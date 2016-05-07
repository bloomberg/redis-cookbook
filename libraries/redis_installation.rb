#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Resource
    # @provides redis_installation
    # @action create
    # @action remove
    # @since 2.0
    class RedisInstallation < Chef::Resource
      include Poise(inversion: true)
      provides(:redis_installation)
      actions(:create, :remove)

      # @!attribute version
      # The version of Redis to install.
      # @return [String]
      attribute(:version, kind_of: [String, NilClass], default: nil)

      # @return [String]
      def redis_program
        @program ||= provider_for_action(:redis_program).redis_program
      end

      # @return [String]
      def cli_program
        @cli_program ||= provider_for_action(:cli_program).cli_program
      end
    end
  end
end
