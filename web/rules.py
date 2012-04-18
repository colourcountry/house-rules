#!/usr/bin/python

from mako.template import Template
import inlines

try:
    import urlparse
    PYTHON3=False
except ImportError:
    PYTHON3=True
    import urllib.parse as urlparse

import json
import os
import sys
import pprint,cgi



class SafeDict(dict):
    def __getitem__(self, item):
        if super(SafeDict,self).__contains__(item):
            return super(SafeDict,self).__getitem__(item)
        return "<b>RULE REQUIRES VAR: '"+item+"'</b>"

    def __contains__(self, item):
        return True

class RuleSet:
    def __init__(self, path, qNames, defPath=None):
        self.path = path
        self.qNames = qNames

        if defPath is None:
            self.defPath = path
        else:
            self.defPath = defPath

        self.cache = {}
        self.defs = None # create this as necessary otherwise infinite loop

    def __getitem__(self, item):
        if item not in self.cache:
            if PYTHON3:
                self.cache[item] = json.loads( open( os.path.join(self.path,item), "r", encoding="utf-8").read() )
            else:
                self.cache[item] = json.loads( open( os.path.join(self.path,item), "r" ).read().decode("utf-8") )
        
        return self.cache[item]

    def getDefaults(self, item):
        theRule = self[item]
        if "_defaults" not in theRule:
            if self.defs is None:
                self.defs = RuleSet( self.defPath, self.qNames )
            defaults = {}
            if "defaults" in theRule:
                for key, value in theRule["defaults"].items():
                    theDef = self.defs[value]
                    defaults[key] = Variable(Keyword(theDef["base"], self.qNames), **{a:Keyword(b, self.qNames, key) for (a, b) in theDef.get("forms",{}).items()})
            theRule["_defaults"] = defaults

        return theRule["_defaults"]

    def getTemplate(self, item):
        theRule = self[item]
        if "_template" not in theRule:
            mytemplate = Template(theRule["template"])
            theRule["_template"] = mytemplate
            
        return theRule["_template"]



class Variable:
    def __init__(self, default, **args):
        self.forms = args
        self.default = default

    def __getattr__(self, name):
        try:
            return self.forms[name]
        except KeyError:
            return self.default

    def __str__(self):
        return str(self.default)

    def __repr__(self):
        return "<variable "+str(self.default)+" with forms "+repr(self.forms.items())+">"

    def html(self):
        #sys.stderr.write(str(self.forms))
        return Variable(self.default.html(), **{a:b.html() for (a,b) in self.forms.items()})

class Keyword:
    def __init__(self, name, qNames, baseName=None):
        self.name = name
        # dict which will at render time map self.name to a qname
        self.qNames = qNames
        if baseName is None:
            self.baseName = name
        else:
            self.baseName = baseName

    def html(self):
        if self.baseName in self.qNames:
            return inlines.link(self.name,self.qNames[self.baseName])
        else:
            return inlines.keyword(self.name)

    def __str__(self):
        return "(("+self.name +"))"

    def __repr__(self):
        return "(("+self.name +"))"

class Piece:
    def __init__(self, colour, shape):
        self.colour = colour
        self.shape = shape

    def html(self):
        return inlines.piece(self.colour,self.shape)

    def __str__(self):
        return "<<"+self.colour+" "+self.shape+">>"

    def __repr__(self):
        return "<<"+self.colour+" "+self.shape+">>"


class Rule:
    def __init__(self, localName, definition, ruleSet):
        self.localName = localName
        self.definition = definition
        self.template = ruleSet.getTemplate(definition)
        self.defaultKeywordMap = ruleSet.getDefaults(definition)

    def findKeyword(self,keyword):
        theId = urlparse.urljoin(self.definition,keyword)
        if theId in self.keywordMap:
            return (theId, "keyword", self.keywordMap[theId])
        else:
            return ("unknown", "keyword unknown", theId)

    def html(self, keywordMap):
        sys.stderr.write("rule %s has keywordmap %s\n" % (self.localName, pprint.pformat(self.defaultKeywordMap)))
        renderedMap = {a:b.html() for (a,b) in keywordMap.items()}
        for (a,b) in self.defaultKeywordMap.items():
            if a not in renderedMap:
                renderedMap[a]=b.html()
        sys.stderr.write("rule %s has renderedmap %s\n" % (self.localName, pprint.pformat(renderedMap)))
    
        return self.template.render_unicode(**renderedMap)

class RuleSpec:
    @classmethod
    def fromJson( cclass, theme, ruleRoot, gameRoot, defRoot, source=None  ):

        if PYTHON3:
            gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r', encoding="utf-8" )
            game = json.loads( gameFile.read() )
        else:
            gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r')
            game = json.loads( gameFile.read().decode("utf-8") )

        results = {}

        locale = theme['locale']

        name = theme.pop('name')
        keywords = theme.pop('keywords')

        if source:
            theme['source'] = source

        ruleSpec = cclass( name, os.path.join(ruleRoot,locale), os.path.join(defRoot,locale), **theme )

        for localName, kwSpec in keywords.items():
            ruleSpec.addVariable(localName, kwSpec)

        
        # no themed content below here


        for phaseName, phaseSpec in game['rules'].items():
            ruleSpec.addPhase(phaseName, phaseSpec['rule'], **phaseSpec.get('vars',{}))

            if 'constraints' in phaseSpec:
                for constraint in phaseSpec['constraints']:
                    ruleSpec.addConstraint(phaseName, constraint['rule'], **constraint.get('vars',{}))

        for defName, defSpec in game['defs'].items():
            ruleSpec.addDef(defName, defSpec['def'], **defSpec.get('vars',{}))


        ruleSpec.finish()

        return ruleSpec
        

    def __init__(self, name, rulePath, defPath, **metadata):
        # Map of local-name --> rule qualified-name (filename)
        self.qNames = {}

        # Map of local-name --> variable with forms
        self.variables = {}

        # For each local-name, optional map of rule qname --> variable
        # If not found, use reverse of above
        self.keywordMaps = {}

        self.defTemplates = {}
        self.phaseTemplates = {}
        self.constraintTemplates = {}

        self.name = name
        self.ruleSet = RuleSet(rulePath, self.qNames, defPath)
        self.metadata = metadata

    def finish(self):
        self.globalsMap = SafeDict({a:self.variables[b] for (b,a) in self.qNames.items()})
        self.variableMaps = {}


    def addVariable(self, localName, spec):
        if spec['type']=='piece':
            self.addPiece(localName, spec['colour'], spec['shape'])
        elif spec['type']=='keyword':
            self.addKeyword(localName, spec['base'], **spec.get('forms',{}))
        else:
            raise ValueError("Unsupported keyword-type")


    def addKeyword(self, localName, default, **args):
        self.variables[localName] = Variable(Keyword(default,self.qNames,localName), **{a:Keyword(b,self.qNames,localName) for (a,b) in args.items()})

    def addPiece(self, localName, colour, shape):
        self.variables[localName] = Variable(Piece(colour, shape))

    def addPhase(self,localName, qName, **keywords):
        self.variables[localName] = Variable(Keyword(localName,self.qNames))
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        self.phaseTemplates[localName] = Rule(localName, qName, self.ruleSet)

    def addConstraint(self,phaseName, qName, **keywords):
        # Constraints don't have visible names so just use the qName
        localName = "rule:"+qName
        self.variables[localName] = Variable(Keyword(localName,self.qNames))
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        if phaseName not in self.constraintTemplates:
            self.constraintTemplates[phaseName] = []
        self.constraintTemplates[phaseName].append( Rule(localName, qName, self.ruleSet) )    

    def addDef(self,localName, qName, **keywords):
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        self.defTemplates[localName] = Rule(localName, qName, self.ruleSet.defs)

        if localName not in self.variables:
            # add the default rendering for locale, as theme didn't supply one
            self.addVariable(localName, self.ruleSet.defs[qName])

    def getVariableMap(self, localName):
        if localName not in self.variableMaps:
            result = SafeDict({})
            if self.keywordMaps[localName]:
                result.update({a:self.variables.get(b,Keyword("MISSING KEY "+b,[])) for (a,b) in self.keywordMaps[localName].items()})
            self.variableMaps[localName] = result

        return self.variableMaps[localName]

    def html(self):
        result = []

        DEBUG = ''

        authorInfo = ''
        if 'author' in self.metadata:
            authorInfo += '<span class="author">%s </span>' % self.metadata['author']
        if 'date' in self.metadata:
            authorInfo += '<span class="date">%s</span>' % self.metadata['date']
        if authorInfo:
            result.append('<div class="authorInfo">%s</div>' % authorInfo)

        if 'description' in self.metadata:
            result.append('<div class="description">%s</div>' % self.metadata['description'])

        result.append('<table><tr><td class="phases"><dl>')

        for localName in self.phaseTemplates:
            variableMap = self.getVariableMap(localName)
            result.extend([ '<dt><a name="phase-'+self.qNames[localName]+'"></a><span class="keyword">',localName,"</span></dt>",
                            "<dd>",self.phaseTemplates[localName].html( self.getVariableMap(localName) ),"</dd>" ])

            if localName in self.constraintTemplates:
                for constraint in self.constraintTemplates[localName]:
                    variableMap = self.getVariableMap(constraint.localName)
                    result.extend([ '<dt></dt>',
                                    "<dd>",constraint.html( self.getVariableMap(constraint.localName) ),"</dd>" ])

        result.append("</dl></td>")

        result.append('<td class="defs"><dl>')
        for localName in self.defTemplates:
            variableMap = self.getVariableMap(localName)
            result.extend([ '<dt><a name="keyword-'+self.qNames[localName]+'"></a><span class="keyword">',str(self.variables[localName].html()),"</span></dt>",
                            "<dd>",self.defTemplates[localName].html(self.getVariableMap(localName)),"</dd>" ])
        result.append("</dl></td></tr></table>")

        #DEBUG += pprint.pformat(self.variableMaps)
        #DEBUG += pprint.pformat(self.qNames)
        
        if DEBUG:
            result.append('<pre style="background-color:yellow;z-index:50;opacity:0.4;position:absolute">%s</pre>' % cgi.escape(DEBUG))

        #s = result[0].decode('utf-8')
        #for t in result[1:]:
        #    if not isinstance(t,unicode):
        #        raise AssertionError("Not Unicode: %s" % t)
        #    s += "\n"+t
        #
        #return s
        return "\n".join(result)
