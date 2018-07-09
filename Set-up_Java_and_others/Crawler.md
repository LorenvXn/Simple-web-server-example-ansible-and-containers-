
<b> Next... </b>

1. Install & set-up Java environment on web1 and web2 containers, using <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Set-up_Java_and_others/java_play.yml">java_play.yml</a> to install java:



2. Install & set-up Maven environment on web1 and web2 containers, using <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Set-up_Java_and_others/maven_play.yml">maven_play.yml</a>.

[output for maven installation]
```
root@controller:/# ansible-playbook maven_play.yml --ask-become-pass  
SUDO password: 

PLAY [webserver] *******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [tron@172.17.0.5]
ok: [tron@172.17.0.4]

TASK [Download maven] **************************************************************************************************************************************************************************************
 [WARNING]: Consider using the get_url or uri module rather than running wget.  If you need to use command because get_url or uri is insufficient you can add warn=False to this command task or set
command_warnings=False in ansible.cfg to get rid of this message.

changed: [tron@172.17.0.5]
changed: [tron@172.17.0.4]

TASK [Extract maven] ***************************************************************************************************************************************************************************************
changed: [tron@172.17.0.5]
changed: [tron@172.17.0.4]

TASK [Extract maven II] ************************************************************************************************************************************************************************************
 [WARNING]: Consider using the file module with state=link rather than running ln.  If you need to use command because file is insufficient you can add warn=False to this command task or set
command_warnings=False in ansible.cfg to get rid of this message.

changed: [tron@172.17.0.4]
changed: [tron@172.17.0.5]

TASK [Maven home] ******************************************************************************************************************************************************************************************
changed: [tron@172.17.0.5]
changed: [tron@172.17.0.4]

TASK [Maven home II] ***************************************************************************************************************************************************************************************
changed: [tron@172.17.0.5]
changed: [tron@172.17.0.4]

PLAY RECAP *************************************************************************************************************************************************************************************************
tron@172.17.0.4            : ok=6    changed=5    unreachable=0    failed=0   
tron@172.17.0.5            : ok=6    changed=5    unreachable=0    failed=0  
```

Checking done on web1 container:

```
root@web1:/opt# echo $JAVA_HOME
/opt/jdk1.8.0_171
root@web1:/opt# echo $M2_HOME  
/usr/local/maven
root@web1:/opt# 
root@web1:/opt# mvn -version
Apache Maven 3.5.4 (1xxx; 2018-06-17T18:33:14Z)
Maven home: /usr/local/maven
Java version: 1.8.0_171, vendor: Oracle Corporation, runtime: /opt/jdk1.8.0_171/jre
Default locale: en_US, platform encoding: ANSI_X3.4-1968
OS name: "linux", version: "4.15.0-24-generic", arch: "amd64", family: "unix"

```
