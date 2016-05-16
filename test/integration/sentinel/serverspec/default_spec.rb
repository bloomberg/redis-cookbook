require 'serverspec'
set :backend, :exec

describe service('redis-sentinel') do
  it { should be_enabled }
  it { should be_running }
end

describe process('redis-sentinel') do
  its(:count) { should eq 1 }
  its(:user) { should eq 'redis' }
  its(:args) { should eq '/usr/bin/redis-sentinel *:26379' }
  it { should be_running }
end

describe user('redis') do
  it { should exist }
end

describe file('/etc/redis-sentinel.conf') do
  it { should exist }
  it { should be_file }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
  it { should be_mode 640 }
end
