name 'default'
run_list 'blp-redis::default'
instance_eval(IO.read(File.expand_path('../_base.rb', __FILE__)))