

<b>Next...</b>

On the two web servers (172.17.0.4, and 172.17.0.5), let's install mysql, using the <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/loadbalancer/mysql/mysql.yml">mysql.yml</a> configuration file:

```
root@controller:~/mysql# ansible-playbook mysql.yml --ask-become-pass
SUDO password: 


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
mysql> SHOW VARIABLES WHERE Variable_name = 'hostname';
+---------------+--------------+
| Variable_name | Value        |
+---------------+--------------+
| hostname      |  web1        |
+---------------+--------------+
1 row in set (0.00 sec)


```
[on container web2] 

```
root@web2:/# mysql -u root --password=abc123

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
mysql> SHOW VARIABLES WHERE Variable_name = 'hostname';
+---------------+--------------+
| Variable_name | Value        |
+---------------+--------------+
| hostname      |  web2        |
+---------------+--------------+
1 row in set (0.00 sec)
```

Hosts that are allowed to Mysql:

```
mysql>use mysql;
mysql> select Host from user;
+------------+
| Host       |
+------------+
| 172.17.0.2 |
| 172.17.0.3 |
| 172.17.0.4 |
| 172.17.0.5 |
| localhost  |
| localhost  |
| localhost  |
| localhost  |
+------------+
```
Grant privilege is terrible these days, so I simply took the easiest approach:

For example:
```
mysql> use mysql;
mysql> insert into user(Host, User, ssl_cipher, x509_issuer, x509_subject)  values ('172.17.0.2', 'root', 'non-null','non-null','non-null');
Query OK, 1 row affected (0.00 sec)
```


Modify /etc/mysql/my.cnf and make mysql available to all containers:

```
[mysqld]
bind-address=0.0.0.0
```

<i><b>Possible fix (for this tutorial, at least)</i></b>

```

mysql> 
mysql> SELECT host,user,Grant_priv,Super_priv FROM mysql.user where user="root";
+--------------+------+------------+------------+
| host         | user | Grant_priv | Super_priv |
+--------------+------+------------+------------+
| localhost    | root | N          | Y          |
| web1         | root | Y          | Y          |
| 172.17.0.2   | root | N          | N          |
| 172.17.0.3   | root | N          | N          |
| 172.17.0.4   | root | N          | N          |
| 172.17.0.5   | root | N          | N          |
+--------------+------+------------+------------+
6 rows in set (0.00 sec)


mysql> UPDATE mysql.user SET Grant_priv='Y', Super_priv='Y' WHERE User='root';
Query OK, 5 rows affected (0.00 sec)
Rows matched: 6  Changed: 5  Warnings: 0

mysql> SELECT host,user,Grant_priv,Super_priv FROM mysql.user where user="root";
+--------------+------+------------+------------+
| host         | user | Grant_priv | Super_priv |
+--------------+------+------------+------------+
| localhost    | root | Y          | Y          |
| web1         | root | Y          | Y          |
| 172.17.0.2   | root | Y          | Y          |
| 172.17.0.3   | root | Y          | Y          |
| 172.17.0.4   | root | Y          | Y          |
| 172.17.0.5   | root | Y          | Y          |
+--------------+------+------------+------------+
6 rows in set (0.00 sec)

mysql>
```


<b> Loadbalancing with Nginx </b>


Back to loadbalancer container 172.17.0.3, since nginx is running on this container -  we will make it loadbalancer for our mysql (the old web) containers:

Create a <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/loadbalancer/mysql/balance_stream.conf">stream</a> block by modifying file /etc/nginx/nginx.conf accordingly:

```
stream {
      upstream dba {
        server 172.17.0.4:3306;
        server 172.17.0.5:3306;
        zone tcp_mem 64k;
        least_conn;
    }
 
    server {
        listen 3306;
        proxy_pass dba;
        proxy_connect_timeout 1s;
    }
}

http{
  ...
}

include /etc/nginx/conf.d/*.conf;  <-- this include must be out of http block
 
```

Restart nginx:
```
/etc/init.d/nginx restart
```

...and check if anything listens on port 3306:

```
root@loadbalancer:/etc/nginx/conf.d# netstat -tenpula | grep :3306
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      0          665412      3093/nginx      
root@loadbalancer:/etc/nginx/conf.d# 
```

fini!

Now, go to the <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/replication/replication.md"> The next simple example for Mysql replication with ProxySQL </a>
