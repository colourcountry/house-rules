#!/usr/bin/python

def player(colour="grey"):
    return piece(colour, "player")


def piece(colour="grey", shape="rook"):
    return '''
    <span class="svg">
    <svg:svg viewBox="0 0 10 10">
        <svg:g transform="translate(5,5)">
            <svg:g clip-path="url(../rules/pieces.svg#clip-path-%s)">
                <svg:use xlink:href="../rules/pieces.svg#fill-%s"/>
            </svg:g>
            <svg:use xlink:href="../rules/pieces.svg#%s"/>
        </svg:g>
    </svg:svg>
    </span>
''' % (shape, colour, shape)


def link(name,link,cclass="link"):
    return '''
    <a href="#keyword-%s" class="%s">%s</a>
''' % (link,cclass,name)

def keyword(name,cclass="keyword"):
    return '''
    <span class="%s">%s</span>
''' % (cclass,name)
