#
# Cookbook: redis
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
      include Poise(inversion: true)
      provides(:redis_installation)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute version
      # The version of Redis to install.
      # @return [String]
      attribute(:version, kind_of: [String, NilClass], default: '3.2.0')

      # @return [String]
      def redis_program
        @program ||= provider_for_action(:redis_program).redis_program
      end

      # @return [String]
      def sentinel_program
        @sentinel_program ||= provider_for_action(:sentinel_program).sentinel_program
      end

      # @return [String]
      def cli_program
        @cli_program ||= provider_for_action(:cli_program).cli_program
      end
    end
  end
end
