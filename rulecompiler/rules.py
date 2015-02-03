#!/usr/bin/python
#coding: utf-8

from mako.template import Template
import rulecompiler.inlines as inlines

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

LAST = -1
SVG_NS = 'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'

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
                try:
                    self.cache[item] = json.loads( open( os.path.join(self.path,item), "r", encoding="utf-8").read() )
                except Exception as e:
                    raise ValueError("error reading rule %s: %s" % (item, e))
            else:
                try:
                    self.cache[item] = json.loads( open( os.path.join(self.path,item), "r" ).read().decode("utf-8") )
                except Exception as e:
                    raise ValueError("error reading rule %s: %s" % (item, e))
            sys.stderr.write("\ncached %s" % item)
            
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
    def __init__(self, base, fallback, **args):
        self.forms = args

        # The fallback is used if the result would be empty, or if the form specified is not available
        self.fallback = fallback

        # The base is used when no specific form is indicated
        self.base = base or fallback


    def __getattr__(self, name):
        try:
            return self.forms[name] or self.fallback
        except KeyError:
            return self.fallback

    def __str__(self):
        return str(self.base)

    def __repr__(self):
        return "<variable "+str(self.base)+" with forms "+repr(self.forms.items())+">"

    def html(self,qNamesKnown,fallback=None):
        #sys.stderr.write(str(self.forms))
        return Variable(self.base.html(qNamesKnown), fallback or self.fallback, **{a:b.html(qNamesKnown) for (a,b) in self.forms.items()})

    def titleHtml(self,qNamesKnown,fallback=None):
        #sys.stderr.write(str(self.forms))
        return Variable(self.base.titleHtml(qNamesKnown), fallback or self.fallback, **{a:b.titleHtml(qNamesKnown) for (a,b) in self.forms.items()})

    def svg(self,qNamesKnown,fallback=None):
        return Variable(self.base.svg(qNamesKnown), fallback or self.fallback, **{a:b.svg(qNamesKnown) for (a,b) in self.forms.items()})

    def __lt__(self, other):
        return self.base < other.base

class Keyword:
    def __init__(self, qName, baseName=None):
        self.qName = qName
        self.baseName = baseName or qName

    def html(self, qNamesKnown, fallback=""):
        safeQName = self.qName.replace('/','-')
        if qNamesKnown and qNamesKnown[self.qName].visible:
            return inlines.link(self.baseName or fallback,safeQName,"link visibleLink")
        else:
            return inlines.link(self.baseName or fallback,safeQName,"link hiddenLink")

    def titleHtml(self, qNamesKnown, fallback=""):
        return self.html(qNamesKnown, fallback)

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
        return '<text x="-4" y="4" font-size="8">%s</text>' % self.baseName

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
        <span class="svg" style="width: 20pt; height:20pt" %s>
        <svg version="1.1" viewBox="0 0 10 10">
            %s
        </svg>
        </span>
    ''' % (SVG_NS,self.svg(qNamesKnown, 5, 5))

    def titleHtml(self, qNamesKnown, fallback=""):
        # TODO: figure out sensible fallback behaviour
        return ('''
        <span class="svg" style="width: 20pt; height:20pt" %s>
        <svg version="1.1" viewBox="0 0 10 10">
            %s
        </svg>
        </span>
    = ''' % (SVG_NS,self.svg(qNamesKnown, 5, 5))+Keyword.html(self, None))

    def svg(self, qNamesKnown, x=0, y=0):
        Piece.SEQ += 1
        return '''
        <g transform="translate(%d,%d)">
            <clipPath id="local-clip-path-%d">
                <use xlink:href="%s#path-%s"/>
            </clipPath>
            <g clip-path="url(#local-clip-path-%d)">
                <use xlink:href="%s#fill-%s"/>
            </g>
            <use xlink:href="%s#%s"/>
        </g>
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
    BG_COLOUR = '#fff'
    SCALE = 1.2

    def __init__(self, width, height, spaces, edges=None):
        self.width = width
        self.height = height
        self.spaces = spaces
        self.edges = edges

    def html(self, qNamesKnown):
        return '''
    <span class="svg zoomTarget" style="width: %dpt; height: %dpt" %s>
    <svg version="1.1" viewBox="0 0 %d %d">
        %s
    </svg>
    </span>
''' % ( (self.width*10+20)*SquareBoard.SCALE, (self.height*10+20)*SquareBoard.SCALE, SVG_NS, self.width*10+20, self.height*10+20, self.svg(qNamesKnown) )

    def titleHtml(self, qNamesKnown, fallback=""):
        return "(board)"

    def svg(self, qNamesKnown):
        board = ''

        if self.edges:
            if "north" in self.edges:
                obj = self.edges["north"]
                board += '<g transform="translate(%d %d) scale(0.7)">%s</g>' % (self.width*5+10,5,qNamesKnown[obj].localName.svg(qNamesKnown))
            if "south" in self.edges:
                obj = self.edges["south"]
                board += '<g transform="translate(%d %d) scale(0.7)">%s</g>' % (self.width*5+10,self.height*10+15,qNamesKnown[obj].localName.svg(qNamesKnown))
            if "east" in self.edges:
                obj = self.edges["east"]
                board += '<g transform="translate(%d %d) scale(0.7)">%s</g>' % (self.width*10+15,self.height*5+10,qNamesKnown[obj].localName.svg(qNamesKnown))
            if "west" in self.edges:
                obj = self.edges["west"]
                board += '<g transform="translate(%d %d) scale(0.7)">%s</g>' % (5,self.height*5+10,qNamesKnown[obj].localName.svg(qNamesKnown))

        board += '<g transform="translate(10 10)">'
        
        board += '''<rect fill="%s" stroke="none" x="0" y="0" width="%d" height="%d"/>''' % (SquareBoard.BG_COLOUR, self.width*10, self.height*10)

        for location, obj in self.spaces.items():
            if obj:
                xy = self.getXy(location)
                if not isinstance(obj, list):
                    obj = [obj]
                for item in obj:
                    board += '<g transform="translate(%d %d)">%s</g>' % (5+int(xy[0])*10,5+int(xy[1])*10,qNamesKnown[item].localName.svg(qNamesKnown))

        board += '''<rect fill="none" stroke="black" stroke-width="1" x="0" y="0" width="%d" height="%d"/>
<g fill="none" stroke="black" stroke-width="0.2">''' % (self.width*10, self.height*10)

        for x in range(self.width):
            board += '<line x1="%d" x2="%d" y1="0" y2="%d"/>' % (x*10, x*10, self.height*10)
        for y in range(self.height):
            board += '<line x1="0" x2="%d" y1="%d" y2="%d"/>' % (self.width*10, y*10, y*10)

        board += '</g></g>'


        return board

    def getXy(self, location):
        # Return x,y given a location specifier in the forms
        # N,N = direct coordinate (0,0 at top left)
        # aN  = chess style (a1 at bottom left)
        if "," in location:
            return location.split(',')
        else:
            x = (ord(location[0])+31) % 32
            y = self.height - int(location[1:])
            return x,y

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

        try:
            return self.template.render_unicode(**renderedVars)
        except NameError:
            # mako doesn't tell us what variable is missing
            raise NameError("Can't render %s: missing variable definition" % self.qName)

    def titleHtml(self, qNamesKnown, fallback=""):
        return self.localName.titleHtml(None, fallback).base or fallback


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

class FullSpec:
    @classmethod
    def fromJson( cclass, theme, ruleRoot, gameRoot, source=None  ):

        if PYTHON3:
            try:
                gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r', encoding="utf-8" )
            except Exception as e:
                raise NotFound("game %s not found: %s" % (theme['rules'], e))
            try:
                game = json.loads( gameFile.read() )
            except Exception as e:
                raise ValueError("error reading game %s: %s" % (theme['rules'], e))

        else:
            try:
                gameFile = open(os.path.join( gameRoot, theme['rules'] ), 'r')
            except Exception as e:
                raise NotFound("game %s not found: %s" % (theme['rules'], e))
            try:
                game = json.loads( gameFile.read().decode("utf-8") )
            except Exception as e:
                raise ValueError("error reading game %s: %s" % (theme['rules'], e))

        results = {}

        locale = theme['locale']

        name = theme.pop('name')


        if source:
            theme['source'] = source

        defs = theme.pop('defs')

        fullSpec = cclass( name, os.path.join(ruleRoot,locale), **theme )

        for (specializeFrom, specializeTo) in game.get('specializations',{}).items():
            fullSpec.addSpecialization(specializeFrom,specializeTo)
        
        sys.stderr.write("specializations are %s" % fullSpec.specializations)

        for ruleSpec in game['rules']:
            qName = ruleSpec['src']
            fullSpec.addRule(qName, ruleSpec.get('order',LAST), True, ruleSpec.get('vars',{}))

            if 'constraints' in ruleSpec:
                for constraintSpec in ruleSpec['constraints']:
                    fullSpec.addConstraint(qName, constraintSpec['src'], constraintSpec.get('order',LAST), constraintSpec.get('vars',{}))

        # apply the theme
        fullSpec.applyTheme(defs)

        # make references to generic rules point to the corresponding specialized rule
        # we assume that themed rules are naturally going to be specialized so won't normally be overridden
        fullSpec.applySpecializations()

        return fullSpec
        

    def __init__(self, name, rulePath, **metadata):

        # key: qName
        # value: Rule instance
        # for every referenced qName
        self.rules = {}

        # key: qName (search)
        # value: qName (replace)
        # for qNames which should be replaced with less generic ones wherever they appear
        self.specializations = {}

        self.constraintTemplates = {}

        self.name = name
        self.ruleSet = RuleSet(rulePath)
        self.metadata = metadata


    def applySpecializations(self):
        for specializeFrom in self.specializations.keys():
            specializeTo = self.specialize(specializeFrom)
            sys.stderr.write("\n%s specialized to %s" % (specializeFrom, specializeTo))
            if specializeTo not in self.rules:
                sys.stderr.write("\nEMERGENCY: didn't have %s, pulling it in" % specializeTo)
                self.addRule(specializeTo, LAST, True, {})
                self.setRuleName(specializeTo, self.ruleSet[specializeTo])
            self.rules[specializeFrom] = self.rules[specializeTo]

    def applyTheme(self, theme):
        fullTheme = theme.copy()
        # if a theme is applied to a generic, 
        # it also themes specialized rules derived from it
        # which don't have a specific theme
        for specializeFrom in theme:
            specializeTo = self.specialize(specializeFrom)
            if specializeTo != specializeFrom and specializeTo not in theme:
                fullTheme[specializeTo] = theme[specializeFrom]

        for qName in self.rules:
            if qName in fullTheme:
                self.setRuleName(qName, fullTheme[qName])
            else:
                self.setRuleName(qName, self.ruleSet[qName])
        sys.stderr.write("\nApplied theme: rules now %s" % pprint.pformat(self.rules))

    def setRuleName(self, qName, localName):
        self.rules[qName].localName = self.getVariable(qName,localName)


    def addRule(self, qName, order=LAST, visibility=False, vars=None):
        qName = self.specialize(qName)
        if order==LAST:
            order = len(self.rules)
        if qName in self.rules:
            sys.stderr.write('\nAlready have rule %s' % qName)
            rule = self.rules[qName]
            rule.setVisibility(visibility)
            rule.overrideFields(vars)
            if vars:
                for templateName, fieldQName in rule.getTemplateFields().items():
                    if templateName in vars:
                        sys.stderr.write('\nInvestigating game-rule %s' % vars[templateName])
                        self.addDef(vars[templateName],visibility=False)
        else:
            sys.stderr.write('\nNew rule %s' % qName)
            rule = Rule(qName, self.ruleSet, order, visibility, vars) 
            self.rules[qName] = rule

            #self.ruleTemplates.append( qName )

            sys.stderr.write('\nvars for %s were %s' % (qName, vars))
            for templateName, fieldQName in rule.getTemplateFields().items():
                if vars and templateName in vars:
                    sys.stderr.write('\nInvestigating game-rule %s' % vars[templateName])
                    self.addDef(vars[templateName],visibility=False)
                else:
                    sys.stderr.write('\nInvestigating default-rule %s' % fieldQName)
                    self.addDef(fieldQName,visibility=False)


    def getVariable(self, qName, spec):
        #sys.stderr.write("\nBuilding keyword for %s from %s" % (qName,pprint.pformat(spec)))
        t_ype = spec.get('type','keyword')
        if t_ype=='piece':
            return self.getPieceVar(qName, spec['colour'], spec['shape'], spec.get('base','!missing base form for %s!' % qName), spec.get('forms',{}))
        elif t_ype=='keyword':
            return self.getKeywordVar(qName, spec.get('base','['+qName+']'), spec.get('forms',{}))
        elif t_ype=='board':
            return self.getBoardVar(qName, spec)
        else:
            raise ValueError("Unsupported keyword-type %s" % t_ype)


    def getKeywordVar(self, qName, base, forms):
        return Variable(Keyword(qName, base), base, **{a:Keyword(qName, b) for (a,b) in forms.items()})

    def getPieceVar(self, qName, colour, shape, base, forms):
        # A piecevar yields a pictorial piece if used directly, but a word if used in one of its forms
        return Variable(Piece(qName, colour, shape, base), base, **{a:Keyword(qName, b) for (a,b) in forms.items()})

    def getBoardVar(self, qName, spec):
        geometry = spec.pop('geometry')
        if geometry=='square':
            return Variable(SquareBoard(spec['width'], spec['height'], spec['spaces'], spec.get('edges',None)),
                            "%s &#x27a1; %s square board" % (spec['width'],spec['height']))
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

    def addSpecialization(self, specializeFrom, specializeTo):
        # Wherever qName 'from' is encountered, replace with 'to'.
        # This allows you to use generic defs on a game-by-game basis
        # replacing the generic part with something appropriate to the game
        self.specializations[specializeFrom] = specializeTo
    
    def addDef(self, qName, order=LAST, visibility=True, vars=None):
        self.addRule(qName, order, visibility, vars)

    def specialize(self, qName):
        # Return the specialized version of a generic qName.
        # As a side-effect, if a chain is encountered, replace with the chain end.
        specializedName = qName
        while specializedName in self.specializations:
            specializedName = self.specializations[specializedName]
        if specializedName != qName:
            sys.stderr.write("\nSpecialized %s to %s" % (qName, specializedName))
            self.specializations[qName] = specializedName
        return specializedName

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

        result.append('<dl class="rules">')

        myRules = self.rules

        for index, rule in enumerate(sorted(set(myRules.values()))):

            if rule.visible:
                visibilityClass = "visible"
            else:
                visibilityClass = "hidden"

            if rule.role == "phase":
                safeQName = rule.qName.replace('/','-')
                result.extend([ '<dt id="dt-'+safeQName+'" class="'+visibilityClass+'"><a name="keyword-'+safeQName+'"></a><span class="keyword">',rule.titleHtml( myRules, fallback="&#x2022;" ),"</span></dt>",
                                '<dd id="dd-'+safeQName+'" class="'+visibilityClass+'">',rule.html( myRules ),"</dd>" ])

                if rule.qName in self.constraintTemplates:
                    myConstraints = []
                    for constraintQName in self.constraintTemplates[rule.qName]:
                        constraint = myRules[constraintQName]
                        myConstraints.append(constraint)
                    for constraint in sorted(myConstraints):
                        result.extend([ '<dt>&#x2022;</dt>',
                                        '<dd class="visible">',constraint.html( myRules ),"</dd>" ])

            elif rule.role == "definition":
                safeQName = rule.qName.replace('/','-')
                result.extend([ '<dt id="dt-'+safeQName+'" class="'+visibilityClass+'"><a name="keyword-'+safeQName+'"></a><span class="keyword">',rule.titleHtml( myRules ),"</span></dt>",
                                '<dd id="dd-'+safeQName+'" class="'+visibilityClass+'">',rule.html( myRules ),"</dd>" ])

        result.append("</dl>")

        
        
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
