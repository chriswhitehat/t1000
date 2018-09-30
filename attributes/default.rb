#########################
# Timezone
#########################
default[:t1000][:timezone] = 'UTC'

#########################
# Management Interface
#########################
default[:t1000][:mgmt][:configure] = false
default[:t1000][:mgmt][:interface] = 'eth0'
default[:t1000][:mgmt][:ipv4] = '127.0.0.1'
default[:t1000][:mgmt][:netmask] = '255.255.255.0'
default[:t1000][:mgmt][:gateway] = '127.0.0.1'
default[:t1000][:mgmt][:nameserver] = '127.0.0.1'
default[:t1000][:mgmt][:domain] = 'example.com'

##################
# Target to Impersonate
##################
default[:t1000][:target] = 'localhost'


##################
# OpenCanary Settings
##################
default[:t1000][:opencanary][:portscan][:synrate] = 5
default[:t1000][:opencanary][:logger][:file][:path] = '/var/log/opencanary.log'

##################
# FTP Pot
##################
default[:t1000][:opencanary][:ftp][:enabled] = 'false'
default[:t1000][:opencanary][:ftp][:banner] = 'FTP server ready' 
default[:t1000][:opencanary][:ftp][:port] = '21'

##################
# HTTP Pot
##################
default[:t1000][:opencanary][:http][:enabled] = 'false'
default[:t1000][:opencanary][:http][:banner] = 'Apache/2.2.22 (Ubuntu)'
default[:t1000][:opencanary][:http][:port] = '80'
default[:t1000][:opencanary][:http][:skin] = 'nasLogin'
default[:t1000][:opencanary][:http][:skins][:basicLogin][:name] = 'basicLogin'
default[:t1000][:opencanary][:http][:skins][:basicLogin][:desc] = 'Plain HTML Login'
default[:t1000][:opencanary][:http][:skins][:nasLogin][:name] = 'nasLogin'
default[:t1000][:opencanary][:http][:skins][:nasLogin][:desc] = 'Synology NAS Login'

##################
# HTTP Proxy Pot
##################
default[:t1000][:opencanary][:httpproxy][:enabled] = 'false'
default[:t1000][:opencanary][:httpproxy][:port] = '8080'
default[:t1000][:opencanary][:httpproxy][:skin] = 'squid'
default[:t1000][:opencanary][:httpproxy][:skins][:squid][:name] = 'squid'
default[:t1000][:opencanary][:httpproxy][:skins][:squid][:desc] = 'Squid'
default[:t1000][:opencanary][:httpproxy][:skins]['ms-issa'][:name] = 'ms-issa'
default[:t1000][:opencanary][:httpproxy][:skins]['ms-issa'][:desc] = 'Microsoft ISA Server Web Proxy'

##################
# SMB Pot
##################
default[:t1000][:opencanary][:smb][:enabled] = 'false'
default[:t1000][:opencanary][:smb][:configfile] = '/etc/smb/smb.conf'
default[:t1000][:opencanary][:smb][:domain] = 'corp.thinkst.com'
default[:t1000][:opencanary][:smb][:files][:file1][:name] = '2016-Tender-Summary.pdf'
default[:t1000][:opencanary][:smb][:files][:file1][:type] = 'PDF'
default[:t1000][:opencanary][:smb][:files][:file2][:name] = 'passwords.docx'
default[:t1000][:opencanary][:smb][:files][:file2][:type] = 'DOCX'
default[:t1000][:opencanary][:smb][:mode] = 'workgroup'

default[:t1000][:smb][:workgroup] = 'WORKGROUP'
default[:t1000][:smb][:server_string] = 'blah'
default[:t1000][:smb][:netbios_name] = 'SRV01'
default[:t1000][:smb][:syslog_facility] = 'local6'
default[:t1000][:smb][:syslog_path] = '/var/log/samba-audit.log'

default[:t1000][:smb][:share_name] = 'dev_share'
default[:t1000][:smb][:share_comment] = 'All the stuff!'
default[:t1000][:smb][:share_path] = '/home/canary/dev_share'


##################
# MySQL Pot
##################
default[:t1000][:opencanary][:mysql][:enabled] = 'false'
default[:t1000][:opencanary][:mysql][:banner] = '5.5.43-0ubuntu0.14.04.1'
default[:t1000][:opencanary][:mysql][:port] = '3306'


##################
# MySQL Pot
##################
default[:t1000][:opencanary][:ssh][:enabled] = 'false'
default[:t1000][:opencanary][:ssh][:version] = 'SSH-2.0-OpenSSH_5.1p1 Debian-4'
default[:t1000][:opencanary][:ssh][:port] = '22'


##################
# RDP Pot
##################
default[:t1000][:opencanary][:rdp][:enabled] = 'false'


##################
# SIP Pot
##################
default[:t1000][:opencanary][:sip][:enabled] = 'false'


##################
# snmp Pot
##################
default[:t1000][:opencanary][:snmp][:enabled] = 'false'


##################
# ntp Pot
##################
default[:t1000][:opencanary][:ntp][:enabled] = 'false'
default[:t1000][:opencanary][:ntp][:port] = '123'


##################
# tftp Pot
##################
default[:t1000][:opencanary][:tftp][:enabled] = 'false'


##################
# telnet Pot
##################
default[:t1000][:opencanary][:telnet][:enabled] = 'false'
default[:t1000][:opencanary][:telnet][:port] = '21'
default[:t1000][:opencanary][:telnet][:banner] = ''
default[:t1000][:opencanary][:telnet][:honeycreds][:admin][:username] = 'admin'
default[:t1000][:opencanary][:telnet][:honeycreds][:admin][:password] = '$pbkdf2-sha512$19000$bG1NaY3xvjdGyBlj7N37Xw$dGrmBqqWa1okTCpN3QEmeo9j5DuV2u1EuVFD8Di0GxNiM64To5O/Y66f7UASvnQr8.LCzqTm6awC8Kj/aGKvwA'
default[:t1000][:opencanary][:telnet][:honeycreds][:admin1][:username] = 'admin'
default[:t1000][:opencanary][:telnet][:honeycreds][:admin1][:password] = 'admin1'


##################
# MSSQL Pot
##################
default[:t1000][:opencanary][:mssql][:enabled] = 'false'


##################
# VNC Pot
##################
default[:t1000][:opencanary][:vnc][:enabled] = 'false'
