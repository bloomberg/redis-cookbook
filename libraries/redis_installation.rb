#
# Cookbook: blp-redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Resource
    # An `redis_installation` resource which manages the Redis
    # installation on the node.
    # @provides redis_installation
    # @action create
    # @action remove
    # @since 2.0
    class RedisInstallation < Chef::Resource
      include Poise(container: true, inversion: true)
      provides(:redis_installation)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute version
      # The version of Redis to install.
      # @return [String]
      attribute(:version, kind_of: String, name_attribute: true)

      # @return [String]
      def redis_program
        provider_for_action(:redis_program).redis_program
      end

      # @return [String]
      def sentinel_program
        provider_for_action(:sentinel_program).sentinel_program
      end

      # @return [String]
      def cli_program
        provider_for_action(:cli_program).cli_program
      end
    end
  end

  module Provider
    # The `redis_installation` base provider.
    # @abstract
    # @since 3.0
    class RedisInstallation < Chef::Provider
      include Poise(inversion: :redis_installation)

      # Set the default inversion options.
      # @private
      def self.default_inversion_options(_node, new_resource)
        super.merge(version: new_resource.version)
      end

      def action_create
        notifying_block do
          install_redis
        end
      end

      def action_remove
        notifying_block do
          uninstall_redis
        end
      end

      # @abstract
      # @return [String]
      def redis_program
        raise NotImplementedError
      end

      # @abstract
      # @return [String]
      def sentinel_program
        raise NotImplementedError
      end

      # @abstract
      # @return [String]
      def cli_program
        raise NotImplementedError
      end

      private

      # @abstract
      # @return [void]
      def install_redis
        raise NotImplementedError
      end

      # @abstract
      # @return [void]
      def uninstall_redis
        raise NotImplementedError
      end
    end
  end
end
