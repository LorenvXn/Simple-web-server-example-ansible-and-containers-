
<b> Next... </b>


Now that we have our tablespace populated with munchkin links, and there is an apache2 running on that container, 
let's use Jinja2 & Python, to extract those links from tablespace,  and check them from a browser.

Find code at <a href="https://github.com/LorenvXn/Simple-web-server-example-ansible-and-containers-/tree/master/Jinja2">Jinja2</a> folder

Our templates/index.html looks as below:

```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Munchkin links</title>
</head>
<body>
<center>
    <p>{{ urls[0] |length }} links</p>
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

... and an output.html file should be created, containing the tablespace's links.

Our links from original output looks like this:

```
[ ... sni ... ]
<li><a href="['http://cats.wikia.com/wiki/Main_Page']">['http://cats.wikia.com/wiki/Main_Page']</a></li>
<li><a href="['http://cats.wikia.com/wiki/Special:WikiActivity']">['http://cats.wikia.com/wiki/Special:WikiActivity']</a></li>
[ ... sni ... ]
```

It is obviously we won't be able to access those links from a browser.


Time for bit of sed jiu-jitsu. While we are here, let's move the changed file under /var/www/html:

```
more output.html |  sed 's/\[//g' | sed 's/\\\x27//g' | sed 's/\"\x27/\"/g' | \
sed 's/\]//g' | sed 's/\\\x27//g' | sed 's/\x27\"/\"/g' > /var/www/html/output.html
```

The links under /var/www/html/output.html file should now be looking as below:

```
<li><a href="http://cats.wikia.com/wiki/Main_Page">'http://cats.wikia.com/wiki/Main_Page'</a></li>
<li><a href="http://cats.wikia.com/wiki/Special:WikiActivity">'http://cats.wikia.com/wiki/Special:WikiActivity'</a></li>
```

