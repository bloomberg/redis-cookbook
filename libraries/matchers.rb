if defined?(ChefSpec)
  %i(enable disable start stop restart).each do |action|
    define_method(:"#{action}_redis_instance") do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new(:redis_instance, action, resource_name)
    end
  end
end
