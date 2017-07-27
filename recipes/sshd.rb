#
# Cookbook:: t1000
# Recipe:: sshd
#
# Copyright:: 2017, The Authors, All Rights Reserved.


#########################
# Install SSH Issue file
#########################

cookbook_file '/etc/issue.net' do
  source 'issue.net'
  mode '0644'
  owner 'root'
  group 'root'
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[ssh]', :delayed
end

service 'ssh' do
	action :nothing
end