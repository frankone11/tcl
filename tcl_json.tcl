package require json::write

set datitos {{nombre {Prime Video} costo 25.0 fecha 17/07/2026} {nombre Netflix costo 32.0 fecha 17/07/2026} {nombre {HBO Max} costo 40.0 fecha 18/07/2026}}

::json::write indented 1
::json::write aligned 1

proc json_parser {data} {
	set myobject "\[\n"
	set datalength [llength $data]
	for {set i 0} {$i < $datalength} {incr i} {
		set myobject [append myobject [::json::write object-strings "nombre" [dict get [lindex $data $i] nombre] "costo" [dict get [lindex $data $i] costo] "fecha" [dict get [lindex $data $i] fecha] ] ]
		if {$i < [expr {$datalength - 1}]} {
			set myobject [append myobject ",\n"]
		}
	}
	set myobject [append myobject "\n\]"]
	return $myobject
}
puts [json_parser $datitos]
