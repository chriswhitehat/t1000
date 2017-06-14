#
# Cookbook:: t1000
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


user 'canary' do
  action :create
  comment 'Canary User'
  gid 'users'
  home '/home/random'
  shell '/bin/bash'
  password '$1$JJsvHslV$szsCjVEroftprNn4JHtDi.'
end


package 'install_hwe' do
  package_name ['linux-image-generic-lts-xenial', 'linux-generic-lts-xenial']
  action :install
  notifies :reboot_now, 'reboot[hwe_upgraded]', :immediately
end

reboot 'hwe_upgraded' do
	action :nothing
end	


directories = ['/etc/opencanaryd', '/etc/smb/']

directories.each do |directory|

	directory "#{directory}" do
	  owner 'root'
	  group 'root'
	  mode '0755'
	  action :create
	end
end


package 'install_opencanary_deps' do
  package_name ['python-dev', 'python-pip', 'python-pcapy', 'build-essential', 'libssl-dev', 'libffi-dev', 'samba', 'syslog-ng-core' ]
  action :install
end


execute 'pip_opencanary_deps' do
  command 'pip install scapy; pip install rdpy; pip install --upgrade pyopenssl; pip install opencanary'
  creates '/tmp/something'
  action :run
  not_if do ::File.exists?('/usr/local/bin/opencanaryd') end
end


template '/etc/smb/smb.conf' do
  source 'smb/smb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


template '/etc/syslog-ng/conf.d/smb.conf' do
  source 'syslog-ng/smb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end



####################
# Create json lists
####################
http_skins = ""
node[:t1000][:opencanary][:http][:skins].each do |name, skin|
	http_skins << "        {\n"
	http_skins << "            \"name\": \"#{skin[:name]}\",\n"
	http_skins << "            \"desc\": \"#{skin[:desc]}\"\n"
	http_skins << "        },\n"
end
http_skins = http_skins.chomp
http_skins = http_skins.chomp(",")


httpproxy_skins = ""
node[:t1000][:opencanary][:httpproxy][:skins].each do |name, skin|
	httpproxy_skins << "        {\n"
	httpproxy_skins << "            \"name\": \"#{skin[:name]}\",\n"
	httpproxy_skins << "            \"desc\": \"#{skin[:desc]}\"\n"
	httpproxy_skins << "        },\n"
end
httpproxy_skins = httpproxy_skins.chomp
httpproxy_skins = httpproxy_skins.chomp(",")


smb_files = ""
node[:t1000][:opencanary][:smb][:files].each do |name, smb_file|
	smb_files << "        {\n"
	smb_files << "            \"name\": \"#{smb_file[:name]}\",\n"
	smb_files << "            \"type\": \"#{smb_file[:type]}\"\n"
	smb_files << "        },\n"
end
smb_files = smb_files.chomp
smb_files = smb_files.chomp(",")


telnet_honeycreds = ""
node[:t1000][:opencanary][:telnet][:honeycreds].each do |name, telnet_honeycred|
	telnet_honeycreds << "        {\n"
	telnet_honeycreds << "            \"username\": \"#{telnet_honeycred[:username]}\",\n"
	telnet_honeycreds << "            \"password\": \"#{telnet_honeycred[:password]}\"\n"
	telnet_honeycreds << "        },\n"
end
telnet_honeycreds = telnet_honeycreds.chomp
telnet_honeycreds = telnet_honeycreds.chomp(",")


template '/etc/opencanaryd/opencanary.conf' do
  source 'opencanary/opencanary.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
  	:http_skins => http_skins,
  	:httpproxy_skins => httpproxy_skins,
  	:smb_files => smb_files,
  	:telnet_honeycreds => telnet_honeycreds
  	})
end
