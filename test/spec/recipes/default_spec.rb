require 'spec_helper'

describe_recipe 'redis::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'with default attributes' do
    it { expect(chef_run).to enable_redis_instance('redis') }

    it 'converges successfully' do
      chef_run
    end
  end
end
