#!/usr/bin/python

import os, sys
sys.path.append(os.path.dirname(__file__))

import inlines
import rules


def application(environ, start_response):
    status = '200 OK'

    myrules = rules.RuleSpec("Caravaneers",date="2009",author="Andrew Perkis")

    myrules.add("move", "defs/caravaneers/move")
    myrules.add("caravan","defs/caravaneers/caravan")
    myrules.add("mountain space","defs/caravaneers/marked-space")


    output = '''<html  xmlns="http://www.w3.org/1999/xhtml"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:xlink="http://www.w3.org/1999/xlink"
>
    <head>
        <title>%s</title>
        <style type="text/css">
.svg { display: inline-block; height: 20pt; width: 20pt; vertical-align: middle }
.keyword { text-transform: uppercase; font-weight: bold; color: blue }
.keyword-unknown { text-transform: uppercase; font-weight: bold; color: red }
        </style>
    </head>
    <body>
        <h1>%s</h1>
        %s
    </body>
</html>
''' % (myrules.name, myrules.name, myrules.html())

    response_headers = [('Content-type', 'application/xhtml+xml'),
                        ('Content-length', str(len(output)))]

    start_response(status, response_headers)

    return [output]



