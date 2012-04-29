#!/usr/bin/python3

import os, sys, json
sys.path.append(os.path.dirname(__file__))

import cgi
import inlines
import rules

ROOT= "/var/www/rules"
GAME_ROOT= os.path.join(ROOT, "games")
RULE_ROOT= os.path.join(ROOT, "rules")
THEME_ROOT= os.path.join(ROOT, "themes")

PIECES_SVG = "\n".join( open(os.path.join(ROOT,"pieces.svg"),"r").readlines()[1:] )

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


def update( old, new ):
    '''Recursively update a dictionary and any of its dictionary children'''
    for key, value in new.items():
        if isinstance(value, dict) and key in old:
            old[key] = update( old[key], value )
        else:
            old[key] = value
    return old

class Application:

    @classmethod
    def loadTheme( cclass, gameName, locale ):

        try:
            defaultFile = open(os.path.join(THEME_ROOT,locale,'default'),'r')
        except:
            raise NotFound("default theme not found for locale %s" % locale)
        try:
            themeFile = open(os.path.join(THEME_ROOT,locale,gameName),'r')
        except:
            raise NotFound("%s not found for locale %s" % (themePath, locale))

        theme = json.load(defaultFile)
        update( theme, json.load(themeFile) )

        return theme

    def __init__(self, *args):
        # no idea what Apache is passing here
        self.initArgs = args

    def __call__(self,environ, start_response):
        query = cgi.parse_qs(environ['QUERY_STRING'])

        method = query.get("method",['html'])[0]
        locale = query.get("locale",['en'])[0]
        gameName = query.get("game",[None])[0]
        status = '200 OK'


        try:
            theme = Application.loadTheme(gameName, locale)

            myrules = rules.RuleSpec.fromJson(theme, ruleRoot = RULE_ROOT, gameRoot = GAME_ROOT, source = locale+"/"+gameName)

            output = '''<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/html1/DTD/xhtml1-strict.dtd">
<html  xmlns="http://www.w3.org/1999/xhtml"
                     xmlns:svg="http://www.w3.org/2000/svg"
                     xmlns:xlink="http://www.w3.org/1999/xlink"
>
    <head>
        <title>%s</title>
        <link rel="stylesheet" type="text/css" href="../rules/rules.css"></link>
        <script src="/zoomooz/jquery.min.js"></script>
        <script src="/zoomooz/jquery.zoomooz.min.js"></script>
        <script type="text/javascript">
            init = function() {
                $(".hiddenLink").each( function(index) {
                    var qName = $(this).attr("href").substring(9);
                    var dt = $("#dt-"+qName);
                    var dd = $("#dd-"+qName);
                    $(this).click(function() {
                        dt.toggleClass("hidden callout");
                        dd.toggleClass("hidden callout");
                    });
                    $(this).mouseenter(function() {
                        dt.addClass("callout");
                        dd.addClass("callout");
                        dt.removeClass("hidden");
                        dd.removeClass("hidden");
                    });
                    $(this).mouseleave(function() {
                        dt.addClass("hidden");
                        dd.addClass("hidden");
                        dt.removeClass("callout");
                        dd.removeClass("callout");
                    });
                });
                $(".visibleLink").each( function(index) {
                    var qName = $(this).attr("href").substring(9);
                    var dt = $("#dt-"+qName);
                    var dd = $("#dd-"+qName);
                    $(this).click(function() {
                        dt.toggleClass("visible callout");
                        dd.toggleClass("visible callout");
                    });
                    $(this).mouseenter(function() {
                        dt.addClass("callout");
                        dd.addClass("callout");
                        dt.removeClass("visible");
                        dd.removeClass("visible");
                    });
                    $(this).mouseleave(function() {
                        dt.addClass("visible");
                        dd.addClass("visible");
                        dt.removeClass("callout");
                        dd.removeClass("callout");
                    });
                });
            };
        </script>
    </head>
    <body onload="init()">
        <div class="zoomViewport">
            <div class="zoomContainer">
                <h1>%s</h1>
                %s
            </div>
        </div>
        <div style="display: none">
            <!-- Workaround for Safari not supporting external svg:use -->
            %s
        </div>
    </body>
</html>
''' % (myrules.name, myrules.name, myrules.html(), PIECES_SVG)

        except Exception as e:
            status = '404 Not Found'

            output = '''<html  xmlns="http://www.w3.org/1999/xhtml">
    <head><title>404 Not Found</title></head>
    <body><h1>%s</h1><p>%s</p></body>
</html>
''' % (e.__class__.__name__, e)

        outBytes = output.encode("utf-8")

        response_headers = [('Content-type', 'application/xhtml+xml; charset=utf-8'),
                        ('Content-length', str(len(outBytes)))]

        start_response(status, response_headers)

        return [outBytes]


# Apache mod_wsgi is very weird
def application(environ, start_response):
    return Application().__call__(environ, start_response)

# For debugging, you can run this script from command line
if __name__=="__main__":
    gameName = "caravaneers"
    locale = "en"
    theme = Application.loadTheme(gameName, locale)
    myrules = rules.RuleSpec.fromJson(theme, ruleRoot = RULE_ROOT, gameRoot = GAME_ROOT, source = locale+"/"+gameName)
    print(myrules.html())
    raise SystemExit
