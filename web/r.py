#!/usr/bin/python

import os, sys
sys.path.append(os.path.dirname(__file__))

import cgi
import inlines
import rules

GAME_ROOT= "/var/www/rules/games"

class NotFound(Exception):
    pass

#myrules = rules.RuleSpec("Caravaneers","/var/www/rules/en",date="2009",author="Andrew Perkis")

#myrules.addKeyword("scaravan","caravan",pl="caravans",an="a caravan")
#myrules.addKeyword("svictory","camel",pl="camels",an="a camel")
#myrules.addKeyword("send","game over")
#myrules.addKeyword("smountain space","mountain space",pl="mountain spaces",an="a mountain space")
#myrules.addPiece("spiece","black","circle")


#myrules.addPhase("A", "caravaneers/move", piece='spiece', group='scaravan', victory_point='svictory', end='send')
#myrules.addConstraint("A","common/pass-if-no-legal-moves")
#myrules.addConstraint("A","common/end-if-two-consecutive-passes")
#myrules.addConstraint("A","common/score-if-move-off-board")
#myrules.addDef("scaravan","caravaneers/caravan", piece='spiece', space='smountain space')
#myrules.addDef("smountain space","caravaneers/marked-space")
#myrules.addDef("svictory","common/victory-point")
#myrules.addDef("send","common/end/count-victory-points", victory_point='svictory')

if __name__=="__main__":
    print myrules['en'].html()
    raise SystemExit


def application(environ, start_response):
    query = cgi.parse_qs(environ['QUERY_STRING'])

    method = query.get("method",['html'])[0]
    locale = query.get("locale",['en'])[0]
    gamePath = query.get("game",[None])[0]
    status = '200 OK'

    try:
        try:
            gameFile = file(os.path.join(GAME_ROOT,gamePath),'r')
        except:
            raise NotFound("%s not found" % gamePath)

        myrules = rules.RuleSpec.fromFile(gameFile, source=gamePath)

        if locale not in myrules:
            raise NotFound("Locale %s not available for %s" % (locale,gamePath))
    
        output = '''<html  xmlns="http://www.w3.org/1999/xhtml"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:xlink="http://www.w3.org/1999/xlink"
>
    <head>
        <title>%s</title>
        <link rel="stylesheet" type="text/css" href="../rules/rules.css"></link>
    </head>
    <body>
        <h1>%s</h1>
        %s
    </body>
</html>
''' % (myrules[locale].name, myrules[locale].name, myrules[locale].html())

    except (NotFound, IOError) as e:
        status = '404 Not Found'

        output = '''<html  xmlns="http://www.w3.org/1999/xhtml">
    <head><title>404 Not Found</title></head>
    <body><h1>%s</h1></body>
</html>
''' % e


    response_headers = [('Content-type', 'application/xhtml+xml; charset=utf-8'),
                        ('Content-length', str(len(output)))]

    start_response(status, response_headers)

    return [output.encode("utf-8")]



