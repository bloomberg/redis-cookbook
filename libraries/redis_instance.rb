#
# Cookbook: blp-redis
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
      attribute(:config_path, kind_of: String, default: '/etc/redis.conf')
      # @!attribute config_mode
      # @return [String]
      attribute(:config_mode, kind_of: String, default: '0440')

      # @see: https://github.com/antirez/redis/blob/3.2/redis.conf
      attribute(:port, kind_of: Integer, default: 6_379)
      attribute(:bind, kind_of: String, default: '0.0.0.0')
      attribute(:unixsocket, kind_of: [String, NilClass], default: nil)
      attribute(:unixsocketperm, kind_of: [String, NilClass], default: nil)
      attribute(:tcp_backlog, kind_of: [Integer, NilClass], default: nil)
      attribute(:timeout, kind_of: Integer, default: 0)
      attribute(:loglevel, kind_of: String, default: 'notice')
      attribute(:syslog_enabled, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_ident, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_facility, kind_of: [String, NilClass], default: nil)
      attribute(:databases, kind_of: Integer, default: 16)
      attribute(:save, kind_of: [String, Array], default: ['900 1', '300 10', '60 10000'])
      attribute(:stop_writes_on_bgsave_error, equal_to: %w{yes no}, default: 'yes')
      attribute(:rdbcompression, equal_to: %w{yes no}, default: 'yes')
      attribute(:protected_mode, equal_to: %w{yes no}, default: 'yes')
      attribute(:rdbchecksum, equal_to: %w{yes no}, default: 'yes')
      attribute(:slaveof, kind_of: [String, Array, NilClass], default: nil)
      attribute(:masterauth, kind_of: [String, NilClass], default: nil)
      attribute(:slave_serve_stale_data, equal_to: %w{yes no}, default: 'yes')
      attribute(:slave_read_only, equal_to: %w{yes no}, default: 'yes')
      attribute(:repl_ping_slave_period, kind_of: [String, NilClass], default: nil)
      attribute(:repl_timeout, kind_of: [String, NilClass], default: nil)
      attribute(:slave_priority, kind_of: Integer, default: 100)
      attribute(:requirepass, kind_of: [String, NilClass], default: nil)
      attribute(:maxclients, kind_of: [String, NilClass], default: nil)
      attribute(:maxmemory, kind_of: [String, NilClass], default: nil)
      attribute(:maxmemory_policy, kind_of: [String, NilClass], default: nil)
      attribute(:memory_samples, kind_of: [String, NilClass], default: nil)
      attribute(:dbfilename, kind_of: String, default: 'dump.rdb')
      attribute(:appendonly, equal_to: %w{yes no}, default: 'no')
      attribute(:appendfilename, kind_of: String, default: 'appendonly.aof')
      attribute(:appendfsync, kind_of: String, default: 'everysec')
      attribute(:no_appendfsync_on_rewrite, equal_to: %w{yes no}, default: 'no')
      attribute(:auto_aof_rewrite_percentage, kind_of: Integer, default: 100)
      attribute(:auto_aof_rewrite_min_size, kind_of: String, default: '64mb')
      attribute(:lua_time_limit, kind_of: Integer, default: 5_000)
      attribute(:slowlog_log_slower_than, kind_of: Integer, default: 10_000)
      attribute(:slowlog_max_len, kind_of: Integer, default: 128)
      attribute(:hash_max_ziplist_entries, kind_of: Integer, default: 512)
      attribute(:hash_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:list_max_ziplist_entries, kind_of: Integer, default: 512)
      attribute(:list_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:set_max_intset_entries, kind_of: Integer, default: 512)
      attribute(:zset_max_ziplist_entries, kind_of: Integer, default: 128)
      attribute(:zet_max_ziplist_value, kind_of: Integer, default: 64)
      attribute(:activerehashing, equal_to: %w{yes no}, default: 'yes')
      attribute(:client_output_buffer_limit, kind_of: [String, Array], default: ['normal 0 0 0', 'slave 256mb 64mb 60', 'pubsub 32mb 8mb 60'])

      def default_config_source
        if matches = parent.options.fetch('version', '').match(/\d\.\d/)
          "#{matches.first}/redis.conf.erb"
        else
          '3.2/redis.conf.erb'
        end
      end
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
