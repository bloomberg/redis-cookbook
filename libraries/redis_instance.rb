#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'

module RedisCookbook
  module Resource
    # A `redis_instance` resource which manages the Redis on the node.
    # @provides redis_instance
    # @action enable
    # @action disable
    # @action start
    # @action stop
    # @action restart
    # @since 1.0
    class RedisInstance < Chef::Resource
      include Poise(parent: :redis_installation, container: true)
      provides(:redis_instance)
      include PoiseService::ServiceMixin

      # @!attribute user
      # The user to run the Redis instance as.
      # @return [String]
      attribute(:user, kind_of: String, default: 'redis')
      # @!attribute group
      # The group to run the Redis instance as.
      # @return [String]
      attribute(:group, kind_of: String, default: 'redis')
      # @!attribute directory
      # The directory to start Redis.
      # @return [String]
      attribute(:directory, kind_of: String, default: lazy { "/var/lib/#{service_name}" })
      # @!attribute logfile
      # The log file for the Redis process.
      # @return [String]
      attribute(:logfile, kind_of: String, default: lazy { "/var/log/#{service_name}.log" })
      # @!attribute config_file
      # The configuration file for the Redis instance.
      # @return [String]
      attribute(:config_file, kind_of: String, default: '/etc/redis.conf')
      # @!attribute program
      # The program path for Redis.
      # @return [String]
      attribute(:program, kind_of: String, default: lazy { parent.redis_program })
    end
  end

  module Provider
    # A `redis_instance` provider which manages the Redis service on
    # the node.
    # @provides redis_instance
    # @since 1.0
    class RedisInstance < Chef::Provider
      include Poise
      provides(:redis_instance)
      include PoiseService::ServiceMixin

      def action_enable
        notifying_block do
          directory new_resource.directory do
            recursive true
            owner new_resource.user
            group new_resource.group
          end
        end
        super
      end

      # @api private
      def service_options(service)
        config = new_resource.subresources.each.find do |r|
          r.is_a?(RedisCookbook::Resource::RedisConfig) || r.is_a?(RedisCookbook::Resource::RedisSentinelConfig)
        end

        service.command("#{new_resource.program} #{config.path}")
        service.directory(new_resource.directory)
        service.user(new_resource.user)
      end
    end
  end
end
