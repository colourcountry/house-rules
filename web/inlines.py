#!/usr/bin/python

BG_COLOUR = '#ffeecc'
PIECES_FILE = ''
#PIECES_FILE = "../rules/pieces.svg"
SEQ = 1000

def player(colour):
    return piece(colour, "player")

def piece(x, y, colour, shape):
    return '''
    <span class="svg" style="width: 20pt; height:20pt">
    <svg:svg version="1.1" viewBox="0 0 10 10">
        %s
    </svg:svg>
    </span>
''' % svgPiece(x+5, y+5, colour, shape)

def svgPiece(x, y, colour, shape):
    global SEQ
    SEQ += 1
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
''' % (x, y, SEQ, PIECES_FILE, shape, SEQ, PIECES_FILE, colour, PIECES_FILE, shape)

def squareBoard(width, height, squares):
    return '''
    <span class="svg" style="width: %dpt; height: %dpt">
    <svg:svg version="1.1" viewBox="0 0 %d %d">
        %s
    </svg:svg>
    </span>
''' % ( width*20, height*20, width*10, height*10, svgSquareBoard(width, height, squares) )

def svgSquareBoard(width, height, squares):
    board = '''<svg:rect fill="%s" stroke="black" stroke-width="1" x="0" y="0" width="%d" height="%d"/>
<svg:g fill="none" stroke="black" stroke-width="0.2">''' % (BG_COLOUR, width*10, height*10)
    for x in range(width):
        board += '<svg:line x1="%d" x2="%d" y1="0" y2="%d"/>' % (x*10, x*10, height*10)
    for y in range(height):
        board += '<svg:line x1="0" x2="%d" y1="%d" y2="%d"/>' % (width*10, y*10, y*10)
    board += '</svg:g>'

    return board


def link(name,link,cclass="link"):
    return '''
    <a href="#keyword-%s" class="%s">%s</a>
''' % (link,cclass,name)

def keyword(name,cclass="keyword"):
    return '''
    <span class="%s">%s</span>
''' % (cclass,name)
