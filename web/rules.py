#!/usr/bin/python

from Cheetah.Template import Template
import inlines
import urlparse
import json
import os
import sys

class SafeDict(dict):
    def __getitem__(self, item):
        if super(SafeDict,self).__contains__(item):
            return super(SafeDict,self).__getitem__(item)
        return "<b>"+item.replace("_"," ")+"</b>"

    def __contains__(self, item):
        return True

class TemplateSet:
    def __init__(self, prefix):
        self.prefix = prefix
        self.cache = {}

    def __getitem__(self, item):
        if item not in self.cache:
            self.cache[item] = {'src':file( os.path.join(self.prefix,item), "r" ).read()}
        
        return self.cache[item]

    def getTemplate(self, item):
        if "template" not in self[item]:
            mytemplate = Template(self[item]["src"],searchList=[SafeDict()])
            self[item]["template"] = mytemplate
            
        return self[item]["template"]




class Variable:
    def __init__(self, default, **args):
        self.forms = args
        self.default = default

    def __getitem__(self, name):
        try:
            return self.forms[name]
        except KeyError:
            return self.default

    def __str__(self):
        return str(self.default)

    def __repr__(self):
        return "<variable "+str(self.default)+" with forms "+repr(self.forms.items())+">"

    def html(self):
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
        return inlines.keyword(self.name,self.qNames[self.baseName])

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
    def __init__(self, definition, templateSet):
        self.definition = definition
        self.template = templateSet.getTemplate(definition)

    def findKeyword(self,keyword):
        theId = urlparse.urljoin(self.definition,keyword)
        if theId in self.keywordMap:
            return (theId, "keyword", self.keywordMap[theId])
        else:
            return ("unknown", "keyword unknown", theId)

    def html(self, keywordMap):
        renderedMap = {a:b.html() for (a,b) in keywordMap.items()}
        self.template.searchList()[0].update(renderedMap)
        return str(self.template)

class RuleSpec:
    def __init__(self, name, templatePrefix, **metadata):
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
        self.templateSet = TemplateSet(templatePrefix)
        self.metadata = metadata

    def addKeyword(self, localName, default, **args):
        self.variables[localName] = Variable(Keyword(default,self.qNames,localName), **{a:Keyword(b,self.qNames,localName) for (a,b) in args.items()})

    def addPiece(self, localName, colour, shape):
        self.variables[localName] = Variable(Piece(colour, shape))

    def addPhase(self,localName, qName, keywords={}):
        self.variables[localName] = Variable(Keyword(localName,self.qNames))
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        self.phaseTemplates[localName] = Rule(qName, self.templateSet)

    def addConstraint(self,phaseName, qName, keywords={}):
        # Constraints don't have visible names so just use the qName
        localName = qName
        self.variables[localName] = Variable(Keyword(localName,self.qNames))
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        if phaseName not in self.constraintTemplates:
            self.constraintTemplates[phaseName] = []
        self.constraintTemplates[phaseName].append( Rule(qName, self.templateSet) )    

    def addDef(self,localName, qName, keywords={}):
        self.qNames[localName] = qName
        self.keywordMaps[localName] = {"this":localName}
        self.keywordMaps[localName].update(keywords)
        self.defTemplates[localName] = Rule(qName, self.templateSet)

    def html(self):
        result = []

        result.append('<div class="phases"><dl>')
        for localName in self.phaseTemplates:
            keywordMap = SafeDict({a:self.variables[b] for (b,a) in self.qNames.items()})
            if self.keywordMaps[localName]:
                keywordMap.update( {a:self.variables[b] for (a,b) in self.keywordMaps[localName].items()} )

            result.extend([ '<dt><a name="phase-'+self.qNames[localName]+'"></a><span class="keyword">',localName,"</span></dt>",
                            "<dd>",self.phaseTemplates[localName].html(keywordMap),"</dd>" ])

            if localName in self.constraintTemplates:
                for constraint in self.constraintTemplates[localName]:
                    result.extend([ '<dt></dt>',
                                    "<dd>",constraint.html(keywordMap),"</dd>" ])

        result.append("</dl></div>")

        result.append('<div class="defs"><dl>')
        for localName in self.defTemplates:
            keywordMap = {a:self.variables[b] for (b,a) in self.qNames.items()}
            if self.keywordMaps[localName]:
                keywordMap.update( {a:self.variables[b] for (a,b) in self.keywordMaps[localName].items()} )

            result.extend([ '<dt><a name="keyword-'+self.qNames[localName]+'"></a><span class="keyword">',str(self.variables[localName].html()),"</span></dt>",
                            "<dd>",self.defTemplates[localName].html(keywordMap),"</dd>" ])
        result.append("</dl></div>")

        return "\n".join(result)