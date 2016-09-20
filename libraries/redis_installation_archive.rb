#
# Cookbook: redis
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#
require 'poise'

module RedisCookbook
  module Provider
    # A `redis_installation` provider implementation which installs
    # from an archive.
    # @provides redis_installation
    # @action create
    # @action remove
    # @since 2.0
    class RedisInstallationArchive < RedisInstallation
      provides(:archive)

      # Set the default inversion options.
      # @param [Chef::Node] _node
      # @param [Chef::Resource] resource
      # @return [Hash]
      # @api private
      def self.default_inversion_options(_node, resource)
        super.merge(prefix: '/opt/redis',
                    version: resource.version,
                    archive_url: 'http://download.redis.io/releases/redis-%{version}.tar.gz',
                    archive_checksum: default_archive_checksum(resource))
      end

      # @return [String]
      # @api private
      def redis_program
        options.fetch(:program, ::File.join(static_folder, 'src', 'redis-server'))
      end

      # @return [String]
      # @api private
      def sentinel_program
        options.fetch(:sentinel_program, ::File.join(static_folder, 'src', 'redis-sentinel'))
      end

      # @return [String]
      # @api private
      def cli_program
        options.fetch(:cli_program, ::File.join(static_folder, 'src', 'redis-cli'))
      end

      # @return [String]
      # @api private
      def static_folder
        ::File.join(options[:prefix], new_resource.version)
      end

      # @param [Chef::Resource] resource
      # @return [String]
      # @api private
      def self.default_archive_checksum(resource)
        case resource.version
        when '3.2.3' then '674e9c38472e96491b7d4f7b42c38b71b5acbca945856e209cb428fbc6135f15'
        when '3.0.7' then 'b2a791c4ea3bb7268795c45c6321ea5abcc24457178373e6a6e3be6372737f23'
        when '2.8.24' then '6c86ca5291ca7f4e37d9c90511eed67beb6649befe57e2e26307f74adb8630fe'
        when '2.6.17' then '5a65b54bb6deef2a8a4fabd7bd6962654a5d35787e68f732f471bbf117f4768e'
        end
      end

      private

      # @api private
      def install_redis
        include_recipe 'build-essential::default'

        url = options[:archive_url] % {version: options[:version]}
        poise_archive url do
          notifies :run, 'bash[make-redis]', :immediately
          destination static_folder
          not_if { ::File.exist?(redis_program) }
        end

        bash 'make-redis' do
          action :nothing
          cwd static_folder
          code 'make'
          notifies :create, 'link[/usr/local/bin/redis-server]'
          notifies :create, 'link[/usr/local/bin/redis-sentinel]'
          notifies :create, 'link[/usr/local/bin/redis-cli]'
        end

        # Actually build the database from the extracted archive.
        link '/usr/local/bin/redis-server' do
          action :nothing
          to redis_program
        end

        link '/usr/local/bin/redis-sentinel' do
          action :nothing
          to sentinel_program
        end

        link '/usr/local/bin/redis-cli' do
          action :nothing
          to cli_program
        end
      end

      # @api private
      def uninstall_redis
        link '/usr/local/bin/redis-server' do
          action :delete
          to redis_program
        end

        link '/usr/local/bin/redis-sentinel' do
          action :delete
          to sentinel_program
        end

        link '/usr/local/bin/redis-cli' do
          action :delete
          to cli_program
        end
      end
    end
  end
end
