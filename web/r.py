#!/usr/bin/python

import os, sys, json
sys.path.append(os.path.dirname(__file__))

import cgi
import inlines
import rules

ROOT= "/var/www/rules"
GAME_ROOT= os.path.join(ROOT, "games")
RULE_ROOT= os.path.join(ROOT, "rules")
THEME_ROOT= os.path.join(ROOT, "themes")

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

def update( old, new ):
    '''Recursively update a dictionary and any of its dictionary children'''
    for key, value in new.items():
        if isinstance(value, dict) and key in old:
            old[key] = update( old[key], value )
        else:
            old[key] = value
    return old

def application(environ, start_response):
    query = cgi.parse_qs(environ['QUERY_STRING'])

    method = query.get("method",['html'])[0]
    locale = query.get("locale",['en'])[0]
    gameName = query.get("game",[None])[0]
    status = '200 OK'


    try:
        try:
            defaultFile = file(os.path.join(THEME_ROOT,locale,'default'),'r')
        except:
            raise NotFound("default theme not found for locale %s" % locale)
        try:
            themeFile = file(os.path.join(THEME_ROOT,locale,gameName),'r')
        except:
            raise NotFound("%s not found for locale %s" % (themePath, locale))

        theme = json.load(defaultFile)
        update( theme, json.load(themeFile) )


        myrules = rules.RuleSpec.fromJson(theme, ruleRoot = RULE_ROOT, gameRoot = GAME_ROOT, source = locale+"/"+gameName)

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
''' % (myrules.name, myrules.name, myrules.html())

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



