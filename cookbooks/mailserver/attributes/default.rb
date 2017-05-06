# package dependencies
default['mailserver']['packages'] = [ 
	"postfix", 
	"postfix-mysql", 
	"dovecot-core", 
	"dovecot-imapd", 
	"dovecot-mysql", 
	"mysql-server", 
	"dovecot-lmtpd"
]
default['mailserver']['database_name'] = 'mailserver'
default['mailserver']['mailuser'] = {
  "name" => "mailuser",
  "grant_level" => "SELECT",
  "grant_tables" => "mailserver.*",
  "grant_host" => "127.0.0.1"
}

