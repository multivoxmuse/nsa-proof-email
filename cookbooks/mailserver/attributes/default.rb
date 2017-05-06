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
mysql/attributes/default.rb
