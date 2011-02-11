# We're riding on Sinatra, so let's include it.
require "sinatra/base"

# Use the padrino project's helpers
require "padrino-core/application/rendering"
require "padrino-helpers"

module Middleman
  class Server < Sinatra::Base
    # Basic Sinatra config
    set :app_file,    __FILE__
    set :root,        ENV["MM_DIR"] || Dir.pwd
    set :reload,      false
    set :sessions,    false
    set :logging,     false
    set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development

    # Import padrino helper methods

    # Middleman-specific options
    set :index_file,  "index.html"  # What file responds to folder requests
                                    # Such as the homepage (/) or subfolders (/about/)

    # These directories are passed directly to Compass
    set :js_dir,      "javascripts" # Where to look for javascript files
    set :css_dir,     "stylesheets" # Where to look for CSS files
    set :images_dir,  "images"      # Where to look for images
    set :fonts_dir,   "fonts"       # Where to look for fonts

    set :build_dir,   ENV['MM_ENV'] || 'build'       # Which folder are builds output to
    set :http_prefix, nil           # During build, add a prefix for absolute paths

    # Use Padrino Helpers
    register Padrino::Helpers
    set :asset_stamp, false         # Disable Padrino cache buster until explicitly enabled

    # Activate custom features
    register Middleman::Features

    # Activate built-in helpers
    register Middleman::Features::DefaultHelpers

    # Tilt-aware renderer
    register Padrino::Rendering

    # Override Sinatra's set to accept a block
    def self.set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
      end

      super(option, value, &nil)
    end

    # An array of callback procs to run after all features have been setup
    @@run_after_features = []

    # Add a block/proc to be run after features have been setup
    def self.after_feature_init(&block)
      @@run_after_features << block
    end

    # Activate custom renderers
    register Middleman::Renderers::Haml
    register Middleman::Renderers::Sass

    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end

    # Default layout name
    layout :layout

    def self.current_layout
      @layout
    end

    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def self.with_layout(layout_name, &block)
      old_layout = current_layout

      layout(layout_name)
      class_eval(&block) if block_given?
    ensure
      layout(old_layout)
    end

    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def self.page(url, options={}, &block)
      url << settings.index_file if url.match(%r{/$})

      options[:layout] ||= current_layout
      get(url) do
        return yield if block_given?
        process_request(options)
      end
    end

    # This will match all requests not overridden in the project's config.rb
    not_found do
      process_request
    end

  private
    # Internal method to look for templates and evaluate them if found
    def process_request(options={})
      # Normalize the path and add index if we're looking at a directory
      path = request.path
      path << settings.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')

      old_layout = settings.current_layout
      settings.layout(options[:layout]) if !options[:layout].nil?
      result = render(path, :layout => path.include?('stylesheets') ? false : settings.fetch_layout_path.to_sym)
      settings.layout(old_layout)

      if result
        content_type mime_type(File.extname(path)), :charset => 'utf-8'
        status 200
        return result
      end

      status 404
    rescue Padrino::Rendering::TemplateNotFound
      $stderr.puts "File not found: #{request.path}"
      status 404
    end
  end
end

require "middleman/assets"

# The Rack App
class Middleman::Server
  def self.new(*args, &block)
    # If the old init.rb exists, use it, but issue warning
    old_config = File.join(self.root, "init.rb")
    if File.exists? old_config
      $stderr.puts "== Warning: The init.rb file has been renamed to config.rb"
      local_config = old_config
    end

    # Check for and evaluate local configuration
    local_config ||= File.join(self.root, "config.rb")
    if File.exists? local_config
      $stderr.puts "== Reading:  Local config" if logging?
      Middleman::Server.class_eval File.read(local_config)
      set :app_file, File.expand_path(local_config)
    end

    use ::Rack::ConditionalGet if environment == :development

    @@run_after_features.each { |block| class_eval(&block) }

    super
  end
end
