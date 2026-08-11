# /Users/rajkumar/Desktop/helloworld/HelloWorld.tcl 
# Create the namespace
namespace eval ::HelloWorld {
 
  # Export MyProcedure
  namespace export MyProcedure
 
  # My Variables
   set version 1.0
   set MyDescription "HelloWorld"
 
  # Variable for the path of the script
   variable home [file join [pwd] [file dirname [info script]]]
 
}
 
# Definition of the procedure MyProcedure
proc ::HelloWorld::MyProcedure {} {
   puts $HelloWorld::MyDescription
}

package provide HelloWorld $HelloWorld::version
package require Tcl 8.0