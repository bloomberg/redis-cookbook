# helpers for redis-cookbook

module RedisCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    # Define configuration directory for the different platforms
    def config_dir
      case node.platform_family
      when "debian"
        "/etc/redis"
      else
        "/etc"
      end
    end

  end
end
