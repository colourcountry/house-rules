#!/usr/bin/python3

import os, sys, json, shutil
sys.path.append(os.path.dirname(__file__))

import cgi
import rulecompiler.inlines as inlines
import rulecompiler.rules as rules

DATA_ROOT= "data"
GAME_ROOT= os.path.join(DATA_ROOT, "games")
RULE_ROOT= os.path.join(DATA_ROOT, "rules")
THEME_ROOT= os.path.join(DATA_ROOT, "themes")

TARGET_ROOT= "target"

PIECES_SVG = "\n".join( open(os.path.join("rulecompiler","pieces.svg"),"r").readlines()[1:] )
RULES_CSS= os.path.join("rulecompiler","rules.css")

class NotFound(Exception):
    pass




def update( old, new ):
    '''Recursively update a dictionary and any of its dictionary children'''
    for key, value in new.items():
        if isinstance(value, dict) and key in old:
            old[key] = update( old[key], value )
        else:
            old[key] = value
    return old

class Application:

    @staticmethod
    def loadTheme( gameName, locale ):

        try:
            defaultFile = open(os.path.join(THEME_ROOT,locale,'default'),'r')
        except Exception as e:
            raise NotFound("default theme not found for locale %s: %s" % (locale, e))
        try:
            themeFile = open(os.path.join(THEME_ROOT,locale,gameName),'r')
        except Exception as e:
            raise NotFound("%s not found for locale %s: %s" % (gameName, locale, e))

        try:
            theme = json.load(defaultFile)
        except ValueError as e:
            raise ValueError("error reading default theme for locale %s: %s" % (locale, e))

        try:
            update( theme, json.load(themeFile) )
        except ValueError as e:
            raise ValueError("error reading %s theme for locale %s: %s" % (gameName, locale, e))
        

        return theme

    @staticmethod
    def render(myrules,
                cssUrl='../rules/rules.css',
                jqUrl='/zoomooz/jquery.min.js',
                zoomUrl='/zoomooz/jquery.zoomooz.min.js'):
        output = '''<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>%s</title>
        <link rel="stylesheet" type="text/css" href="%s"></link>
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
        <script src="%s"></script>
        <script src="%s"></script>
        <script type="text/javascript">
            var cur_dt = null;
            var cur_dd = null;

            var remove_callout = function() {
                if (cur_dt) {
                    cur_dt.removeClass("callout");
                    cur_dt = null;
                }
                if (cur_dd) {
                    cur_dd.removeClass("callout");
                    cur_dd = null;
                }
            };

            var move_callout = function(new_dt, new_dd) {
                remove_callout();
                new_dt.addClass("callout");
                new_dd.addClass("callout");
                cur_dt = new_dt;
                cur_dd = new_dd;
            };

            var init = function() {
                $(".hiddenLink").each( function(index) {
                    var qName = $(this).attr("href").substring(9);
                    var dt = $("#dt-"+qName);
                    var dd = $("#dd-"+qName);
                    $(this).click(function() {
                        dt.toggleClass("hidden");
                        dd.toggleClass("hidden");
                        move_callout(dt, dd);
                    });
                    $(this).mouseenter(function() {
                        move_callout(dt, dd);
                    });
                    /*$(this).mouseleave(function() {
                        remove_callout();
                    });*/
                });
                $(".visibleLink").each( function(index) {
                    var qName = $(this).attr("href").substring(9);
                    var dt = $("#dt-"+qName);
                    var dd = $("#dd-"+qName);
                    $(this).click(function() {
                        move_callout(dt, dd);
                    });
                    $(this).mouseenter(function() {
                        move_callout(dt, dd);
                    });
                    /*$(this).mouseleave(function() {
                        remove_callout(dt, dd);
                    });*/
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
''' % (myrules.name,
       cssUrl, jqUrl, zoomUrl,
       myrules.name, myrules.html(), PIECES_SVG)

        return output


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

            myrules = rules.FullSpec.fromJson(theme, ruleRoot = RULE_ROOT, gameRoot = GAME_ROOT, source = locale+"/"+gameName)

            output = Application.render(myrules)

        except Exception as e:
            status = '404 Not Found'

            output = '''<html>
    <head><title>404 Not Found</title></head>
    <body><h1>%s</h1><p>%s</p></body>
</html>
''' % (e.__class__.__name__, e)

        outBytes = output.encode("utf-8")

        response_headers = [('Content-type', 'application/html; charset=utf-8'),
                        ('Content-length', str(len(outBytes)))]

        start_response(status, response_headers)

        return [outBytes]


# Apache mod_wsgi is very weird
def application(environ, start_response):
    return Application().__call__(environ, start_response)

def make_dir(dirname):
    try:
        os.makedirs(dirname)
    except FileExistsError:
        pass


# Run this script from command line to compile all games to static HTML
if __name__=="__main__":
    make_dir(TARGET_ROOT)
    shutil.copy(RULES_CSS,TARGET_ROOT)
    for locale in os.listdir(THEME_ROOT):
        make_dir(os.path.join(TARGET_ROOT,locale))
        for gameName in os.listdir(os.path.join(THEME_ROOT,locale)):
            if gameName != 'default':
                print('%s/%s\n' % (locale, gameName))
                theme = Application.loadTheme(gameName, locale)
                myrules = rules.FullSpec.fromJson(theme, ruleRoot = RULE_ROOT, gameRoot = GAME_ROOT, source = locale+"/"+gameName)
                html = Application.render(myrules, cssUrl = '../rules.css')
                open('target/%s/%s.html' % (locale, gameName),'w').write(html)
