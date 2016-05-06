#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Provider
    # @provides redis_installation
    # @action create
    # @action remove
    # @since 2.0
    class RedisInstallationPackage < Chef::Provider
      include Poise(inversion: :redis_installation)
      provides(:package)

      # Set the default inversion options.
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, resource)
        super.merge(package: default_package_name(node))
      end

      def action_create
        notifying_block do
          package_version = options[:version]
          package options[:package] do
            version package_version if package_version
            action :upgrade
          end
        end
      end

      def action_remove
        notifying_block do
          package_version = options[:version]
          package options[:package] do
            version package_version if package_version
            if node.platform_family?('debian')
              action :purge
            else
              action :remove
            end
          end
        end
      end

      # @return [String]
      # @api private
      def redis_program
        options(:program, '/usr/sbin/redis-server')
      end

      # @param [Chef::Node] node
      # @return [String]
      def self.default_package_name(node)
        case node.platform_family
        when 'debian' then 'redis-server'
        end
      end
    end
  end
end
