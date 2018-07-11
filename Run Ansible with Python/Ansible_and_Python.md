


<b> Small example on how ansible playbook can be run using Python </b>

Perform a simple installation of pip3 and vim on webserver containers

```
root@controller:~#  ansible webserver --list-hosts
  hosts (2):
    tron@172.17.0.4
    tron@172.17.0.5
```
Our playbook:
```
root@controller:/test# more install_stuff.yml 
 - hosts: webserver
   become: true

   tasks:

    - name: install vim, pip3
      apt:
        name: "{{ packages }}"
        state: present
      vars:
        packages:
        - vim
        - python3-pip
```

Provide the necessary arguments (path of ansible hosts file, and path of playbook),
and run the <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Run%20Ansible%20with%20Python/example.py">example.py</a> code as following:




```
root@controller:/# python example.py "/etc/ansible/hosts" "/test/install_stuff"

PLAY [webserver] *******************************************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************************************
ok: [tron@172.17.0.4]
ok: [tron@172.17.0.5]

TASK [install vim, pip3] ***********************************************************************************************************************************************************************************
ok: [tron@172.17.0.4]
ok: [tron@172.17.0.5]

PLAY RECAP *************************************************************************************************************************************************************************************************
tron@172.17.0.4            : ok=2    changed=0    unreachable=0    failed=0   
tron@172.17.0.5            : ok=2    changed=0    unreachable=0    failed=0   

```


Fini!
