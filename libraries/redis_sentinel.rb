#
# Cookbook: blp-redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'

module RedisCookbook
  module Resource
    # A `redis_sentinel` resource which manages the Redis on the node.
    # @provides redis_sentinel
    # @action enable
    # @action disable
    # @action start
    # @action stop
    # @action restart
    # @since 1.0
    class RedisSentinel < Chef::Resource
      include Poise(parent: :redis_installation, container: true)
      provides(:redis_sentinel)
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
      attribute(:directory, kind_of: String, default: lazy { "/var/lib/redis/#{service_name}" })
      # @!attribute logfile
      # The log file for the Redis process.
      # @return [String]
      attribute(:logfile, kind_of: String, default: lazy { "/var/log/redis/#{service_name}.log" })
      # @!attribute program
      # The program path for Redis.
      # @return [String]
      attribute(:program, kind_of: String, default: lazy { parent.redis_program })

      attribute(:config, template: true, default_source: lazy { default_config_source })
      # @!attribute config_path
      # @return [String]
      attribute(:config_path, kind_of: String, default: '/etc/redis-sentinel.conf')
      # @!attribute config_mode
      # @return [String]
      attribute(:config_mode, kind_of: String, default: '0440')

      # @see: https://github.com/antirez/redis/blob/3.2/sentinel.conf
      attribute(:sentinel_port, kind_of: Integer, default: 26_379)
      attribute(:sentinel_master_name, kind_of: String, default: 'mymaster')
      attribute(:sentinel_monitor, kind_of: String, default: '127.0.0.1 6379 2')
      attribute(:sentinel_auth, kind_of: String, default: 'changeme')
      attribute(:sentinel_down, kind_of: Integer, default: 30_000)
      attribute(:sentinel_parallel, kind_of: Integer, default: 1)
      attribute(:sentinel_failover, kind_of: Integer, default: 180_000)
      attribute(:sentinel_notification, kind_of: [String, NilClass], default: nil)
      attribute(:sentinel_client_reconfig, kind_of: [String, NilClass], default: nil)

      def default_config_source
        if parent.version
          "#{parent.version.match(/\d\.\d/).first}/sentinel.conf.erb"
        else
          'sentinel.conf.erb'
        end
      end
    end
  end

  module Provider
    # A `redis_sentinel` provider which manages the Redis service on
    # the node.
    # @provides redis_sentinel
    # @since 3.0
    class RedisSentinel < Chef::Provider
      include Poise
      provides(:redis_sentinel)
      include PoiseService::ServiceMixin

      def action_enable
        notifying_block do
          [new_resource.directory, ::File.dirname(new_resource.logfile)].each do |dirname|
            directory dirname do
              recursive true
              owner new_resource.user
              group new_resource.group
            end
          end

          file new_resource.config_path do
            content new_resource.config_content
            owner new_resource.user
            group new_resource.group
            mode new_resource.config_mode
          end
        end
        super
      end

      def action_disable
        super
        notifying_block do
          file new_resource.config_path do
            action :delete
          end
        end
      end

      # @api private
      def service_options(service)
        service.command("#{new_resource.program} #{new_resource.config_path}")
        service.directory(new_resource.directory)
        service.user(new_resource.user)
      end
    end
  end
end
