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

LAST = 99999

class SafeDict(dict):
    def __getitem__(self, item):
        if super(SafeDict,self).__contains__(item):
            return super(SafeDict,self).__getitem__(item)
        return "<b>RULE REQUIRES VAR: '"+item+"'</b>"

    def __contains__(self, item):
        return True

class RuleSet:
    def __init__(self, path, qNames):
        self.path = path
        self.qNames = qNames

        self.cache = {}

    def injectDefs(self, defs):
        self.cache.update(defs)

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
            defaults = {}
            if "defaults" in theRule:
                for key, value in theRule["defaults"].items():
                    theDef = self[value]
                    defaults[key] = Variable(Keyword(value, self.qNames, theDef["base"]), **{a:Keyword(value, self.qNames, b) for (a, b) in theDef.get("forms",{}).items()})
            theRule["_defaults"] = defaults

        return theRule["_defaults"]

    def getTemplate(self, item):
        theRule = self[item]
        if "_template" not in theRule:
            mytemplate = Template(theRule["template"])
            theRule["_template"] = mytemplate
            
        return theRule["_template"]



class Variable:
    def __init__(self, base, **args):
        self.forms = args
        self.base = base

    def __getattr__(self, name):
        try:
            return self.forms[name]
        except KeyError:
            return self.base

    def __str__(self):
        return str(self.base)

    def __repr__(self):
        return "<variable "+str(self.base)+" with forms "+repr(self.forms.items())+">"

    def html(self):
        #sys.stderr.write(str(self.forms))
        return Variable(self.base.html(), **{a:b.html() for (a,b) in self.forms.items()})

    def __lt__(self, other):
        return self.base < other.base

class Keyword:
    def __init__(self, qName, allQNames, baseName=None):
        self.qName = qName
        self.allQNames = allQNames
        if baseName is None:
            self.baseName = qName
        else:
            self.baseName = baseName

    def html(self):
        if self.qName in self.allQNames:
            return inlines.link(self.baseName,self.qName)
        else:
            return inlines.keyword(self.baseName)

    def __str__(self):
        return "(("+self.qName +":"+self.baseName+"))"

    def __repr__(self):
        return "(("+self.qName +":"+self.baseName+"))"

    def __lt__(self, other):
        return self.baseName < other.baseName

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
    def __init__(self, qName, ruleSet, order):
        self.qName = qName
        self.order = order
        self.localName = qName
        self.template = ruleSet.getTemplate(qName)
        self.defaultKeywordMap = ruleSet.getDefaults(qName)

    def findKeyword(self,keyword):
        theId = urlparse.urljoin(self.qName,keyword)
        if theId in self.keywordMap:
            return (theId, "keyword", self.keywordMap[theId])
        else:
            return ("unknown", "keyword unknown", theId)

    def html(self, keywordMap):
        sys.stderr.write("rule %s has keywordmap %s\n" % (self.qName, pprint.pformat(self.defaultKeywordMap)))
        renderedMap = {a:b.html() for (a,b) in keywordMap.items()}
        for (a,b) in self.defaultKeywordMap.items():
            if a not in renderedMap:
                renderedMap[a]=b.html()
        sys.stderr.write("rule %s has renderedmap %s\n" % (self.qName, pprint.pformat(renderedMap)))
    
        return self.template.render_unicode(**renderedMap)

    def __lt__(self, other):
        if self.order == other.order:
            return self.localName < other.localName
        return self.order < other.order

class RuleSpec:
    @classmethod
    def fromJson( cclass, theme, ruleRoot, gameRoot, source=None  ):

        if PYTHON3:
            gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r', encoding="utf-8" )
            game = json.loads( gameFile.read() )
        else:
            gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r')
            game = json.loads( gameFile.read().decode("utf-8") )

        results = {}

        locale = theme['locale']

        name = theme.pop('name')
        keywords = theme.pop('defs')

        if source:
            theme['source'] = source

        ruleSpec = cclass( name, os.path.join(ruleRoot,locale), **theme )

        for qName, kwSpec in keywords.items():
            ruleSpec.addVariable(qName, kwSpec)

        
        # no themed content below here


        for phaseName, phaseSpec in game['rules'].items():
            if phaseSpec is None:
                ruleSpec.addPhase(phaseName)
            else:            
                ruleSpec.addPhase(phaseName,  phaseSpec.get('order',LAST), **phaseSpec.get('vars',{}))

            if 'constraints' in phaseSpec:
                for constraintName, constraintSpec in phaseSpec['constraints'].items():
                    if constraintSpec is None:
                        ruleSpec.addConstraint(phaseName, constraintName)
                    else:            
                        ruleSpec.addConstraint(phaseName, constraintName, constraintSpec.get('order',LAST), **constraintSpec.get('vars',{}))

        for defName, defSpec in game['defs'].items():
            if defSpec is None:
                ruleSpec.addDef(defName)
            else:
                ruleSpec.addDef(defName, defSpec.get('order',LAST), **defSpec.get('vars',{}))


        ruleSpec.finish()

        return ruleSpec
        

    def __init__(self, name, rulePath, **metadata):

        # Map of qName --> variable with forms
        self.qNames = {}

        # For each local-name, optional map of rule qname --> variable
        # If not found, use reverse of above
        self.keywordMaps = {}

        self.defTemplates = []
        self.phaseTemplates = []
        self.constraintTemplates = {}

        self.name = name
        self.ruleSet = RuleSet(rulePath, self.qNames)
        self.metadata = metadata

    def finish(self):
        self.globalsMap = SafeDict(self.qNames)
        self.variableMaps = {}


    def addVariable(self, qName, spec):
        if spec['type']=='piece':
            self.addPiece(qName, spec['colour'], spec['shape'])
        elif spec['type']=='keyword':
            self.addKeyword(qName, spec['base'], **spec.get('forms',{}))
        else:
            raise ValueError("Unsupported keyword-type")


    def addKeyword(self, qName, default, **args):
        self.qNames[qName] = Variable(Keyword(qName,self.qNames,default), **{a:Keyword(qName,self.qNames,b) for (a,b) in args.items()})

    def addPiece(self, qName, colour, shape):
        self.qNames[qName] = Variable(Piece(colour, shape))

    def addPhase(self, qName, order=LAST, **keywords):
        #self.qNames[qName] = Variable(Keyword(qName,self.qNames))
        self.phaseTemplates.append( Rule(qName, self.ruleSet, order) )
        self.keywordMaps[qName] = {"this":qName}
        self.keywordMaps[qName].update(keywords)

        if qName not in self.qNames:
            # add the default rendering for locale, as theme didn't supply one
            self.addVariable(qName, self.ruleSet[qName])

    def addConstraint(self, phaseName, qName, order=LAST, **keywords):
        # Constraints don't have visible names so just use the qName
        self.qNames[qName] = Variable(Keyword(qName,self.qNames))
        self.keywordMaps[qName] = {"this":qName}
        self.keywordMaps[qName].update(keywords)
        if phaseName not in self.constraintTemplates:
            self.constraintTemplates[phaseName] = []
        self.constraintTemplates[phaseName].append( Rule(qName, self.ruleSet, order) )

    def addDef(self,qName, order=LAST, **keywords):
        self.defTemplates.append( Rule(qName, self.ruleSet, order) )
        self.keywordMaps[qName] = {"this":qName}
        self.keywordMaps[qName].update(keywords)

        if qName not in self.qNames:
            # add the default rendering for locale, as theme didn't supply one
            self.addVariable(qName, self.ruleSet[qName])

    def getVariableMap(self, qName):
        if qName not in self.variableMaps:
            result = SafeDict({})
            if self.keywordMaps[qName]:
                result.update({a:self.qNames.get(b,Keyword("MISSING KEY "+b,[])) for (a,b) in self.keywordMaps[qName].items()})
            self.variableMaps[qName] = result

        return self.variableMaps[qName]

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

        for rule in self.phaseTemplates:
            try:
                rule.localName = self.qNames[rule.qName]
            except KeyError:
                pass
        for index, rule in enumerate(sorted(self.phaseTemplates)):
            variableMap = self.getVariableMap(rule.qName)
            result.extend([ '<dt><a name="phase-'+rule.qName+'"></a><span class="keyword">',str(self.qNames[rule.qName].html()),"</span></dt>",
                            "<dd>",rule.html( self.getVariableMap(rule.qName) ),"</dd>" ])

            if rule.qName in self.constraintTemplates:
                for constraint in self.constraintTemplates[rule.qName]:
                    try:
                        constraint.localName = self.qNames[constraint.qName]
                    except KeyError:
                        pass
                for constraint in sorted(self.constraintTemplates[rule.qName]):
                    variableMap = self.getVariableMap(constraint.qName)
                    result.extend([ '<dt></dt>',
                                    "<dd>",constraint.html( self.getVariableMap(constraint.qName) ),"</dd>" ])

        result.append("</dl></td>")

        result.append('<td class="defs"><dl>')
        for rule in self.defTemplates:
            try:
                rule.localName = self.qNames[rule.qName]
            except KeyError:
                pass
        for rule in sorted(self.defTemplates):
            variableMap = self.getVariableMap(rule.qName)
            result.extend([ '<dt><a name="keyword-'+rule.qName+'"></a><span class="keyword">',str(self.qNames[rule.qName].html()),"</span></dt>",
                            "<dd>",rule.html(self.getVariableMap(rule.qName)),"</dd>" ])
        result.append("</dl></td></tr></table>")

        
        #DEBUG += pprint.pformat(self.variableMaps)+"\n"
        #DEBUG += pprint.pformat(self.qNames)+"\n"
        
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
