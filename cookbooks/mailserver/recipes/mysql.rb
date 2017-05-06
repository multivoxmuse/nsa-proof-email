
opts = node['mysql']
create_tables = [
  "GRANT #{opts['grant_level']} ON #{opts['grant_tables']} TO '#{opts['mailuser']['name']}'@'#{opts['grant_host']}' IDENTIFIED BY '#{opts['mailuser']['password']}'",
  "FLUSH PRIVILEGES",
  "CREATE TABLE IF NOT EXISTS `virtual_domains` (`id` int(11) NOT NULL auto_increment, `name` varchar(50) NOT NULL, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8",
  "CREATE TABLE IF NOT EXISTS `virtual_users` (`id` int(11) NOT NULL auto_increment, `domain_id` int(11) NOT NULL, `password` varchar(106) NOT NULL, `email` varchar(100) NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `email` (`email`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE ) ENGINE=InnoDB DEFAULT CHARSET=utf8",
  "CREATE TABLE IF NOT EXISTS `virtual_aliases` (`id` int(11) NOT NULL auto_increment, `domain_id` int(11) NOT NULL, `source` varchar(100) NOT NULL, `destination` varchar(100) NOT NULL, PRIMARY KEY (`id`), FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE ) ENGINE=InnoDB DEFAULT CHARSET=utf8"
]

execute 'create db' do 
  command "mysql -e 'CREATE #{node['mysql']['database_name']} IF NOT EXISTS'"
end

create_tables.each do |query|
  bash 'create table if it does not exist in mysql'
    code <<-EOH
      mysql -e "#{query}"
      EOH
  end
end

opts['virtual_domains'].each do |domain|
  bash 'insert domains' do
    code <<-EOH
      mysql -e "INSERT INTO `#{node['mysql']['database_name']}`.`virtual_domains` (`name`) VALUES ('#{domain}')"
      EOH
  end
end

opts['virtual_users'].each do |user|
  bash 'insert users' do
    code <<-EOH
      DOMAINID=$(mysql -e "SELECT id FROM #{node['mysql']['database_name']}.virtual_domains WHERE name = '#{user['domain'}'"
      mysql -e "INSERT INTO `#{node['mysql']['database_name']}`.`virtual_users` (`domain_id`, `password` , `email`) VALUES ('$DOMAINID', '#{user['password'}', '#{user['email']}')"
      EOH
  end
end
