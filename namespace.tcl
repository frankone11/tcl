#!/usr/bin/tclsh

namespace eval MyMath {
   # Create a variable inside the namespace
   variable myResult
   namespace export Add
}

# Create procedures inside the namespace
proc MyMath::Add {a b } {  
   return [expr $a + $b]
}
namespace import MyMath::*
puts [Add 10 30]
namespace forget MyMath::*