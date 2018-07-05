# Simple web server example, using ansible &containers


We will be dealing with four ssh containers:

1. <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/controller/Dockerfile">controller</a> -- ansible will be installed on this container, and it will deploy changes on all other containers
2. <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/web1/Dockerfile">loadbalancer</a> -- nginx load balancer is deployed on this container
3. <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/web1/Dockerfile">web1</a> -- apache2 is deployed on this container
4. <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/web1/Dockerfile">web2</a> -- apache 2 is deployed on this container

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

Also, make sure you modified /etc/sudoers with the necessary privileges for your user:
```
# User privilege specification
root    ALL=(ALL:ALL) ALL
tron    ALL=(ALL:ALL) ALL
```
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
<i> what a mainstream thing to do...</i>

Now that ssh is done, you need to add all the hosts under <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/files/hosts">/etc/ansible/hosts</a> under controller container, of course.
<i>Do check if python is installed on all containers (a simple "apt-get install python" will do the trick)</i>
```
root@controller:/# ansible all -m  "ping"
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
```

<b> Time to install services, apply changes...and all that jazz...</b> 

On ansible container add the following files, for further installation and configuration:

<a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/files/loadbalancer.yml">loadbalancer.yml</a> and <a href="https://raw.githubusercontent.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/master/files/webserver.yml">webserver.yml</a>

1) Install nginx on loadbalancer container (and you should see something similar):

``` 
root@controller:/# ansible-playbook loadbalancer.yml --ask-become-pass
SUDO password:  <-- you put here your user's password (in this case, tron)

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

Do a test:
```
root@controller:/# curl -v http://172.17.0.2:80
* Rebuilt URL to: http://172.17.0.3:80/
*   Trying 172.17.0.3...
* Connected to 172.17.0.3 (172.17.0.3) port 80 (#0)
> GET / HTTP/1.1
> Host: 172.17.0.3
> User-Agent: curl/7.47.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Server: nginx/1.10.3 (Ubuntu)
< Date: Tue, 03 Jul 2018 15:50:12 GMT
< Content-Type: text/html
< Content-Length: 612
< Last-Modified: Fri, 29 Jun 2018 16:16:45 GMT
< Connection: keep-alive
[ ---- snip ---- ]
< 
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
* Connection #0 to host 172.17.0.3 left intact
```

Nice! Nginx is installed and running!

<b> Onto the next one... </b>

Install apache2 on web1 and web2:

```
root@controller:/# ansible-playbook webserver.yml --ask-become-pass

SUDO password:  <-- your username's passwd again

PLAY [webserver] ******************************************************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************************************
ok: [tron@172.17.0.5]
ok: [tron@172.17.0.4]

TASK [install apache] *************************************************************************************************************************************************************************
ok: [tron@172.17.0.5]
ok: [tron@172.17.0.4]

TASK [deleted index.html] *********************************************************************************************************************************************************************
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

RUNNING HANDLER [restart apache2] *************************************************************************************************************************************************************
changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

PLAY [web1] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************************************
ok: [tron@172.17.0.4]

TASK [set up index.html for first web server] *************************************************************************************************************************************************
changed: [tron@172.17.0.4]

RUNNING HANDLER [restart apache2] *************************************************************************************************************************************************************
changed: [tron@172.17.0.4]

PLAY [web2] ***********************************************************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************************************
ok: [tron@172.17.0.5]

TASK [set up index.html for second web server] ************************************************************************************************************************************************
changed: [tron@172.17.0.5]

RUNNING HANDLER [restart apache2] *************************************************************************************************************************************************************
changed: [tron@172.17.0.5]

PLAY RECAP ************************************************************************************************************************************************************************************
tron@172.17.0.4            : ok=7    changed=4    unreachable=0    failed=0   
tron@172.17.0.5            : ok=7    changed=4    unreachable=0    failed=0   

```

... a few tests:

Check if apache is installed and up and running (it better be!):

```
root@8web1:/# /etc/init.d/apache2 status
 * apache2 is running

root@web2:/# /etc/init.d/apache2 status
 * apache2 is running
``` 
Now, let's see if there is anything on-going on port 80:
```
root@controller:/# telnet 172.17.0.5 80
Trying 172.17.0.5...
Connected to 172.17.0.5.
Escape character is '^]'.

GET /index.html
<html><header><title>moar kittens</title></header><img src="https://78.media.tumblr.com/tumblr_m6kgukHNoL1r2h6ioo1_400.gif" alt="munchkin after espresso"></html>Connection closed by foreign host.
root@controller:/# 
root@controller:/# 
root@controller:/# telnet 172.17.0.4 80
Trying 172.17.0.4...
Connected to 172.17.0.4.
Escape character is '^]'.

GET /index.html
<html><header><title>kittens</title></header><img src="https://78.media.tumblr.com/48373ffbceec2d8f73299cf13d4e70bb/tumblr_nhi2o1ab9T1u77y9bo1_250.gif" alt="munchkin"</html>Connection closed by foreign host.
root@controller:/# 

```

Wow, your browser should be populated by evil munchkins gifs, by now! 

<i>on host 172.17.0.4</i>
![ScreenShot](https://github.com/Satanette/test/blob/master/more_kittens.png)


<i>on host 172.17.0.5</i>
![ScreenShot](https://github.com/Satanette/test/blob/master/kittens.png)




Fini!

Now, go and read more about loadbalancer &mysql...<a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/loadbalancer/mysql/loadbalancer.md"> The next simple example... </a>
