#!/usr/bin/wish

proc addText {} {
   label .myLabel -text "Hello................" -width 25
   pack .myLabel
}
after 1000 addText
#after cancel addText
