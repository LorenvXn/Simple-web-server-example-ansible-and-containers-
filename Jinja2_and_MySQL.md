
<b> Next... Jinja2 and MySQL</b>


Now that we have our tablespace populated with munchkin links, and there is an apache2 running on that container, 
let's use Jinja2 & Python, and check those links from a browser.

Find code at <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/tree/master/Jinja2">Jinja2</a> folder

```
root@web:/home/ji# tree
.
|-- extract.py
|-- templates
|   `-- index.html
`-- ~
```

The code is run on the container on which we have already created the database Kittens, &tablespace Links:

```
[ ... snip ... ]
dba = MySQLdb.connect(host="localhost", 
                      user="root", 
                      passwd="abc123", 
                      db="Kittens")     
[ ... snip ... ]
```

Our <b>templates/index.html</b> looks as below:

```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Munchkin links</title>
</head>
<body>
<center>
    <p>{{ urls |length }} links</p>
</center>
<ol align="left">
{% set counter = 0 -%}
    {% for url  in urls  %}
<li><a href="{{ url }}">{{ url }}</a></li>
{% set counter = counter + 1 -%}
{% endfor -%}
</ol>
</body>
</html>

```
Just run:

```
python extract.py
```

... and an <b>output.html</b> file should be created, containing the tablespace's links.

```
root@web:/home/ji# tree
.
|-- extract.py
|-- output.html
|-- templates
|   `-- index.html
`-- ~
```
Our links from original output look as per below snip:

```
[ ... snip ... ]
<li><a href="['http://cats.wikia.com/wiki/Main_Page']">['http://cats.wikia.com/wiki/Main_Page']</a></li>
<li><a href="['http://cats.wikia.com/wiki/Special:WikiActivity']">['http://cats.wikia.com/wiki/Special:WikiActivity']</a></li>
[ ... snip ... ]
```

It is obviously we won't be able to access those links from a browser.


Time for bit of sed jiu-jitsu. While we are here, let's make a copy of the changed <b>output.html</b> file 
under path <b>/var/www/html</b>:

```
more output.html |  sed 's/\[//g' | sed 's/\\\x27//g' | sed 's/\"\x27/\"/g' | \
sed 's/\]//g' | sed 's/\\\x27//g' | sed 's/\x27\"/\"/g' > /var/www/html/output.html
```

The links under <b>/var/www/html/output.html</b> file should now be looking as below:

[final /var/www/html/output.html form]


```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Munchkin links</title>
</head>
<body>
<center>
    <p>12 links</p>
</center>
<ol align="left">

<li><a href="http://cats.wikia.com">'http://cats.wikia.com'</a></li>

<li><a href="https://www.wikia.com/signin?redirect=http%3A%2F%2Fcats.wikia.com%2Fwiki%2FMunchkin_%28Breed%29">'https://www.wikia.com/signin?redirect=http%3A%2F%2Fcats.wikia.com%2Fwiki%2FMunchkin_%28Breed%
29'</a></li>

<li><a href="https://www.wikia.com/register?redirect=http%3A%2F%2Fcats.wikia.com%2Fwiki%2FMunchkin_%28Breed%29">'https://www.wikia.com/register?redirect=http%3A%2F%2Fcats.wikia.com%2Fwiki%2FMunchkin_%28Br
eed%29'</a></li>

<li><a href="http://cats.wikia.com/wiki/Main_Page">'http://cats.wikia.com/wiki/Main_Page'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:WikiActivity">'http://cats.wikia.com/wiki/Special:WikiActivity'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:Random">'http://cats.wikia.com/wiki/Special:Random'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:Videos">'http://cats.wikia.com/wiki/Special:Videos'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:Images">'http://cats.wikia.com/wiki/Special:Images'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:Forum">'http://cats.wikia.com/wiki/Special:Forum'</a></li>
<li><a href="http://ja.cats.wikia.com/wiki/">'http://ja.cats.wikia.com/wiki/'</a></li>
<li><a href="http://ru.cats.wikia.com/wiki/">'http://ru.cats.wikia.com/wiki/'</a></li>
<li><a href="http://cats.wikia.com/wiki/Munchkin_(Breed)?oldid=12127">'http://cats.wikia.com/wiki/Munchkin_(Breed)?oldid=12127'</a></li>
</ol>
</body>
</html>
```

You can now access the munchkin links from container 172.17.0.5 (don't forget to check if apache2 is up and running! 
remember that 172.17.0.4 and 172.17.0.5 were web containers, with apache2 on them):

![ScreenShot](https://github.com/Satanette/test/blob/master/munchy.png)


Fini!
