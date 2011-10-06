#!/usr/bin/python

import os, sys
sys.path.append(os.path.dirname(__file__))

import inlines
import rules

def application(environ, start_response):
    status = '200 OK'

    piece = rules.Piece("black","circle")

    keywords = {"move":"defs/caravaneers/move",
                "caravan":"defs/caravaneers/caravan",
                "mountain space":"defs/caravaneers/marked-space",
                "victory point":"defs/common/victory-point"}


    defs = '<dl>'

    for keyword in sorted(keywords.keys()):
        defs += '<dt><a name="keyword-%s"></a><span class="keyword">%s</span></dt>' % (keywords[keyword], keyword)
        defs += '<dd>%s</dd>' % rules.getHtml(keywords[keyword],piece,keywords)

    defs += '</dl>'

    output = '''<html  xmlns="http://www.w3.org/1999/xhtml"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:xlink="http://www.w3.org/1999/xlink"
>
    <head>
        <title>Hello</title>
        <style type="text/css">
.svg { display: inline-block; height: 20pt; width: 20pt; vertical-align: middle }
.keyword { text-transform: uppercase; font-weight: bold; color: blue }
.keyword-unknown { text-transform: uppercase; font-weight: bold; color: red }
        </style>
    </head>
    <body>
        <h1>hello</h1>
        %s
    </body>
</html>
''' % defs

    response_headers = [('Content-type', 'application/xhtml+xml'),
                        ('Content-length', str(len(output)))]

    start_response(status, response_headers)

    return [output]



