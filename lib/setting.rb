require 'singleton'
require 'yaml'
require 'erb'
require 'hashie'

class Setting
  class NotFound < RuntimeError; end
  class FileError < RuntimeError; end
  class AlreadyLoaded < RuntimeError; end

  include Singleton
  NUM_KLASS = if RUBY_VERSION.split(/\./)[0].to_i == 2 && RUBY_VERSION.split(/\./)[1].to_i >= 4
                Integer
              else
                Fixnum
              end

  attr_reader :available_settings

  # This method can be called only once.
  #
  # Parameter hash looks like this:
  #
  #  {  :files => [ "file1.yml", "file2.yml", ...],
  #     :path  => "/var/www/apps/my-app/current/config/settings",
  #     :local => true }
  #
  # If :local => true is set, we will load all *.yml files under :path/local directory
  # after all files in :files have been loaded.  "Local" settings thus take precedence
  # by design.  See README for more details.
  #
  def self.load(args = {})
    raise AlreadyLoaded.new('Settings already loaded') if self.instance.loaded?
    self.instance.load(args)
  end

  def self.reload(args = {})
    self.instance.load(args)
  end

  # In Method invocation syntax we collapse Hash values
  # and return a single value if 'default' is found among keys
  # or Hash has only one key/value pair.
  #
  # For example, if the YML data is:
  # tax:
  #   default: 0.0
  #   california: 7.5
  #
  # Then calling Setting.tax returns "0.0""
  #
  # This is the preferred method of using settings class.
  #
  def self.method_missing(method, *args, &block)
    self.instance.value_for(method, args) do |v, args|
      self.instance.collapse_hashes(v, args)
    end
  end

  def self.respond_to?(method_name, include_private = false)
    self.instance.available_settings.has_key?(method_name.to_s.sub(/\?\z/, '')) ||
      super
  end

  # In [] invocation syntax, we return settings value 'as is' without
  # Hash conversions.
  #
  # For example, if the YML data is:
  # tax:
  #   default: 0.0
  #   california: 7.5
  #
  # Then calling Setting['tax'] returns
  #   { 'default' => "0.0", 'california' => "7.5"}

  def self.[](value)
    self.instance.value_for(value)
  end

  # <b>DEPRECATED:</b> Please use <tt>method accessors</tt> instead.
  def self.available_settings
    self.instance.available_settings
  end

  #=================================================================
  # Instance Methods
  #=================================================================

  def initialize
    @available_settings ||= Hashie::Mash.new
  end

  def has_key?(key)
    @available_settings.has_key?(key) ||
      (key[-1,1] == '?' && @available_settings.has_key?(key.chop))
  end

  def value_for(key, args = [])
    name = key.to_s
    raise NotFound.new("#{name} was not found") unless has_key?(name)
    bool = false
    if name[-1,1] == '?'
      name.chop!
      bool = true
    end

    v = @available_settings[name]
    if block_given?
      v = yield(v, args)
    end


    if v.is_a?(NUM_KLASS) && bool
      v.to_i > 0
    else
      v
    end
  end

  # This method performs collapsing of the Hash settings values if the Hash
  # contains 'default' value, or just 1 element.

  def collapse_hashes(v, args)
    out = if v.is_a?(Hash)
      if args.empty?
        if v.has_key?("default")
          v['default'].nil? ? "" : v['default']
        elsif v.keys.size == 1
          v.values.first
        else
          v
        end
      else
        v[args.shift.to_s]
      end
    else
      v
    end
    if out.is_a?(Hash) && !args.empty?
        collapse_hashes(out, args)
    elsif out.is_a?(Hash) && out.has_key?('default')
      out['default']
    else
      out
    end
  end

  def loaded?
    @loaded
  end

  def load(params)
    # reset settings hash
    @available_settings = Hashie::Mash.new
    @loaded = false

    files = []
    path  = params[:path] || Dir.pwd
    params[:files].each do |file|
      files << File.join(path, file)
    end

    if params[:local]
      files << Dir.glob(File.join(path, 'local', '*.yml')).sort
    end

    files.flatten.each do |file|
      begin
        # Ruby versions before 3.0.3 include Psych < 3.3.2, which does not include `unsafe_load`. In those versions,
        # `load` is the behavior we want (in later versions, `load` uses `safe_load`, which doesn't support aliases and
        # requires allowlisting classes used in files.
        if Psych::VERSION < '3.3.2'
          @available_settings.deep_merge!(YAML::load(ERB.new(IO.read(file)).result) || {}) if File.exists?(file)
        else
          @available_settings.deep_merge!(YAML::unsafe_load(ERB.new(IO.read(file)).result) || {}) if File.exists?(file)
        end
      rescue Exception => e
        raise FileError.new("Error parsing file #{file}, with: #{e.message}")
      end
    end

    @loaded = true
    @available_settings
  end
end
