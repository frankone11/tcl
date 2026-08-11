#!/usr/bin/wish

frame .myFrame1 -background red  -height 100 -width 100
frame .myFrame2 -background blue -height 100 -width 50
grid .myFrame1 -columnspan 10 -rowspan 10 -sticky w
grid .myFrame2 -column 10 -row 2