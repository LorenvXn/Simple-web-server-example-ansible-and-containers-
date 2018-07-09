
<b> Next... </b>


<i><b>Mysql replication with ProxySQL</b></i>


We will be using loadbalancer container, and webserver containers on which 
we have installed MySQL, web1 &web2:

```
root@controller:~#  ansible loadbalancer --list-hosts
  hosts (1):
    tron@172.17.0.3
root@controller:~#  ansible webserver --list-hosts
  hosts (2):
    tron@172.17.0.4
    tron@172.17.0.5
```


ProxySQL will be installed on loadbalancer, web1 will be the master, and web2 the slave.


<b>1) ProxySQL on loadbalancer (172.17.0.3) container </b>

<i> MySQL must be installed on this one as well...</i>

Ansible playbook for ProxySQL and Mysql configuration on 172.17.0.3:

```
 - hosts: loadbalancer
   become: true
   vars:
     packages: proxysql_1.4.9-ubuntu16_amd64.deb
     mysql_password: abc123
     
   tasks:
    - name: Download proxysql
      get_url:
        url: https://github.com/sysown/proxysql/releases/download/v1.4.9/{{ packages }}
        dest: /tmp

    - name: Install proxysql
      command: dpkg -i /tmp/{{ packages }}

    - name: Start proxysql
      service:
        name: proxysql
        state: started

    - name: install mysql
      apt: name={{ item }} update_cache=yes cache_valid_time=3600 state=present
      with_items:
      - python-mysqldb
      - mysql-server

    - name: start mysql
      service:
        name: mysql
        state: started

    - name: root user mysql
      command: mysql -e "alter user root@localhost identified by '{{ mysql_password }}';"
      
    - name: grant privileges
      command: mysql -u root -e "grant all on *.* to root@localhost;" --password={{ mysql_password }}

```

And Play it...
```
root@controller:~# ansible-playbook proxy.yml --ask-become-pass
SUDO password: 

PLAY [loadbalancer] *****************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [Install wget package (Debian based)] ******************************************************************************************
ok: [tron@172.17.0.3]

TASK [Download proxy] ***************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [Install proxysql] *************************************************************************************************************
changed: [tron@172.17.0.3]

TASK [Start proxysql] ***************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [install mysql] ****************************************************************************************************************
ok: [tron@172.17.0.3] => (item=[u'python-mysqldb', u'mysql-server'])

TASK [Start mysql] ******************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [update mysql] *****************************************************************************************************************
changed: [tron@172.17.0.3]

TASK [grant privileges] *************************************************************************************************************
changed: [tron@172.17.0.3]

PLAY RECAP **************************************************************************************************************************
tron@172.17.0.3            : ok=8    changed=2    unreachable=0    failed=0   
```

Check if everything is ok on container "loadbalancer"

```
root@loadbalancer:/tmp# lsof -i :6032
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
proxysql 2054 root   23u  IPv4 579017      0t0  TCP *:6032 (LISTEN)

root@loadbalancer:/tmp# ss -l | grep my
u_str  LISTEN     0      80     /var/run/mysqld/mysqld.sock 630510                * 0                    
tcp    LISTEN     0      80      *:mysql                 *:*                    
```

<b><i>Master-slave replication</b></i>

1. Create an application user, and a monitoring user on all three containers, using below Playbook:
 <i> ( same mysql password for every user...)</i> :
  
 ```
root@controller:~# more mass.yml 
 - hosts: loadbalancer, webserver
   become: true
   vars:
     packages: proxysql_1.4.9-ubuntu16_amd64.deb
     mysql_password: abc123
     mysql_user: root
     sysbench: tronsysbench
     monitor: tronmonitor

   tasks:
    - name: create user sysbench
      command: mysql -u {{ mysql_user }} -e "create user {{ sysbench }} identified by '{{mysql_password}}';" --password={{ mysql_password}}

    - name: grant privilege to sysbench
      command: mysql -u {{ mysql_user }} -e "grant all privileges on *.* to '{{ sysbench }}'@'172.17.0.%' identified by '{{ mysql_password }}';" --password={{ mysql_password}}

    - name: create user sysbench
      command: mysql -u {{ mysql_user }} -e "create user {{ monitor }} identified by '{{mysql_password}}';" --password={{ mysql_password}}

    - name: grant privilege to sysbench
      command: mysql -u {{ mysql_user }} -e "grant all privileges on *.* to '{{ monitor  }}'@'172.17.0.%' identified by '{{ mysql_password }}';" --password={{ mysql_password}}

```
  
...and Play it:
```
root@controller:~# ansible-playbook master_slave.yml --ask-become-pass
SUDO password: 

SUDO password: 

PLAY [loadbalancer, webserver] ******************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [tron@172.17.0.3]
ok: [tron@172.17.0.4]
ok: [tron@172.17.0.5]

TASK [create user sysbench] *********************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [grant privilege to sysbench] **************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [create user monitor] *********************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [grant privilege to monitor] **************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

PLAY RECAP **************************************************************************************************************************
tron@172.17.0.3            : ok=5    changed=4    unreachable=0    failed=0   
tron@172.17.0.4            : ok=5    changed=4    unreachable=0    failed=0   
tron@172.17.0.5            : ok=5    changed=4    unreachable=0    failed=0   



```

2). Connect as ProxySQL admin and start configuration of container 172.17.0.3 (loadbalancer), by using following 
Playbook:

```
 - hosts: loadbalancer
   become: true
   vars:
     proxy_passwd: admin
     proxy_user: admin

   tasks:
    - name: set master
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "insert into mysql_servers(hostgroup_id,hostname,port) VALUES (0,'172.17.0.4',3306);" --password={{ proxy_passwd }}

    - name: set slave
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "insert into mysql_servers(hostgroup_id,hostname,port) VALUES (1,'172.17.0.5',3306);" --password={{ proxy_passwd }}

    - name: load mysql servers
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "load mysql servers to runtime;"  --password={{ proxy_passwd }}

    - name: save configuration
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "save mysql servers to disk;" --password={{ proxy_passwd }}

```
Play...
```
root@controller:~# ansible-playbook config.yml --ask-become-pass
SUDO password: 

PLAY [loadbalancer] ***************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [set master] *****************************************************************************************************************
changed: [tron@172.17.0.3]

TASK [set slave] ******************************************************************************************************************
changed: [tron@172.17.0.3]

TASK [load mysql servers] *********************************************************************************************************
changed: [tron@172.17.0.3]

TASK [save configuration] *********************************************************************************************************
changed: [tron@172.17.0.3]

PLAY RECAP ************************************************************************************************************************
tron@172.17.0.3            : ok=5    changed=4    unreachable=0    failed=0   

```

...and do a check:

```
root@controller:/tmp# mysql -u admin  -h 127.0.0.1 -P6032 -e "SELECT hostgroup_id,hostname,port,status,weight FROM mysql_servers;" --password=admin
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------+------------+------+--------+--------+
| hostgroup_id | hostname   | port | status | weight |
+--------------+------------+------+--------+--------+
| 0            | 172.17.0.4 | 3306 | ONLINE | 1      |
| 1            | 172.17.0.5 | 3306 | ONLINE | 1      |
+--------------+------------+------+--------+--------+
root@controller:/tmp# 
root@controller:/tmp# mysql -u admin  -h 127.0.0.1 -P6032 -e "insert into mysql_replication_hostgroups VALUES (0,1,'whoaa');;" --password=admin
mysql: [Warning] Using a password on the command line interface can be insecure.
root@controller:/tmp#
root@controller::/tmp# mysql -u admin  -h 127.0.0.1 -P6032 -e "select *  from mysql_replication_hostgroups;" --password=adminmysql: [Warning] Using a password on the command line interface can be insecure.
+------------------+------------------+---------+
| writer_hostgroup | reader_hostgroup | comment |
+------------------+------------------+---------+
| 0                | 1                | whoaa   |
+------------------+------------------+---------+
```
<b> Configure users </b>

```
root@controller:~# more user_conf.yml 
 - hosts: loadbalancer
   become: true
   vars:
     proxy_passwd: admin
     proxy_user: admin
     sysbench: tronsysbench
     monitor: tronmonitor

   tasks:
    - name: monitor user setup
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "update global_variables set variable_value='monitor' where variable
_name='mysql-monitor_password';"  --password={{ proxy_passwd }}
     
    - name: load mysql servers
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "load mysql servers to runtime;"  --password={{ proxy_passwd }}

    - name: save configuration
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "save mysql servers to disk;" --password={{ proxy_passwd }}

    - name: configure sysbench
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "insert into mysql_users(username,password,default_hostgroup) values 
(\"{{ sysbench }}\",\"{{ sysbench }}\",1);" --password={{ proxy_passwd }} 

    - name: load mysql servers
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "load mysql servers to runtime;"  --password={{ proxy_passwd }}

    - name: save configuration
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "save mysql servers to disk;" --password={{ proxy_passwd }}

```

Perform checking on loadbalancer:

```
root@loadbalancer:/tmp# mysql -u admin  -h 127.0.0.1 -P6032 -e "select username,password,active,default_hostgroup,default_schema,max_connections,max_connections FROM mysql_users; " --password=admin
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------+--------------+--------+-------------------+----------------+-----------------+-----------------+
| username     | password     | active | default_hostgroup | default_schema | max_connections | max_connections |
+--------------+--------------+--------+-------------------+----------------+-----------------+-----------------+
| tronsysbench | tronsysbench | 1      | 1                 | NULL           | 10000           | 10000           |
+--------------+--------------+--------+-------------------+----------------+-----------------+-----------------+
root@loadbalancer:/tmp# 
```
<b> Configure monitoring... </b>
```
root@controller:~# more monitoring.yml 
 - hosts: loadbalancer
   become: true
   vars:
     proxy_passwd: admin
     proxy_user: admin
     sysbench: tronsysbench
     monitor: tronmonitor

   tasks:
    - name: monitor user setup
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e " update global_variables set variable_value=2000 where variable_nam
e IN ('mysql-monitor_connect_interval','mysql-monitor_ping_interval','mysql-monitor_read_only_interval');"  --password={{ proxy_passw
d }}
     
    - name: configure interval variable
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "update global_variables set variable_value = 1000 where variable_na
me = 'mysql-monitor_connect_timeout';"  --password={{ proxy_passwd }}

    - name: configure ping timeout
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "update global_variables set variable_value = 500 where variable_nam
e = 'mysql-monitor_ping_timeout';"  --password={{ proxy_passwd }}

    - name: load mysql servers
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "load mysql servers to runtime;"  --password={{ proxy_passwd }}

    - name: save configuration
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "save mysql servers to disk;" --password={{ proxy_passwd }}

```

<b> Configure query rules </b>
```
root@e647cc8515dd:~# more queries.yml 
 - hosts: loadbalancer
   become: true
   vars:
     proxy_passwd: admin
     proxy_user: admin
     sysbench: tronsysbench
     monitor: tronmonitor

   tasks:
    - name: monitor user setup
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "INSERT INTO mysql_query_rules (active, match_digest, destination_
hostgroup, apply) VALUES (1, '^SELECT.*', 1, 0);"  --password={{ proxy_passwd }}
     
    - name: configure interval variable
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "INSERT INTO mysql_query_rules (active, match_digest, destination_
hostgroup, apply) VALUES (1, '^SELECT.*FOR UPDATE', 0, 1);"  --password={{ proxy_passwd }}

    - name: load mysql servers
      command: mysql -u {{ proxy_user }}  -h 127.0.0.1 -P6032 -e "load mysql servers to runtime;"  --password={{ proxy_passwd }}

    - name: save configuration
      command: mysql -u {{ proxy_user }} -h 127.0.0.1 -P6032 -e "save mysql servers to disk;" --password={{ proxy_passwd }}

```

Implement checking:


```
root@loadbalancerr:/tmp# mysql -u admin  -h 127.0.0.1 -P6032 -e "SELECT rule_id, match_digest,destination_hostgroup hg_id, apply FROM mysql_query_rules WHERE active=1;" --password=admin
mysql: [Warning] Using a password on the command line interface can be insecure.
+---------+---------------------+-------+-------+
| rule_id | match_digest        | hg_id | apply |
+---------+---------------------+-------+-------+
| 1       | ^SELECT.*           | 1     | 0     |
| 2       | ^SELECT.*FOR UPDATE | 0     | 1     |
+---------+---------------------+-------+-------+
```

<b> Check connection </b>
```
root@loadbalancer:/tmp# mysql -u admin -p -h 127.0.0.1 -P6032 -e "Select * from monitor.mysql_server_ping_log order by time_start_us desc limit 3;"
Enter password: 
+------------+------+------------------+----------------------+------------+
| hostname   | port | time_start_us    | ping_success_time_us | ping_error |
+------------+------+------------------+----------------------+------------+
| 172.17.0.5 | 3306 | 1530929811738058 | 424                  | NULL       |
| 172.17.0.4 | 3306 | 1530929811735853 | 733                  | NULL       |
| 172.17.0.5 | 3306 | 1530929809736067 | 186                  | NULL       |
+------------+------+------------------+----------------------+------------+```
```
Checking on containers:
```
root@loadbalancer:/tmp# mysql -u tronsysbench -pabc123 -h 172.17.0.5 -P 3306 -e "create database ahaaa;"
mysql: [Warning] Using a password on the command line interface can be insecure.
root@loadbalancer:/tmp#
root@loadbalancer:/tmp# mysql -u tronsysbench -pabc123 -h 172.17.0.5 -P 3306 -e "show databases;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+--------------------+
| Database           |
+--------------------+
| information_schema |
| ahaaa              |
| mysql              |
| performance_schema |
| pfehehehe          |
| sys                |
+--------------------+

```
<i> ... in progress </i>

For now, check how to gather munchkin links using <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Set-up_Java_and_others/Crawler.md">the web crawler (root dba user)</a>
