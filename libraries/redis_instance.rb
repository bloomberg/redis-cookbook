#
# Cookbook: redis-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
require 'poise_service/service_mixin'
require_relative 'helpers'

class Chef::Resource::RedisInstance < Chef::Resource
  include Poise
  provides(:redis_instance)
  include PoiseService::ServiceMixin

  actions(:enable, :disable)
  default_action(:enable)

  # @!attribute config_name
  # @return [String]
  attribute(:config_name, kind_of: String, name_attribute: true)

  # @!attribute pkg
  # @return [String]
  attribute(:pkg, kind_of: String, default: 'redis-server') # default for ubuntu

  # @!attribute version
  # @return [String, NilClass]
  attribute(:version, kind_of: [String, NilClass], default: nil)

  # @!attribute user
  # @return [String]
  attribute(:user, kind_of: String, default: 'root')

  # @!attribute group
  # @return [String]
  attribute(:group, kind_of: String, default: 'root')

  # @see: https://raw.githubusercontent.com/antirez/redis/2.8/redis.conf
  attribute(:pid_file, kind_of: String, default: '/var/run/redis/redis-server.pid')
  attribute(:port, kind_of: Integer, default: '6379')
  attribute(:bind, kind_of: String, default: '0.0.0.0')
  attribute(:unixsocket, kind_of: [String, NilClass], default: nil)
  attribute(:unixsocketperm, kind_of: [String, NilClass], default: nil)
  attribute(:timeout, kind_of: Integer, default: '0')
  attribute(:loglevel, kind_of: String, default: 'notice')
  attribute(:syslog_enabled, kind_of: [String, NilClass], default: nil)
  attribute(:syslog_ident, kind_of: [String, NilClass], default: nil)
  attribute(:syslog_facility, kind_of: [String, NilClass], default: nil)
  attribute(:logfile, kind_of: String, default: '/var/log/redis/redis-server.log')
  attribute(:databases, kind_of: Integer, default: '16')
  attribute(:save, kind_of: [String, Array], default: ['900 1', '300 10', '60 10000'])
  attribute(:stop_writes_on_bgsave_error, equal_to: %w{yes no}, default: 'yes')
  attribute(:rdbcompression, equal_to: %w{yes no}, default: 'yes')
  attribute(:rdbchecksum, equal_to: %w{yes no}, default: 'yes')
  attribute(:dir, kind_of: String, default: '/var/lib/redis')
  attribute(:slaveof, kind_of: [String, Array, NilClass], default: nil)
  attribute(:masterauth, kind_of: [String, NilClass], default: nil)
  attribute(:slave_serve_stale_data, equal_to: %w{yes no}, default: 'yes')
  attribute(:slave_read_only, equal_to: %w{yes no}, default: 'yes')
  attribute(:repl_ping_slave_period, kind_of: [String, NilClass], default: nil)
  attribute(:repl_timeout, kind_of: [String, NilClass], default: nil)
  attribute(:slave_priority, kind_of: Integer, default: '100')
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
  attribute(:auto_aof_rewrite_percentage, kind_of: Integer, default: '100')
  attribute(:auto_aof_rewrite_min_size, kind_of: Integer, default: '64mb')
  attribute(:lua_time_limit, kind_of: Integer, default: '5000')
  attribute(:slowlog_log_slower_than, kind_of: Integer, default: '10000')
  attribute(:slowlog_max_len, kind_of: Integer, default: '128')
  attribute(:hash_max_ziplist_entries, kind_of: Integer, default: '512')
  attribute(:hash_max_ziplist_value, kind_of: Integer, default: '64')
  attribute(:list_max_ziplist_entries, kind_of: Integer, default: '512')
  attribute(:list_max_ziplist_value, kind_of: Integer, default: '64')
  attribute(:set_max_intset_entries, kind_of: Integer, default: '512')
  attribute(:zset_max_ziplist_entries, kind_of: Integer, default: '128')
  attribute(:zet_max_ziplist_value, kind_of: Integer, default: '64')
  attribute(:activerehashing, equal_to: %w{yes no}, default: 'yes')
  attribute(:client_output_buffer_limit, kind_of: [String, Array], default: ['normal 0 0 0', 'slave 256mb 64mb 60', 'pubsub 32mb 8mb 60'])
  attribute(:include, kind_of: [Array, NilClass], default: nil)

  # @!attribute sentinel
  # # @return [TrueClass, FalseClass]
  attribute(:sentinel, :kind_of => [TrueClass, FalseClass], default: false)

  # @see: https://github.com/antirez/redis/blob/unstable/sentinel.conf
  attribute(:sentinel_port, :kind_of => Integer, default: '26379')
  attribute(:sentinel_master_name, :kind_of => String, default: 'mymaster')
  attribute(:sentinel_monitor, :kind_of => String, default: '127.0.0.1 6379 2')
  attribute(:sentinel_auth, :kind_of => String, default: 'notneverthatsecureYOLO')
  attribute(:sentinel_down, :kind_of => Integer, default: '30000')
  attribute(:sentinel_parallel, :kind_of => Integer, default: '1')
  attribute(:sentinel_failover, :kind_of => Integer, default: '180000')
  attribute(:sentinel_notification, :kind_of => [String, NilClass], default: nil) # Dir.home('redis') + '/notify.sh'
  attribute(:sentinel_client_reconfig, :kind_of => [String,NilClass], default: nil) # Dir.home('redis') + '/reconfig.sh'
end

class Chef::Provider::RedisInstance < Chef::Provider
  include Poise
  provides(:redis_instance)
  include PoiseService::ServiceMixin
  include RedisCookbook::Helpers

  # Setup config files for redis
  def action_enable
    notifying_block do
      # Install Packages
      package new_resource.pkg do
        package_name new_resource.pkg
        version new_resource.version unless new_resource.version.nil?
        action :upgrade
      end

      # Create directory if it does not exist
      directory "#{config_dir}" do
        recursive true
        action :create
      end

      # Place configuration file on the filesystem
      template "#{new_resource.config_name} :create #{config_dir}/redis.conf" do
        path "#{config_dir}/redis.conf"
        source "redis.conf.erb"
        variables(
          config: new_resource
        )
        cookbook 'redis'
        owner new_resource.user
        group new_resource.group
      end

      # Add statemenet for sentinel configuration.
      unless new_resource.sentinel == false
        template "sentinel :create #{sentinel_config}" do
          path "#{sentinel_config}"
          source "sentinel.conf.erb"
          variables(
            config: new_resource
          )
          cookbook 'redis'
          owner new_resource.user
          group new_resource.group
        end
      end
    end
    super
  end

  def service_options(service)
    service.service_name('redis')
    service.command(start_command)
    service.directory('/var/run/redis')
    service.user('redis')
    service.restart_on_update(true)
  end
end
