# helpers for redis-cookbook

module RedisCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    # Define configuration directory for the different platforms
    def config_dir
      case node.platform_family
      when 'debian'
        '/etc/redis'
      else
        '/etc/'
      end
    end

    # Since other platforms like to name the files differently.
    def sentinel_config
      case node.platform_family
      when 'debian'
        "#{config_dir}/sentinel.conf"
      else
        "#{config_dir}/redis-sentinel.conf"
      end
    end

    # Method for start command if sentinel is being used.
    def start_command
      start = '/usr/bin/redis-server'
      case new_resource.sentinel
      when true
        "#{start} #{sentinel_config} --sentinel"
      when false
        "#{start} #{config_dir}/redis.conf"
      end
    end
  end
end
