require 'serverspec'
set :backend, :exec

describe service('redis') do
  it { should be_enabled }
  it { should be_running }
end

describe process('redis-server') do
  its(:count) { should eq 1 }
  its(:user) { should eq 'redis' }
  its(:args) { should match '0.0.0.0:6379' }
  it { should be_running }
end

describe user('redis') do
  it { should exist }
end

describe file('/etc/redis.conf') do
  it { should be_file }
  it { should be_owned_by 'redis' }
  it { should be_grouped_into 'redis' }
end

%w{redis-server redis-sentinel redis-cli}.each do |program|
  describe file("/opt/redis/3.2.0/src/#{program}") do
    it { should be_file }
    it { should be_executable }
  end

  describe file("/usr/local/bin/#{program}") do
    it { should be_linked_to "/opt/redis/3.2.0/src/#{program}" }
  end
end
