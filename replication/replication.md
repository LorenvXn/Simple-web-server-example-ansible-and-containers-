
<b> Next... </b>

<i><b>Mysql replication with ProxySQL</b></i>


We will be using loadbalancer container (172.17.0.3), and webserver containers on which 
we have installed MySQL (web1 - 172.17.0.4, and web2 - 172.17.0.5).


ProxySQL will be installed on loadbalancer, web1 will be the master, and web2 the slave.


<b>1) ProxySQL on loadbalancer (172.17.0.2) container </b>

<i> MySQL must be installed on this one as well...</i>

Ansible playbook for ProxySQL and Mysql configuration on 172.17.0.2:

```
 - hosts: loadbalancer
   become: true
   vars:
     packages: proxysql_1.4.9-ubuntu16_amd64.deb
     mysql_password: abc123

   tasks:
    - name: Install wget package (Debian based)
      action: apt pkg='wget' state=present

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
      command: mysql -e "alter user root@localhost identified by 'mysql_password';"
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

PLAY RECAP **************************************************************************************************************************
tron@172.17.0.3            : ok=8    changed=2    unreachable=0    failed=0   
```

Check if everything ok on container "loadbalancer"

```
root@loadbalancer:/tmp# lsof -i :6032
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
proxysql 2054 root   23u  IPv4 579017      0t0  TCP *:6032 (LISTEN)

root@loadbalancer:/tmp# ss -l | grep my
u_str  LISTEN     0      80     /var/run/mysqld/mysqld.sock 630510                * 0                    
tcp    LISTEN     0      80      *:mysql                 *:*                    
```


