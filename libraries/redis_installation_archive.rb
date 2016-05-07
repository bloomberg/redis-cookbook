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
    class RedisInstallationArchive < Chef::Provider
      include Poise(inversion: :redis_installation)
      provides(:archive)

      # Set the default inversion options.
      # @param [Chef::Node] _node
      # @param [Chef::Resource] resource
      # @return [Hash]
      # @api private
      def self.default_inversion_options(_node, resource)
        super.merge(
          archive_url: "http://download.redis.io/releases/redis-%{version}.tar.gz",
          archive_checksum: default_archive_checksum(resource)
        )
      end

      def action_create
        url = options[:archive_url] % {version: new_resource.version}
        notifying_block do
          include_recipe 'build-essential::default'

          poise_archive ::File.basename(url) do
            action :nothing
            destination redis_base
            not_if { ::Dir.exist?(destination) }
            notifies :create, 'link[/usr/local/bin/redis-server]'
            notifies :create, 'link[/usr/local/bin/redis-sentinel]'
            notifies :create, 'link[/usr/local/bin/redis-cli]'
          end

          remote_file ::File.basename(url) do
            source url
            checksum options[:archive_checksum]
            path ::File.join(Chef::Config[:file_cache_path], name)
            notifies :unpack, "poise_archive[#{name}]"
          end

          link '/usr/local/bin/redis-server' do
            to redis_program
            only_if { ::File.exist?(redis_program) }
          end

          link '/usr/local/bin/redis-sentinel' do
            to sentinel_program
            only_if { ::File.exist?(sentinel_program) }
          end

          link '/usr/local/bin/redis-cli' do
            to cli_program
            only_if { ::File.exist?(cli_program) }
          end
        end
      end

      def action_remove
        notifying_block do
          link '/usr/local/bin/redis-server' do
            to redis_program
            action :delete
          end

          link '/usr/local/bin/redis-sentinel' do
            to sentinel_program
            action :delete
          end

          link '/usr/local/bin/redis-cli' do
            to cli_program
            action :delete
          end

          directory redis_base do
            recursive true
            action :delete
          end
        end
      end

      # @return [String]
      # @api private
      def redis_base
        options(:base, "/opt/redis/#{new_resource.version}")
      end

      # @return [String]
      # @api private
      def redis_program
        options.fetch(:program, ::File.join(redis_base, 'src', 'redis-server'))
      end

      # @return [String]
      # @api private
      def sentinel_program
        options.fetch(:sentinel_program, ::File.join(redis_base, 'src', 'redis-sentinel'))
      end

      # @return [String]
      # @api private
      def cli_program
        options.fetch(:cli_program, ::File.join(redis_base, 'src', 'redis-cli'))
      end

      # @param [Chef::Resource] resource
      # @return [String]
      def self.default_archive_checksum(resource)
        case resource.version
        when '3.2.0' then '989f1af3dc0ac1828fdac48cd6c608f5a32a235046dddf823226f760c0fd8762'
        when '3.0.7' then 'b2a791c4ea3bb7268795c45c6321ea5abcc24457178373e6a6e3be6372737f23'
        when '2.8.24' then '6c86ca5291ca7f4e37d9c90511eed67beb6649befe57e2e26307f74adb8630fe'
        when '2.6.17' then '5a65b54bb6deef2a8a4fabd7bd6962654a5d35787e68f732f471bbf117f4768e'
        end
      end
    end
  end
end
