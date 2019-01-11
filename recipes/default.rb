#
# Cookbook:: t1000
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


if node[:t1000][:mgmt][:configure]
  template "/etc/network/interfaces.d/#{node[:t1000][:mgmt][:interface]}" do
    source 'interface.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  # template '/etc/hosts' do
  #   source 'hosts.erb'
  #   owner 'root'
  #   group 'root'
  #   mode '0644'
  # end
  
end

template '/etc/timezone' do
  source 'timezone.erb'
  mode '0644'
  owner 'root'
  group 'root'
  notifies :run, 'execute[set-timezone]', :immediately
end

execute 'set-timezone' do
  command "timedatectl set-timezone #{ node['t1000']['timezone'] }"
  action :nothing
end

# execute 'initial_upgrade' do
#   command "apt-get update; apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade; apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade"
#   not_if do ::File.exists?('/etc/opencanaryd/t1000.target') end
#   action :run
#   notifies :reboot_now, 'reboot[initial_upgrade_reboot]'
# end

# reboot 'initial_upgrade_reboot' do
#   reason 'Cannot continue Chef run without a reboot.'
#   action :nothing
# end


# python_runtime '2' do
#   pip_version '18.0'
#   get_pip_url 'https://github.com/pypa/get-pip/raw/f88ab195ecdf2f0001ed21443e247fb32265cabb/get-pip.py'
# end

# python_runtime '2' 


package 'install_deps' do
  package_name ['python-setuptools', 'python-dev', 'build-essential', 'libssl-dev', 'libffi-dev', 'syslog-ng-core', 'libpcap-dev', 'nmap', 'git', 'macchanger']
  action :install
end

# python_package 'install_python_deps' do
#   package_name ['scapy', 'rdpy']
# end

# python_package 'upgrade_python_deps' do
#   package_name ['pyopenssl']
#   action :upgrade
# end

# python_package 'install_python_deps2' do 
#   package_name ['pcapy', 'python-nmap']
# end

# python_package 'upgrade_python_deps2' do
#   package_name ['twisted']
#   action :upgrade
# end

package 'install_python_deps' do
  package_name ['python-scapy', 'python-pcapy', 'python-nmap', 'python-twisted', 'python-netaddr']
  action :install
end



directories = ['/etc/opencanaryd', '/etc/opencanaryd/ssl', '/etc/smb/']

directories.each do |directory|

  directory "#{directory}" do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

directory '/var/log/opencanary/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


user 'canary' do
  action :create
  comment 'Canary User'
  gid 'users'
  home '/home/canary'
  shell '/bin/bash'
  password '$1$JJsvHslV$szsCjVEroftprNn4JHtDi.'
end


remote_file '/tmp/mitmproxy-2.0.2-linux.tar.gz' do
  owner 'root'
  group 'root'
  mode '0644'
  source 'http://github.com/mitmproxy/mitmproxy/releases/download/v2.0.2/mitmproxy-2.0.2-linux.tar.gz'
  checksum '6da28a8fa67de25c3d753b34524b8a49156e82a5f25f23989b1ebb386f29574f'
  not_if do ::File.exists?('/usr/local/bin/mitmproxy') end
  notifies :run, 'execute[extract_mitmproxy]', :immediately
end

execute 'extract_mitmproxy' do
  command 'tar -xzf /tmp/mitmproxy-2.0.2-linux.tar.gz -C /usr/local/bin'
  action :nothing
end



git "#{Chef::Config[:file_cache_path]}/opencanary" do
  repository 'http://github.com/chriswhitehat/opencanary.git'
  reference 'master'
  action :sync
  notifies :run, 'bash[install_opencanary]', :immediately
  notifies :run, 'execute[replace_opencanary_tac]', :immediately
end

bash 'install_opencanary' do
  cwd "#{Chef::Config[:file_cache_path]}/opencanary"
  user 'root'
  group 'root'
  code <<-EOH
    python setup.py install
    EOH
  action :nothing
end

# execute 'install_opencanary_t1000' do
#   command 'cd tmp; git clone https://github.com/chriswhitehat/opencanary.git; cd opencanary; python setup.py install'
#   action :run
#   not_if do ::File.exists?('/usr/local/bin/opencanaryd') end  
#end


# Fix to overcome egg run script bug in setup.py
# https://github.com/thinkst/opencanary/issues/34
execute 'replace_opencanary_tac' do
  command "mv #{Chef::Config[:file_cache_path]}/opencanary/bin/opencanary.tac /usr/local/bin/opencanary.tac; mv #{Chef::Config[:file_cache_path]}/opencanary/bin/t1000.py /usr/local/bin/t1000.py;"
  #only_if do ::File.exists?('/tmp/opencanary/bin/opencanary.tac') end  
  action :nothing
end

logrotate_app 'opencanary_logs' do
  path      '/var/log/opencanary/opencanary.log'
  frequency 'daily'
  rotate    10
  create    '644 root root'
end

logrotate_app 'respondered_logs' do
  path      '/var/log/opencanary/respondered.log'
  frequency 'daily'
  rotate    10
  create    '644 root root'
end

template '/etc/opencanaryd/default.json' do
  source 'opencanary/default.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


template '/etc/opencanaryd/t1000.broadcasts' do
  source 't1000.broadcasts.erb'
  owner 'root'
  group 'root'
  mode '0644'
end


cron 't1000_respondered' do
  minute '*/5'
  path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  command 'bash -c \'/bin/sleep $(expr $RANDOM \% 300)\'; /usr/bin/python /usr/local/bin/t1000.py --respondered'
end


cron 't1000_patrol' do
  minute '*/5'
  path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  command '/usr/bin/python /usr/local/bin/t1000.py --patrol --conf /etc/opencanaryd/t1000.conf'
end

if node[:t1000][:target].downcase != 'custom'


  if node[:t1000][:target].downcase == 'random_sticky':
    initial_scan_command = "/usr/bin/python /usr/local/bin/t1000.py --scan --forcerand --iface '#{node[:t1000][:mgmt][:interface]}' --target '#{node[:t1000][:target]}' --conf /etc/opencanaryd/t1000.conf"
  else
    initial_scan_command = "/usr/bin/python /usr/local/bin/t1000.py --scan --iface '#{node[:t1000][:mgmt][:interface]}' --target '#{node[:t1000][:target]}' --conf /etc/opencanaryd/t1000.conf"
  end

  template '/etc/opencanaryd/t1000.target' do
    source 't1000.target.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[scan_target]', :delayed
  end

  execute 'scan_target' do
    command initial_scan_command
    action :nothing
  end

  cron 't1000_scan' do
    minute '0'
    hour '8'
    weekday '1'
    path "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
    command "/usr/bin/python /usr/local/bin/t1000.py --scan --iface '#{node[:t1000][:mgmt][:interface]}' --target '#{node[:t1000][:target]}' --conf /etc/opencanaryd/t1000.conf"
  end
end


execute 'initial_scan_target' do
  command "/usr/bin/python /usr/local/bin/t1000.py --scan --iface '#{node[:t1000][:mgmt][:interface]}' --target '#{node[:t1000][:target]}'"
  not_if do ::File.exists?('/etc/opencanaryd/opencanary.conf') end
  action :run
end

# template '/etc/smb/smb.conf' do
#   source 'smb/smb.conf.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end


# template '/etc/syslog-ng/conf.d/smb.conf' do
#   source 'syslog-ng/smb.conf.erb'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end


