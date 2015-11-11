# helpers for redis-cookbook

module RedisCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    # Get config file location based on redis instance name
    def config_path
      ::File.join(new_resource.config_dir,"#{new_resource.instance_name}.conf")
    end

    # Method for start command if sentinel is being used.
    def start_command
      command = "/usr/bin/redis-server #{config_path}"
      new_resource.sentinel ? "#{command} --sentinel" : command
    end
  end
end
