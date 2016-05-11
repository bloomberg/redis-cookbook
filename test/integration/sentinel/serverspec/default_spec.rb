require 'serverspec'
set :backend, :exec

describe service('redis-sentinel') do
  it { should be_enabled }
  it { should be_running }
end

describe process('redis-sentinel') do
  its(:count) { should eq 1 }
  its(:user) { should eq 'redis' }
  its(:args) { should match %r{/etc/redis-sentinel.conf} }
  it { should be_running }
end

describe user('redis') do
  it { should exist }
end

describe file('/etc/redis-sentinel.conf') do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
end
