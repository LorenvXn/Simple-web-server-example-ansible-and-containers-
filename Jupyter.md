
<b> Next... </b>

Deploy iPython notebooks using the ansible playbook <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/blob/master/Jupyter/jupyter.yml"> jupyter.yml</a>



After installation, run as root user, let's say on on web2 :

```
root@web2:~# jupyter notebook  --ip=172.17.0.5 --port=81 --allow-root
```
![ScreenShot](https://github.com/Satanette/test/blob/master/jupy1.png)



Let's connect to database from Jupyter notebook,on web1 container:

```
root@web2:~# jupyter notebook  --ip=172.17.0.4 --port=81 --allow-root

```

![ScreenShot](https://github.com/Satanette/test/blob/master/jupy2.png)


Fini!
