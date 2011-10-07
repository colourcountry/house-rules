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

DEFAULT_PIECE = Piece("black","circle")

class Rule:
    def __init__(self, definition, piece=DEFAULT_PIECE, otherPieces=None):
        self.definition = definition
        self.template = Template(file="/var/www/rules/templates/"+definition)
        self.piece = piece
        self.otherPieces = otherPieces
        self.keywordMap = None # don't know this yet

    def findKeyword(self,keyword):
        theId = urlparse.urljoin(self.definition,keyword)
        if theId in self.keywordMap:
            return (theId, "keyword", self.keywordMap[theId])
        else:
            return ("unknown", "keyword-unknown", theId)

    def html(self, keywordMap):
        self.keywordMap = keywordMap

        if self.piece:
            self.template.piece = self.piece.html()
        if self.otherPieces:
            self.template.pieces = [piece.html() for piece in self.otherPieces]

        self.template.keyword = lambda keyword: '<a href="#keyword-%s" class="%s">%s</a>' % self.findKeyword(keyword)

        return str(self.template)

class RuleSpec:
    def __init__(self, name, **metadata):
        # Map of local-name --> rule (file)name
        self.definitions = {}

        # For each local-name, optional map of rule (file)name --> local-name
        # If not found, use reverse of above
        self.keywordMaps = {}

        self.rules = {}

        self.name = name
        self.metadata = metadata

    def add(self,localName, definition, piece=DEFAULT_PIECE, otherPieces=None, keywords=None):
        self.definitions[localName] = definition
        self.keywordMaps[localName] = keywords
        self.rules[localName] = Rule(definition, piece, otherPieces)

    def html(self):
        result = ["<dl>"]
        for localName in self.rules:
            keywordMap = {a:b for (b,a) in self.definitions.items()}
            if self.keywordMaps[localName]:
                keywordMap.update( self.keywordMaps[localName] )

            result.extend([ '<dt><a name="keyword-'+self.definitions[localName]+'"></a><span class="keyword">',localName,"</span></dt>",
                            "<dd>",self.rules[localName].html(keywordMap),"</dd>" ])
        result.append("</dl>")

        return "\n".join(result)
