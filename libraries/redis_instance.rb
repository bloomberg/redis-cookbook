#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise_service/service_mixin'
require_relative 'helpers'

module RedisCookbook
  module Resource
    # @provides redis_instance
    # @action enable
    # @action disable
    # @action start
    # @action stop
    # @action restart
    # @since 1.0
    class RedisInstance < Chef::Resource
      include Poise
      provides(:redis_instance)
      include PoiseService::ServiceMixin

      # @!attribute instance_name
      # @return [String]
      attribute(:instance_name, kind_of: String, name_attribute: true)

      # @!attribute pkg
      # @return [String]
      attribute(:pkg, kind_of: String, default: 'redis-server') # default for ubuntu

      # @!attribute version
      # @return [String, NilClass]
      attribute(:version, kind_of: [String, NilClass], default: nil)

      # @!attribute user
      # @return [String]
      attribute(:user, kind_of: String, default: 'redis')

      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'redis')

      # @!attribute config_dir
      # @return [String]
      attribute(:config_dir, kind_of: String, default: '/etc/redis')

      # @!attribute log_dir
      # @return [String]
      attribute(:log_dir, kind_of: String, default: '/var/log/redis/')

      attribute(:include, kind_of: [Array, NilClass], default: nil)

      # @!attribute sentinel
      # @return [TrueClass, FalseClass]
      attribute(:sentinel, kind_of: [TrueClass, FalseClass], default: false)

    end
  end

  module Provider
    # @since 1.0.0
    class RedisInstance < Chef::Provider
      include Poise
      provides(:redis_instance)
      include PoiseService::ServiceMixin
      include RedisCookbook::Helpers

      # Installs and sets up the Redis package and configuration.
      # @since 1.0.0
      def action_enable
        notifying_block do
          # Install Packages
          package new_resource.pkg do
            package_name new_resource.pkg
            version new_resource.version unless new_resource.version.nil?
            action :upgrade
            notifies :restart, new_resource
          end

          # Installing package starts redis service automatically
          # Disable this so that redis can be managed through poise-service
          service new_resource.pkg do
            action [:disable, :stop]
          end

          directory new_resource.dir do
            recursive true
            user new_resource.user
            group new_resource.group
            mode '0755'
          end

          directory new_resource.config_dir do
            recursive true
            user new_resource.user
            group new_resource.group
            mode '0755'
          end

          # Place configuration file on the filesystem
          config_source = new_resource.sentinel ? 'sentinel.conf.erb' : 'redis.conf.erb'
          template config_path do
            source config_source
            variables(config: new_resource)
            cookbook 'redis'
            owner new_resource.user
            group new_resource.group
            notifies :restart, new_resource
          end
        end
        super
      end

      # Deletes and removes configuration for the Redis instance.
      # @since 1.0.0
      def action_disable
        super
        notifying_block do
          file config_path do
            action :delete
          end

          directory new_resource.config_dir do
            action :delete
            not_if { new_resource.config_dir == '/etc' }
            only_if { Dir["#{new_resource.config_dir}/*"].empty? }
          end
        end
      end

      def service_options(service)
        service.command(start_command)
        service.directory(new_resource.dir)
        service.user(new_resource.user)
        service.restart_on_update(true)
      end
    end
  end
end
