name 'redis'
run_list 'redis::default'
default_source :community
cookbook 'redis', path: File.expand_path('../../../..', __FILE__)
