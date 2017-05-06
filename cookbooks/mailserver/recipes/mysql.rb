
# Install mysql and create the users

opts = node['mailserver']
create_tables = [
  "GRANT #{opts['mailuser']['grant_level']} ON #{opts['mailuser']['grant_tables']} TO '#{opts['mailuser']['name']}'@'#{opts['mailuser']['grant_host']}' IDENTIFIED BY '#{opts['mailuser']['password']}'",
  "FLUSH PRIVILEGES",
  "CREATE TABLE IF NOT EXISTS #{opts['database_name']}.virtual_domains (id int(11) NOT NULL auto_increment, name varchar(50) NOT NULL, PRIMARY KEY (id) ) ENGINE=InnoDB DEFAULT CHARSET=utf8",
  "CREATE TABLE IF NOT EXISTS #{opts['database_name']}.virtual_users (id int(11) NOT NULL auto_increment, domain_id int(11) NOT NULL, password varchar(106) NOT NULL, email varchar(100) NOT NULL, PRIMARY KEY (id), UNIQUE KEY email (email), FOREIGN KEY (domain_id) REFERENCES #{opts['database_name']}.virtual_domains(id) ON DELETE CASCADE ) ENGINE=InnoDB DEFAULT CHARSET=utf8",
  "CREATE TABLE IF NOT EXISTS #{opts['database_name']}.virtual_aliases (id int(11) NOT NULL auto_increment, domain_id int(11) NOT NULL, source varchar(100) NOT NULL, destination varchar(100) NOT NULL, PRIMARY KEY (id), FOREIGN KEY (domain_id) REFERENCES #{opts['database_name']}.virtual_domains(id) ON DELETE CASCADE ) ENGINE=InnoDB DEFAULT CHARSET=utf8"
]

execute 'create db' do 
  command "mysql -e 'CREATE DATABASE IF NOT EXISTS #{node['mailserver']['database_name']}'"
end

create_tables.each do |query|
  bash 'create table if it does not exist in mysql' do
    code <<-EOH
      mysql -e "#{query}"
      EOH
  end
end

opts['virtual_domains'].each do |domain|
  bash 'insert domains' do
    code <<-EOH
      d_id=$(mysql -Ne "SELECT id FROM #{node['mailserver']['database_name']}.virtual_domains WHERE name = '#{domain}'")
      if ! [[ "$d_id" =~ '^[0-9]+$' ]]; then
        mysql -e "INSERT INTO #{node['mailserver']['database_name']}.virtual_domains (name) VALUES ('#{domain}')"
      fi
      EOH
  end
end

opts['virtual_users'].each do |user|
  bash 'insert users' do
    code <<-EOH
      DOMAINIDS=$(mysql -Ne "SELECT id FROM #{node['mailserver']['database_name']}.virtual_domains WHERE name = '#{user['domain']}'")
      for d_id in $DOMAINIDS
        do mysql -e "INSERT INTO #{node['mailserver']['database_name']}.virtual_users (domain_id, password , email) VALUES ('$d_id', '#{user['password']}', '#{user['email']}')"
      done
      EOH
  end
end
