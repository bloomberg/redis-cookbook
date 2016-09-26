#
# Cookbook: blp-redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Provider
    # A `redis_installation` provider implementation which installs
    # from the system package manager.
    # @provides redis_installation
    # @action create
    # @action remove
    # @since 2.0
    class RedisInstallationPackage < RedisInstallation
      provides(:package)

      # @param [Chef::Node] _node
      # @param [Chef::Resource] _resource
      # @return [TrueClass, FalseClass]
      # @api private
      def self.provides_auto?(_node, _resource)
        true
      end

      # @param [Chef::Node] node
      # @param [Chef::Resource] new_resource
      # @api private
      def self.default_inversion_options(node, new_resource)
        package_version = if new_resource.version.nil? || new_resource.version.empty?
                            default_package_version(node)
                          else
                            resource.version
                          end
        super.merge(package_name: default_package_name(node), version: package_version)
      end

      # @return [String]
      # @api private
      def redis_program
        options.fetch(:program, '/usr/bin/redis-server')
      end

      # @return [String]
      # @api private
      def sentinel_program
        options.fetch(:sentinel_program, '/usr/bin/redis-sentinel')
      end

      # @return [String]
      # @api private
      def cli_program
        options.fetch(:cli_program, '/usr/bin/redis-cli')
      end

      # @param [Chef::Node] node
      # @return [String]
      def self.default_package_name(node)
        case node['platform_family']
        when 'rhel' then 'redis'
        when 'debian' then 'redis-server'
        when 'freebsd' then 'redis'
        end
      end

      # @param [Chef::Node] node
      # @return [String]
      # @api private
      def self.default_package_version(node)
        case node['platform']
        when 'redhat', 'centos'
          case node['platform_version'].to_i
          when 5 then '2.4.10-1.el5'
          when 6 then '2.4.10-1.el6'
          when 7 then '2.8.19-2.el7'
          end
        when 'ubuntu'
          case node['platform_version'].to_i
          when 12 then '2.2.12-1'
          when 14 then '2:2.8.4-2'
          when 16 then '2:3.0.6-1'
          end
        when 'freebsd'
          case node['platform_version'].to_i
          when 9 then '3.0.7'
          when 10 then '3.0.7'
          end
        end
      end

      private

      # @api private
      def install_redis
        system_package_name = options[:package_name]
        system_package_version = options[:version]

        init_file = file '/etc/init.d/redis-server' do
          action :nothing
        end

        if node.platform_family?('debian')
          dpkg_autostart 'redis-server' do
            action :nothing
            allow false
          end
        end

        package system_package_name do
          notifies :delete, init_file, :immediately
          version system_package_version if system_package_version
          if node.platform_family?('debian')
            notifies :create, 'dpkg_autostart[redis-server]', :immediately
            options '-o Dpkg::Options::=--path-exclude=/etc/redis*'
          end
        end
      end

      # @api private
      def uninstall_redis
        package options[:package_name] do
          if node.platform_family?('debian')
            action :purge
          else
            action :remove
          end
        end
      end
    end
  end
end
