#!/usr/bin/tclsh

# import pdf4tcl
package require pdf4tcl

# create a pdf object
pdf4tcl::new mypdf -paper a4 -margin 15mm

# add the first page
mypdf startPage
set width [lindex [mypdf getDrawableArea] 0]

# draw a line, coordinates start in upper left corner of the paper,
# unit is postscript point, which is 1/72 inch
mypdf line 0 0 $width 0

# draw some text
mypdf setFont 8 Helvetica
mypdf text "sample text" -x 0 -y 12

# use another font and draw centered text
mypdf setFont 12 "Helvetica-Bold"
mypdf text "Sample Heading" -align center -x [expr {$width/2.0}] -y 12 

# and some right aligned text
mypdf setFont 8 Helvetica
mypdf text "page 1" -align right -x $width -y 12

# draw a rectangle with dashed red outline and lightgrey fill colour
mypdf setLineStyle 0.5 8 4
mypdf setStrokeColor 0.8 0 0
mypdf setFillColor 0.9 0.9 0.9
mypdf rectangle 20 50 300 100 -filled 1

# set some justified text into this box
mypdf setFillColor 0 0 0
mypdf drawTextBox 21 51 299 99 "This is just some senseless sample text,\
	illustrating some features of pdf4tcl. This text should be justified\
	by stretching white space between words, to make for straight left\
	and right margins." -align justify

# write pdf to a file
mypdf write -file mypdf.pdf

# cleanup memory and unset procedures and variables
mypdf destroy