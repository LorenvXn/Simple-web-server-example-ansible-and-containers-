
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
      command: mysql -u {{ mysql_user }} -e "create user {{ sysbench }} identified by '{{mysql_password}}';" --password={{ mysql_pass
word}}
    - name: grant privilege to sysbench
      command: mysql -u {{ mysql_user }} -e "grant all privileges on *.* to '{{ sysbench }}'@'172.17.0.%' identified by '{{ mysql_pas
sword }}';" --password={{ mysql_password}}
```
  
...and Play it:
```
root@controller:~# ansible-playbook master_slave.yml --ask-become-pass
SUDO password: 

PLAY [loadbalancer, webserver] ******************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************
ok: [tron@172.17.0.5]
ok: [tron@172.17.0.4]
ok: [tron@172.17.0.3]

TASK [create user sysbench] *********************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [grant privilege to sysbench] **************************************************************************************************
changed: [tron@172.17.0.3]
changed: [tron@172.17.0.5]
changed: [tron@172.17.0.4]

PLAY RECAP **************************************************************************************************************************
tron@172.17.0.3            : ok=3    changed=2    unreachable=0    failed=0   
tron@172.17.0.4            : ok=3    changed=2    unreachable=0    failed=0   
tron@172.17.0.5            : ok=3    changed=2    unreachable=0    failed=0   


```
