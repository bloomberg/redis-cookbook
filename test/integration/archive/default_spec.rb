describe service('redis') do
  it { should be_enabled }
  it { should be_installed }
  it { should be_running }
end

describe processes('redis-server') do
  its('list.length') { should eq 1 }
  its('users') { should eq %w[redis] }
end

describe group('redis') do
  it { should exist }
end

describe user('redis') do
  it { should exist }
  its('group') { should eq 'redis' }
end

describe file('/usr/local/bin/redis-server') do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user 'redis' }
end

describe file('/usr/local/bin/redis-cli') do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user 'redis' }
end

describe file('/usr/local/bin/redis-sentinel') do
  it { should exist }
  it { should be_file }
  it { should be_executable.by_user 'redis' }
end

describe file('/etc/redis.conf') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
end

describe file('/var/lib/redis/redis') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
end

describe file('/var/log/redis/redis.log') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
end

describe file('/opt/redis') do
  it { should exist }
  it { should be_directory }
end

describe command('/usr/local/bin/redis-cli SET foo "BAR"') do
  its(:stdout) { should match /OK/ }
end
