# mysql

The following attributes must be supplied

`node['mysql']['virtual_domains']` : The domain your mailserver responds to and mysql will store.
`node['mysql']['mailuser']['password']` : The password postfix will use to authenticate to mysql.

### Example:

```json
{
  "mysql" : {
    "virtual_domains" : ["example.com"],
    "virtual_users" : [
      {
        "email" : "bob@example.com",
        "domain" : "example.com",
        "password" : "ojwfljsfjafpuqr"
      }
    ]
  }
}
```