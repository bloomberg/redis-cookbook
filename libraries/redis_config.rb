#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Resource
    # A `redis_config` resource to manage the Redis configuration on a
    # node.
    # @provides redis_config
    # @action create
    # @action delete
    # @since 2.0
    class RedisConfig < Chef::Resource
      include Poise(fused: true)
      provides(:redis_config)

      # @!attribute path
      # @return [String]
      attribute(:path, kind_of: String, default: '/etc/redis.conf')
      # @!attribute owner
      # @return [String]
      attribute(:owner, kind_of: String, default: 'redis')
      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'redis')
      # @!attribute mode
      # @return [String]
      attribute(:mode, kind_of: String, default: '0440')

      # @!attribute instance_name
      # @return [String]
      attribute(:instance_name, kind_of: String, name_attribute: true)
      # @!attribute logfile
      # @return [String]
      attribute(:logfile, kind_of: String, default: lazy { "/var/log/redis/#{instance_name}.log" })
      # @!attribute directory
      # @return [String]
      attribute(:directory, kind_of: String, default: lazy { "/var/lib/redis/#{instance_name}" })

      # @see: https://github.com/antirez/redis/blob/3.2/redis.conf
      attribute(:port, kind_of: Integer, default: 6_379)
      attribute(:bind, kind_of: String, default: '0.0.0.0')
      attribute(:unixsocket, kind_of: [String, NilClass], default: nil)
      attribute(:unixsocketperm, kind_of: [String, NilClass], default: nil)
      attribute(:timeout, kind_of: Integer, default: 0)
      attribute(:loglevel, kind_of: String, default: 'notice')
      attribute(:syslog_enabled, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_ident, kind_of: [String, NilClass], default: nil)
      attribute(:syslog_facility, kind_of: [String, NilClass], default: nil)
      attribute(:databases, kind_of: Integer, default: 16)
      attribute(:save, kind_of: [String, Array], default: ['900 1', '300 10', '60 10000'])
      attribute(:stop_writes_on_bgsave_error, equal_to: %w{yes no}, default: 'yes')
      attribute(:rdbcompression, equal_to: %w{yes no}, default: 'yes')
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

      action(:create) do
        directory ::File.dirname(new_resource.logfile) do
          owner new_resource.owner
          group new_resource.group
          recursive true
        end

        template new_resource.path do
          source 'redis.conf.erb'
          owner new_resource.owner
          group new_resource.group
          mode new_resource.mode
          variables resource: new_resource
        end
      end

      action(:delete) do
        file new_resource.path do
          action :delete
        end
      end
    end
  end
end
