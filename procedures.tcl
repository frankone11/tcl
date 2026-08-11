#!/usr/bin/tclsh

proc helloWorld {} {
   puts "Hello, World!"
}
helloWorld

proc add {a b} {
   return [expr $a+$b]
}
puts [add 10 30]

proc avg {numbers} {
   set sum 0
   foreach number $numbers {
      set sum  [expr $sum + $number]
   }
   set average [expr $sum/[llength $numbers]]
   return $average
}
puts [avg {70 80 50 60}]
puts [avg {70 80 50 }]