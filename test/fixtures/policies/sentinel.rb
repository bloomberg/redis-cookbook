name 'sentinel'
run_list 'blp-redis::sentinel'
instance_eval(IO.read(File.expand_path('../_base.rb', __FILE__)))
