#!/usr/bin/env python
 
 
import os
import MySQLdb
from jinja2 import Environment, FileSystemLoader


dba = MySQLdb.connect(host="localhost", 
                      user="root", 
                      passwd="abc123", 
                      db="Kittens")
c = dba.cursor()

c.execute("select URL from Links;")

result=c.fetchall()
 
PATH = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_ENVIRONMENT = Environment(
    autoescape=False,
    loader=FileSystemLoader(os.path.join(PATH, 'templates')),
    trim_blocks=False)
 
 
def render_template(template_filename, context):
    return TEMPLATE_ENVIRONMENT.get_template(template_filename).render(context)
 
 
def create_index_html():
    fname = "output.html"
    urls = [list(i) for i in result]

    context = {
        'urls': urls
    }
    #
    with open(fname, 'w') as f:
        html = render_template('index.html', context)
        f.write(html)
 
 
def main():
    create_index_html()
 
 
if __name__ == "__main__":
    main()
