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
    def __init__(self, path):
        self.path = path

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

    def getTemplate(self, item):
        theRule = self[item]
        if "_template" not in theRule:
            mytemplate = Template(theRule["template"])
            theRule["_template"] = mytemplate
            
        return theRule["_template"]

    def getDefaults(self, item):
        theRule = self[item]
        return theRule.get("defaults", {})

    def getRole(self, item):
        theRule = self[item]
        return theRule["role"]


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

    def html(self,qNamesKnown):
        #sys.stderr.write(str(self.forms))
        return Variable(self.base.html(qNamesKnown), **{a:b.html(qNamesKnown) for (a,b) in self.forms.items()})

    def titleHtml(self,qNamesKnown):
        #sys.stderr.write(str(self.forms))
        return Variable(self.base.titleHtml(qNamesKnown), **{a:b.titleHtml(qNamesKnown) for (a,b) in self.forms.items()})

    def svg(self,qNamesKnown):
        return Variable(self.base.svg(qNamesKnown), **{a:b.svg(qNamesKnown) for (a,b) in self.forms.items()})

    def __lt__(self, other):
        return self.base < other.base

class Keyword:
    def __init__(self, qName, baseName=None):
        self.qName = qName

        if baseName is None:
            self.baseName = qName
        else:
            self.baseName = baseName

    def html(self, qNamesKnown):
        safeQName = self.qName.replace('/','-')
        if qNamesKnown and qNamesKnown[self.qName].visible:
            return inlines.link(self.baseName,safeQName,"link visibleLink")
        else:
            return inlines.link(self.baseName,safeQName,"link hiddenLink")

    def titleHtml(self, qNamesKnown):
        return self.html(qNamesKnown)

    def __str__(self):
        return "(("+self.qName +":"+self.baseName+"))"

    def __repr__(self):
        return "(("+self.qName +":"+self.baseName+"))"

    def __lt__(self, other):
        if isinstance(other, Keyword):
            return self.baseName < other.baseName
        else:
            return False

    def svg(self,qNamesKnown):
        return '<svg:text x="-4" y="4" font-size="8">%s</svg:text>' % self.baseName

class Piece(Keyword):
    SEQ = 0
    PIECES_FILE = ''
    #PIECES_FILE = "../rules/pieces.svg"

    def __init__(self, qName, colour, shape, baseName=None):
        Keyword.__init__(self, qName, baseName)
        self.colour = colour
        self.shape = shape

    def html(self, qNamesKnown):
        return '''
        <span class="svg" style="width: 20pt; height:20pt">
        <svg:svg version="1.1" viewBox="0 0 10 10">
            %s
        </svg:svg>
        </span>
    ''' % self.svg(qNamesKnown, 5, 5)

    def titleHtml(self, qNamesKnown):
        return ('''
        <span class="svg" style="width: 20pt; height:20pt">
        <svg:svg version="1.1" viewBox="0 0 10 10">
            %s
        </svg:svg>
        </span>
    = ''' % self.svg(qNamesKnown, 5, 5))+Keyword.html(self, None)

    def svg(self, qNamesKnown, x=0, y=0):
        Piece.SEQ += 1
        return '''
        <svg:g transform="translate(%d,%d)">
            <svg:clipPath id="local-clip-path-%d">
                <svg:use xlink:href="%s#path-%s"/>
            </svg:clipPath>
            <svg:g clip-path="url(#local-clip-path-%d)">
                <svg:use xlink:href="%s#fill-%s"/>
            </svg:g>
            <svg:use xlink:href="%s#%s"/>
        </svg:g>
''' % (x, y, Piece.SEQ, Piece.PIECES_FILE, self.shape, Piece.SEQ, Piece.PIECES_FILE, self.colour, Piece.PIECES_FILE, self.shape)

    def __str__(self):
        return "<<"+self.colour+" "+self.shape+">>"

    def __repr__(self):
        return "<<"+self.colour+" "+self.shape+">>"

    def __lt__(self, other):
        if isinstance(other, Piece):
            return self.shape < other.shape
        else:
            return False

class SquareBoard:
    BG_COLOUR = '#fff8e4'

    def __init__(self, width, height, spaces):
        self.width = width
        self.height = height
        self.spaces = spaces

    def html(self, qNamesKnown):
        return '''
    <span class="svg zoomTarget" style="width: %dpt; height: %dpt">
    <svg:svg version="1.1" viewBox="0 0 %d %d">
        %s
    </svg:svg>
    </span>
''' % ( self.width*20, self.height*20, self.width*10, self.height*10, self.svg(qNamesKnown) )

    def titleHtml(self, qNamesKnown):
        return "(board)"

    def svg(self, qNamesKnown):

        board = '''<svg:rect fill="%s" stroke="none" x="0" y="0" width="%d" height="%d"/>''' % (SquareBoard.BG_COLOUR, self.width*10, self.height*10)

        for location, obj in self.spaces.items():
            if obj:
                xy = location.split(',')
                board += '<svg:g transform="translate(%d %d)">%s</svg:g>' % (5+int(xy[0])*10,5+int(xy[1])*10,qNamesKnown[obj].localName.svg(qNamesKnown))

        board += '''<svg:rect fill="none" stroke="black" stroke-width="1" x="0" y="0" width="%d" height="%d"/>
<svg:g fill="none" stroke="black" stroke-width="0.2">''' % (self.width*10, self.height*10)

        for x in range(self.width):
            board += '<svg:line x1="%d" x2="%d" y1="0" y2="%d"/>' % (x*10, x*10, self.height*10)
        for y in range(self.height):
            board += '<svg:line x1="0" x2="%d" y1="%d" y2="%d"/>' % (self.width*10, y*10, y*10)
        board += '</svg:g>'


        return board

    def __str__(self):
        return "<<square board %s×%s>>" % (self.width, self.height)

    def __repr__(self):
        return "<<square board %s×%s>>" % (self.width, self.height)

    def __lt__(self, other):
        if isinstance(other, SquareBoard):
            return self.width < other.width
        else:
            return False

class Rule:
    def __init__(self, qName, ruleSet, order, visible=False, overrides=None):
        self.qName = qName
        self.ruleSet = ruleSet
        self.order = order
        self.localName = None
        self.visible = visible

        self.role = ruleSet.getRole(qName)
        # The template for the rule is not overridable - only fields inside the template
        # so we can get it straight away
        self.template = ruleSet.getTemplate(qName)

        # The map of template field to qName which applies to the rule
        # set it to a defaults which can be overridden later
        self.templateFields = ruleSet.getDefaults(qName)
        self.overrideFields(overrides)

    def setVisibility(self, visibility):
        # once visible, always visible
        if visibility == True:
            self.visible = True

    def setOrder(self, order):
        # the eventual order is whichever is lowest
        if order < self.order:
            self.order = order

    def overrideFields(self, overrides):
        if overrides:
            sys.stderr.write("\nUpdating %s with %s" % (pprint.pformat(self.templateFields), pprint.pformat(overrides)))
            self.templateFields.update(overrides)


    #def findKeyword(self,keyword):
    #    theId = urlparse.urljoin(self.qName,keyword)
    #    if theId in self.keywordMap:
    #        return (theId, "keyword", self.keywordMap[theId])
    #    else:
    #        return ("unknown", "keyword unknown", theId)


    #def getDefaultVarMap(self, item):
    #    theRule = self[item]
    #    if "_defaults" not in theRule:
    #        self.populateDefaults(item)
    #    defaults = theRule["_defaults"].copy()
    #    for key, value in theRule["_defaultQNames"].items():
    #        if key in self.qNames:
    #            defaults[value] = self.qNames[key]
    #            sys.stderr.write("\nAdding override for %s to %s" % (key, item))
    #    sys.stderr.write("\nDefault var map is %s" % pprint.pformat(defaults))
    #    return defaults

    #def getDefaultQNames(self, item):
    #    theRule = self[item]
    #    if "_defaults" not in theRule:
    #        self.populateDefaults(item)
    #    return theRule["_defaultQNames"]

    def getTemplateFields(self):
        # return the field names and qNames, for which we need to have a corresponding Variable
        return self.templateFields

    def html(self, qNamesKnown):
        # qNamesKnown is the map of qName to Variable which will be used to render the rule
        # This must include a Variable for each qName in self.templateFields.values()
        sys.stderr.write("\nRendering %s" % self)
        renderedVars = {a:qNamesKnown[b].localName.html(qNamesKnown) for (a,b) in self.templateFields.items()}
    
        return self.template.render_unicode(**renderedVars)

    def titleHtml(self, qNamesKnown):
        return self.localName.titleHtml(None).base


    def __lt__(self, other):
        if self.order == other.order:
            return self.qName < other.qName
        return self.order < other.order

    def __repr__(self):
        if self.visible:
            isVisible = "visible"
        else:
            isVisible = "hidden"
        return "<%s rule %s (%s)>" % (isVisible, self.qName, self.localName)

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


        if source:
            theme['source'] = source

        defs = theme.pop('defs')

        ruleSpec = cclass( name, os.path.join(ruleRoot,locale), **theme )

        
        for qName, phaseSpec in game['rules'].items():
            if phaseSpec is None:
                ruleSpec.addPhase(qName)
            else:            
                ruleSpec.addPhase(qName, phaseSpec.get('order',LAST), phaseSpec.get('vars',{}))

            if 'constraints' in phaseSpec:
                for cqName, constraintSpec in phaseSpec['constraints'].items():
                    if constraintSpec is None:
                        ruleSpec.addConstraint(qName, cqName)
                    else:            
                        ruleSpec.addConstraint(qName, cqName, constraintSpec.get('order',LAST), constraintSpec.get('vars',{}))

        for qName, defSpec in game['defs'].items():
            if defSpec is None:
                ruleSpec.addDef(qName)
            else:
                ruleSpec.addDef(qName, defSpec.get('order',LAST), vars=defSpec.get('vars',{}))

        ruleSpec.applyTheme(defs)

        return ruleSpec
        

    def __init__(self, name, rulePath, **metadata):

        # key: qName
        # value: Rule instance
        # for every referenced qName
        self.rules = {}

        self.defTemplates = []
        self.phaseTemplates = []
        self.constraintTemplates = {}

        self.name = name
        self.ruleSet = RuleSet(rulePath)
        self.metadata = metadata


    def applyTheme(self, theme):
        for qName in self.rules:
            if qName in theme:
                self.setRuleName(qName, theme[qName])
            else:
                self.setRuleName(qName, self.ruleSet[qName])
        sys.stderr.write("\nApplied theme: rules now %s" % pprint.pformat(self.rules))

    def setRuleName(self, qName, localName):
        self.rules[qName].localName = self.getVariable(qName,localName)


    def addRule(self, qName, order=LAST, visibility=False, vars=None):
        if qName in self.rules:
            sys.stderr.write('\nAlready have rule %s' % qName)
            rule = self.rules[qName]
            rule.setOrder(order)
            rule.setVisibility(visibility)
            rule.overrideFields(vars)
        else:
            sys.stderr.write('\nNew rule %s' % qName)
            rule = Rule(qName, self.ruleSet, order, visibility, vars) 
            self.rules[qName] = rule

            if rule.role == 'phase':
                self.phaseTemplates.append( qName )
            elif rule.role == 'definition':
                self.defTemplates.append( qName )


        sys.stderr.write('\nvars for %s were %s' % (qName, vars))
        for templateName, qName in rule.getTemplateFields().items():
            if vars and templateName in vars:
                sys.stderr.write('\nInvestigating game-rule %s' % vars[templateName])
                self.addDef(vars[templateName],visibility=False)
            else:
                sys.stderr.write('\nInvestigating default-rule %s' % qName)
                self.addDef(qName,visibility=False)


    def getVariable(self, qName, spec):
        #sys.stderr.write("\nBuilding keyword for %s from %s" % (qName,pprint.pformat(spec)))
        t_ype = spec.get('type','keyword')
        if t_ype=='piece':
            return self.getPieceVar(qName, spec['colour'], spec['shape'], spec.get('base',None), spec.get('forms',{}))
        elif t_ype=='keyword':
            return self.getKeywordVar(qName, spec.get('base','['+qName+']'), spec.get('forms',{}))
        elif t_ype=='board':
            return self.getBoardVar(qName, spec)
        else:
            raise ValueError("Unsupported keyword-type %s" % t_ype)


    def getKeywordVar(self, qName, base, forms):
        return Variable(Keyword(qName, base), **{a:Keyword(qName, b) for (a,b) in forms.items()})

    def getPieceVar(self, qName, colour, shape, base, forms):
        return Variable(Piece(qName, colour, shape, base), **{a:Piece(qName, colour, shape, b) for (a,b) in forms.items()})

    def getBoardVar(self, qName, spec):
        geometry = spec.pop('geometry')
        if geometry=='square':
            return Variable(SquareBoard(spec['width'], spec['height'], spec['spaces']))
        else:
            raise ValueError("Unsupported board-geometry %s" % geometry)

    def addPhase(self, qName, order=LAST, vars=None):
        self.addRule(qName, order, True, vars)

    def addConstraint(self, phaseName, qName, order=LAST, vars=None):
        # does not automatically add, as is child of a phase
        if phaseName not in self.constraintTemplates:
            self.constraintTemplates[phaseName] = []
        if qName not in self.constraintTemplates[phaseName]:
            self.constraintTemplates[phaseName].append( qName )
        self.addRule(qName, order, True, vars)

    def addDef(self, qName, order=LAST, visibility=True, vars=None):
        self.addRule(qName, order, visibility, vars)



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

        myRules = []
        for ruleQName in self.phaseTemplates:
            rule = self.rules[ruleQName]
            myRules.append(rule)

        for index, rule in enumerate(sorted(myRules)):
            if rule.visible:
                visibilityClass = "visible"
            else:
                visibilityClass = "hidden"
            safeQName = rule.qName.replace('/','-')
            result.extend([ '<dt id="dt-'+safeQName+'" class="'+visibilityClass+'"><a name="keyword-'+safeQName+'"></a><span class="keyword">',rule.titleHtml( self.rules ),"</span></dt>",
                            '<dd id="dd-'+safeQName+'" class="'+visibilityClass+'">',rule.html( self.rules ),"</dd>" ])

            if rule.qName in self.constraintTemplates:
                myConstraints = []
                for constraintQName in self.constraintTemplates[rule.qName]:
                    constraint = self.rules[constraintQName]
                    myConstraints.append(constraint)
                for constraint in sorted(myConstraints):
                    result.extend([ '<dt></dt>',
                                    "<dd>",constraint.html( self.rules ),"</dd>" ])

        result.append("</dl></td>")

        result.append('<td class="defs"><dl>')

        myDefs = []
        for ruleQName in self.defTemplates:
            rule = self.rules[ruleQName]
            myDefs.append(rule)

        for rule in sorted(myDefs):
            if rule.visible:
                visibilityClass = "visible"
            else:
                visibilityClass = "hidden"
            safeQName = rule.qName.replace('/','-')
            result.extend([ '<dt id="dt-'+safeQName+'" class="'+visibilityClass+'"><a name="keyword-'+safeQName+'"></a><span class="keyword">',rule.titleHtml( self.rules ),"</span></dt>",
                            '<dd id="dd-'+safeQName+'" class="'+visibilityClass+'">',rule.html( self.rules ),"</dd>" ])
        result.append("</dl></td></tr></table>")

        
        
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
