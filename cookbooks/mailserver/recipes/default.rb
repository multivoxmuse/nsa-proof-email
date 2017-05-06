# Install package dependencies
package node['mailserver']['packages'] do
  action :upgrade
end

# This will give you a string like {SHA512-CRYPT}$6$gJ8hXjMn/lePALEt$JMX1jd... 
# The part after “{SHA512-CRYPT}” is the hash for your password. 
# It always starts with “$6$”.
execute 'create dovecot admin password' do
  command "doveadm pw -s SHA512-CRYPT | awk -F'}' '{ print $2}' > /tmp/doveadmpw"
end