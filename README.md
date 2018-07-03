# Simple web server example, using ansible &containers


We will be dealing with four ssh containers:

1. controller -- ansible will be installed on this container, and it will deploy changes on all other containers
2. loadbalancer -- nginx load balancer is deployed on this container
3. web1  -- apache2 is deployed on this container
4. web2  -- apache 2 is deployed on this container

<i> For better vizualization purposes </i>

```

+-----------+           +------------+           +-----------+ 
|   web1    |<--------->|loadbalancer|<--------->|   web2    |
+-----------+           +------------+           +-----------+ 
      ⌃                       ⌃                        ⌃
      |                       |                        | 
      |                       |                        |
      |                       |                        |
      ---------------------- \|/------------------------     
                              |
                              |
                        +-------------+
                        |  controller |
                        +-------------+
```

I do recommend not to waste your time with web2 creation if using same Dockerfile as web1.
It's simpler if you use "docker commit" - it will create a clone of web1:

Let us suppose 17s4b4d1d34 is the container ID of web1 container:

```
root@tr0n:/# docker commit 17s4b4d1d34
sha256:i3s17sv3r1b4d1d342c99792c99791379ecaa12c67379ecaa12c671c1379ecaa12c67
root@tr0n:/# 
root@tr0n:/#docker run --name=kek -ti i3s17sv3r1b4d /bin/bash
root@y3s17s4v3r1b4d#
```

After creating the four ssh containers
create new user to allow  ssh between containers.

<i>Some of you might want to automate this task, then again, 
containers are shady &can &will mess up configuration files, even if you are a regex overlord.
A bit of practice never hurts.</i>

Small example how to create user (in my case "tron"), on <b>web1 container</b> (do the same for all other 3). </br>
```
root@controller:/# ssh-keygen -t rsa 
[keep pressing enter until you see the stars!]

root@web1:/# useradd tron
root@web1:/# passwd tron
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
root@web1:/#
root@web1:/# mkdir -p /home/tron
root@web1:/#
root@web1:/# chown tron:tron /home/tron
root@web1:/#
root@web1:/#  more /etc/passwd |grep tron
tron:x:1000:1000::/home/tron:
root@web1:/#
root@web1:/# ls ~/.ssh  
id_rsa  id_rsa.pub  known_hosts
root@web1:/#
root@web1:/# cat ~/.ssh/id_rsa.pub | ssh tron@localhost 'cat >> ~/.ssh/authorized_keys'
tron@localhost's password: 
sh: 1: cannot create /home/tron/.ssh/authorized_keys: Directory nonexistent
root@web1:/#
root@web1:/# ssh tron@localhost
tron@localhost's password: 
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.13.0-45-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Fri Jun 29 14:51:21 2018 from ::1
$ pwd      
/home/tron
$ mkdir -p .ssh
$ exit
Connection to localhost closed.
root@web1:/# cat ~/.ssh/id_rsa.pub | ssh tron@localhost 'cat >> ~/.ssh/authorized_keys'
tron@localhost's password: 
root@web1:/# 
root@web1:/# 
root@web1:/# ssh tron@localhost
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.13.0-45-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Fri Jun 29 14:53:19 2018 from ::1
$ exit
Connection to localhost closed.
```

But first, do yourselves a favor, and restart ssh service on every container:

```/etc/init.d/ssh restart```

Controller container must have ssh access without password requirement on all other 3 containers (loadbalancer, web1, web2).

Example how to offer access on  web1 [IP 172.17.0.4]  (do the same for web2, loadbalancer):


```
root@controller:/# ssh-copy-id tron@172.17.0.4
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
tron@172.17.0.4's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'tron@172.17.0.4'"
and check to make sure that only the key(s) you wanted were added.

```

<i>...or easier: just log in to 172.17.0.4 and simply add  the controller's  key under  /home/tron/.ssh/id_rsa.pub</i>


Do a test:

```

root@controller:/#
root@controller:/# hostname -I                         
172.17.0.2 
root@controller:/# 
root@controller:/# 
root@controller:/# ssh tron@172.17.0.4
Welcome to Ubuntu 16.04.4 LTS (GNU/Linux 4.15.0-24-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Tue Jul  3 14:59:52 2018 from 172.17.0.2
$ 
$ hostname -I
172.17.0.4 
$ id
uid=1000(tron) gid=1000(tron) groups=1000(tron)
$ 
```



<b> Ping'em all! </b>

Now that ssh is done, you need to add all the hosts under ```/etc/ansible/hosts``` under controller container, of course.


root@6dc25308106e:/# ansible all -m  "ping"
tron@172.17.0.5 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
tron@172.17.0.3 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
control | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
tron@172.17.0.4 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}


<b> Time to install services, apply changes...and all that jazz...</b> 

1) Install nginx on loadbalancer container:

``` root@controller:/# ansible-playbook loadbalancer.yml --ask-become-pass
SUDO password: 

PLAY [loadbalancer] ***************************************************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [user] ***********************************************************************************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [install nginx] **************************************************************************************************************************************************************************
ok: [tron@172.17.0.3]

TASK [start nginx] ****************************************************************************************************************************************************************************
ok: [tron@172.17.0.3]

PLAY RECAP ************************************************************************************************************************************************************************************
tron@172.17.0.3            : ok=4    changed=0    unreachable=0    failed=0   

root@controller:/# 
```

