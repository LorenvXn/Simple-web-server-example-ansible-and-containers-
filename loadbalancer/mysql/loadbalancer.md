

<b>Next...</b>

On the 2 web servers, let's install mysql, using the mysql.yml configuration file:

```
root@controller:~/mysql# ansible-playbook mysql.yml --ask-become-pass
SUDO password: 
 [WARNING]: Ignoring invalid attribute: sudo


PLAY [webserver] ********************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [tron@172.17.0.5]
ok: [tron@172.17.0.4]

TASK [install mysql] ****************************************************************************************************************
ok: [tron@172.17.0.4] => (item=[u'python-mysqldb', u'mysql-server'])
ok: [tron@172.17.0.5] => (item=[u'python-mysqldb', u'mysql-server'])

TASK [start mysql] ******************************************************************************************************************
 [WARNING]: Consider using the service module rather than running service.  If you need to use command because service is
insufficient you can add warn=False to this command task or set command_warnings=False in ansible.cfg to get rid of this message.

changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [update mysql] *****************************************************************************************************************
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

PLAY RECAP **************************************************************************************************************************
tron@172.17.0.4            : ok=4    changed=2    unreachable=0    failed=0   
tron@172.17.0.5            : ok=4    changed=2    unreachable=0    failed=0   
```

Let's check if everything looks alright:

[on container web1]
```
root@web1:/# mysql -u root --password=abc123

[---------------snip---------------]

mysql> show grants for 'root'@'localhost';
+--------------------------------------------------------------+
| Grants for root@localhost                                    |
+--------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost'            |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION |
+--------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> 
```
[on container web2] 

```
rootweb2:/# mysql -u root --password=abc123

[---------------snip---------------]

mysql> show grants for 'root'@'localhost';
+--------------------------------------------------------------+
| Grants for root@localhost                                    |
+--------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost'            |
| GRANT PROXY ON ''@'' TO 'root'@'localhost' WITH GRANT OPTION |
+--------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> 
```


