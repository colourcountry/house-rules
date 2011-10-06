#!/usr/bin/python

from Cheetah.Template import Template
import inlines
import urlparse

class Piece:
    def __init__(self, colour, shape):
        self.colour = colour
        self.shape = shape

    def html(self):
        return inlines.piece(self.colour,self.shape)


def getHtml(name,piece,keywords):

    # reverse dict as now we want to get local names for ids
    keywords = {a:b for (b,a) in keywords.items()}    

    def getKeywordsHtmlFn(keywordsDict):
        def findId(keyword):
            if keyword in keywordsDict:
                return (keyword, "keyword", keywordsDict[keyword])
            else:
                theId = urlparse.urljoin(name,keyword)
                if theId in keywordsDict:
                    return (theId, "keyword", keywordsDict[theId])
                else:
                    return ("unknown", "keyword-unknown", theId)
        return lambda x: '<a href="#keyword-%s" class="%s">%s</a>' % findId(x)

    t = Template(file="/var/www/rules/templates/"+name)
    t.piece = [piece.html()]
    t.keywords = getKeywordsHtmlFn(keywords)
    return str(t)
