#!/usr/bin/wish

image create photo imgobj -file "./vampiro.png" -width 512 -height 512 
pack [label .myLabel]
.myLabel configure -image imgobj 
puts [image height imgobj]
puts [image width imgobj]
puts [image type imgobj]
puts [image names]
# image delete imgobj