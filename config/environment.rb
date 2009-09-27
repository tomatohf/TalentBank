# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')



require "memcache"
# added by Tomato
MemCache_Options = {
  :compression => false, # Turn compression on or off temporarily.
  # :c_threshold => 10_000, # The compression threshold setting, in bytes. Values larger than this threshold will be compressed by #[]= (and set) and decompressed by #[] (and get).
  :namespace => "talent", # If specified, all keys will have the given value prepended before accessing the cache. Defaults to nil.
  :debug => false, # Send debugging output to the object specified as a value if it responds to call, and to $deferr if set to anything else but false or nil.
  :urlencode => false, # If this is set, all cache keys will be urlencoded. If this is not set, keys with certain characters in them may generate client errors when interacting with the cache, but they will be more compatible with those set by other clients. If you plan to use anything but Strings for keys, you should keep this enabled. Defaults to true.
  # :connect_timeout => 300, # If set, specifies the number of floating-point seconds to wait when attempting to connect to a memcached server.
  :readonly => false # If this is set, any attempt to write to the cache will generate an exception. Defaults to false.
}

Cache = MemCache.new("127.0.0.1", MemCache_Options)

# in seconds, which means cache 1 day = 24 hours
Cache_TTL = 60*60*24



Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  
  # enable memcached to store fragment cache
  # config.action_controller.fragment_cache_store = :mem_cache_store, "127.0.0.1", {}
  config.cache_store = :mem_cache_store, "127.0.0.1", MemCache_Options
end