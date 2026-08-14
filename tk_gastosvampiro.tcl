#!/usr/bin/tclsh

package require Tcl
package require Tk
package require json
package require json::write

# ----- Paleta de colores -----
set BG_MAIN 	"#EEE9FE" ;# Fondo principal lavanda suave
set BG_WHITE 	"#FCFCFD" ;# Tarjetas y superficies blancas
set ACCENT		"#7C4DFF" ;# Púrpura vibrante - color principal
set GREEN		"#00C9A7" ;# Verde menta - acciones positivas
set CORAL		"#FF6B6B" ;# Coral - acciones descriptivas / alertas
set TEXT_DARK	"#06040D" ;# Texto principal oscuro
set TEXT_LIGHT	"#FAFAFA" ;# Texto secundario, placeholders, bordes, sombras
set TEXT_WHITE	"#FFFFFF" ;# Texto blanco

# Colores derivados

set ACCENT_HOVER	"#651FFF" ;# Acento más oscuro para hover
set GREEN_HOVER		"#00B396" ;# Verde más oscuro para hover
set CORAL_HOVER		"#E55A5A" ;# Coral más oscuro para hover
set BG_ENTRY		"#F0ECFA" ;# Fondo sutil para entradas de texto
set BORDER_LIGHT	"#D8D3E8" ;# Borde suave para entradas de texto

# Ruta de datos
set RUTA_DATOS "gastos.json"

#variables globales
set suscripciones {}

# Procedimientos

proc _salir {} {
	if { [tk_messageBox -message "Salir" -detail "¿Estás seguro de que quieres salir?" -title "Gastos Vampiro" -icon question -type okcancel] == "ok"} {
		destroy .
	}
}

proc _exportar_pdf {} {
	tk_messageBox -message "Error" -detail "No implementado" -title "Gastos Vampiro" -icon error
}

proc _mostrar_acerca_de {} {
	tk_messageBox -message "Acerca de Gastos Vampiro" -icon info -detail "Gastos vampiro v1.0\nRastreador de suscripciones que\nchupan tu dinero\nDesarrollado con TCL/TK" -title "Acerca de..."
}

proc _actualizar_tabla {} {
	.frame.frmtabla.frame.tree delete [.frame.frmtabla.frame.tree children {}]

	set total 0.00

	if {[llength $::suscripciones] > 0} {
		place forget .frame.frmtabla.frame.lbl_vacio

		for {set i 0} {$i < [llength $::suscripciones]} {incr i} {
			set costo [expr {double([dict get [lindex $::suscripciones $i] costo])}]
			set total [expr {$costo + $total}]
			.frame.frmtabla.frame.tree insert {} end -text "" -values [list [expr {$i + 1}] [dict get [lindex $::suscripciones $i] nombre] $costo [dict get [lindex $::suscripciones $i] fecha] ]
		}
	} else {
		place .frame.frmtabla.frame.lbl_vacio -relx 0.5 -rely 0.5 -anchor "center"
	}

	.frame.frmtabla.resumen.lbl_total configure -text "Total Mensual: \$[format "%.2f" $total] MXN"

	if {$total > 0} {
		.frame.frmtabla.footer.lbl_anual configure -text "Gasto anual estimado: \$[format "%.2f" [expr $total * 12]] MXN"
	} else {
		.frame.frmtabla.footer.lbl_anual configure -text ""
	}

	wm title . "Gastos vampiro - \$[format "%.2f" $total] MXN/mes"

}

proc _eliminar_suscripcion {} {
	set seleccion [.frame.frmtabla.frame.tree selection]

	if {[llength $seleccion] <= 0} {
		tk_messageBox -message "Sin selección." -detail "Selecciona una suscripción de la tabla para eliminarla." -title "Error" -icon warning -type ok
		return {}
	}

	set valores [.frame.frmtabla.frame.tree item [lindex $seleccion 0] -values]
	set nombre [lindex $valores 1]

	set confirmar [tk_messageBox -message "Confirmar eliminación." -detail "¿Eliminar la suscripción $nombre?" -title "Confirmar eliminación" -icon warning -type yesno]
	if {$confirmar == "yes"} {
		set idx [expr {[lindex $valores 0] - 1}]
		if { [expr 0 <= $idx] || [expr $idx < [llength $::suscripciones]]} {
			set ::suscripciones [lreplace $::suscripciones $idx $idx]
			_guardar_suscripciones $::suscripciones
			_actualizar_tabla
		}
	}

}

proc _cargar_suscripciones {} {
	if {[file exists $::RUTA_DATOS] && [file isfile $::RUTA_DATOS]} {
		set fp [open $::RUTA_DATOS r]
		set datos [read $fp]
		close $fp

		return [::json::json2dict $datos]
	} else {
		puts "File doesn't exist."
		return {}
	}
}

proc json_parser {data} {
	::json::write indented 1
	::json::write aligned 1
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

proc _guardar_suscripciones {data} {
	set fp [open $::RUTA_DATOS w+]
	puts $fp [json_parser $data]
	close $fp
}

proc _agregar_suscripcion {} {
	set nombre [string trim [.frame.formulario.entry_nombre get] " "]
	set costo_str [string trim [.frame.formulario.entry_costo get] " "]

	if {$nombre eq ""} {
		tk_messageBox -message "Campo vacío." -detail "Por favor ingrese el nombre de la suscripción." -title "Error" -icon warning -type ok
		focus .frame.formulario.entry_nombre
		return {}
	}

	if {$costo_str eq ""} {
		tk_messageBox -message "Campo vacío." -detail "Por favor ingrese el costo de la suscripción." -title "Error" -icon warning -type ok
		focus .frame.formulario.entry_costo
		return {}
	}

	if {[string is double -strict $costo_str]} {
		set costo [expr {double($costo_str)}]
	} else {
		tk_messageBox -message "Error de formato." -detail "$costo_str no es un número válido.\n\nEjemplo: 15.99" -title "Error" -icon error -type ok
		.frame.formulario.entry_costo delete 0 end
		focus .entry_costo
		return {}
	}

	set fecha [clock format [clock seconds] -format "%d/%m/%Y"]

	set suscripcion [dict create nombre $nombre costo $costo fecha $fecha]

	lappend ::suscripciones $suscripcion

	_guardar_suscripciones $::suscripciones

	.frame.formulario.entry_nombre delete 0 end
	.frame.formulario.entry_costo delete 0 end
	focus .frame.formulario.entry_nombre

	_actualizar_tabla	
}

# Ventana principal

wm title . "Gastos vampiro"
wm geometry . 700x680
wm resizable . 0 0

image create photo icon -file "vampiro.png"
wm iconphoto . -default icon

# Aplicar estilos
ttk::style theme use clam

ttk::style configure Main.TFrame -background $BG_MAIN
ttk::style configure Header.TFrame -background $ACCENT
ttk::style configure HeaderTitle.TLabel -background $ACCENT -foreground $BG_WHITE -font {"Segoe UI" 30 "bold"}
ttk::style configure HeaderSubTitle.TLabel -background $ACCENT -foreground $BG_WHITE -font {"Segoe UI" 14}
ttk::style configure Card.TLabelframe -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 12 "bold"} -borderwidth 0
ttk::style configure Card.TLabelframe.Label -background $BG_MAIN -foreground $ACCENT -font {"Segoe UI" 12 "bold"}
ttk::style configure Card.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 11}

ttk::style configure Card.TEntry -fieldbackground $BG_WHITE -bordercolor $BORDER_LIGHT -lightcolor $BORDER_LIGHT -darkcolor $BORDER_LIGHT -font {"Segoe UI" 12} -padding {8 6}
ttk::style map Card.TEntry -bordercolor [list focus $ACCENT] -lightcolor [list focus $ACCENT]

ttk::style configure Accent.TButton -background $ACCENT -foreground $TEXT_WHITE -font {"Segoe UI" 12 "bold"} -padding {16 8} -borderwidth 0
ttk::style map Accent.TButton -background [list active $ACCENT_HOVER pressed $ACCENT_HOVER] -foreground [list active $TEXT_WHITE]

ttk::style configure Danger.TButton -background $CORAL -foreground $TEXT_WHITE -font {"Segoe UI" 12 "bold"} -padding {16 0} -borderwidth 0
ttk::style map Danger.TButton -background [list active $CORAL_HOVER pressed $CORAL_HOVER] -foreground [list active $TEXT_WHITE]

ttk::style configure Main.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 12}
ttk::style configure MainBold.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 12 "bold"}
ttk::style configure TotalLabel.TLabel -background $BG_MAIN -foreground $ACCENT -font {"Segoe UI" 14 "bold"}
ttk::style configure Anual.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 10}

ttk::style configure Treeview -background $BG_WHITE -foreground $TEXT_DARK -fieldbackground $BG_WHITE -rowheight 32 -font {"Segoe UI" 12}
ttk::style configure Treeview.Heading -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 11 "bold"} -relief "flat"
ttk::style map Treeview -background [list selected $ACCENT] -foreground [list selected $TEXT_WHITE]

ttk::frame .frame -style "Main.TFrame"

# Barra de menú
menu .mbar
. configure -menu .mbar

menu .mbar.file -tearoff 0

.mbar.file add command -label "Exportar en PDF" -command {_exportar_pdf} -accelerator "Ctrl+P"
.mbar.file add separator
.mbar.file add command -label "Salir" -command {_salir} -accelerator "Ctrl+Q"
.mbar add cascade -menu .mbar.file -label "Archivo"

.mbar add command -label "Acerca de" -command {_mostrar_acerca_de}

bind . <Control-q> {_salir}
bind . <Control-p> {_exportar_pdf}

# --- Formulario ---

ttk::frame .frame.inner -style "Header.TFrame"
ttk::label .frame.inner.titulo -text "Gatos Vampiro" -style "HeaderTitle.TLabel"
ttk::label .frame.inner.subtitulo -text "Rastreador de suscripciones que chupan tu dinero" -style "HeaderSubTitle.TLabel"
pack .frame.inner.titulo -pady {28 0}
pack .frame.inner.subtitulo -pady {2 0}
pack .frame.inner -fill x -ipadx 24 -ipady 28

ttk::labelframe .frame.formulario -text "+ Agregar nueva suscripción" -padding {20 14} -style "Card.TLabelframe"

# --- Fila 0 ---
grid [ttk::label .frame.formulario.nombre -text "Nombre:" -style "Card.TLabel"] -row 0 -column 0 -sticky w -padx 8 -pady {8 0}
grid [ttk::label .frame.formulario.costo -text "Costo (MXN $):" -style "Card.TLabel"] -row 0 -column 2 -sticky w -padx 8 -pady {8 0}

# --- Fila 1 ---
grid [ttk::entry .frame.formulario.entry_nombre -width 30 -style "Card.TEntry"] -row 1 -column 0 -sticky ew -columnspan 2 -padx 8 -pady 8
grid [ttk::entry .frame.formulario.entry_costo -width 14 -style "Card.TEntry"] -row 1 -column 2 -sticky ew -padx 8 -pady 8
grid [ttk::button .frame.formulario.agregar -text "Agregar" -cursor "hand2" -style "Accent.TButton" -command {_agregar_suscripcion}] -row 1 -column 3 -sticky e -padx 8 -pady 8

bind .frame.formulario.entry_costo <Return> {_agregar_suscripcion}
bind .frame.formulario.entry_nombre <Return> {focus .frame.formulario.entry_costo}

grid columnconfigure .frame.formulario 0 -weight 0
grid columnconfigure .frame.formulario 1 -weight 1
grid columnconfigure .frame.formulario 2 -weight 0
grid columnconfigure .frame.formulario 3 -weight 0

pack .frame.formulario -fill x -padx 16 -pady  {16 0}

ttk::frame .frame.frmtabla -style "Main.TFrame"

# --- Resumen ---
ttk::frame .frame.frmtabla.resumen -style "Main.TFrame"

pack [ttk::label .frame.frmtabla.resumen.suscripciones -text "Tus suscripciones" -style "MainBold.TLabel"] -side "left"
pack [ttk::label .frame.frmtabla.resumen.lbl_total -text "Total mensual: \$0.00 MXN" -style "TotalLabel.TLabel"] -side "right"

pack .frame.frmtabla.resumen -fill "x" -pady 16 -padx 16

# --- Tabla ---
ttk::frame .frame.frmtabla.frame

set columnas {"num" "nombre" "costo" "fecha"}

pack [ttk::treeview .frame.frmtabla.frame.tree -columns $columnas -show "headings" -selectmode "browse" -height 5] -side "left" -fill "both" -expand 1

.frame.frmtabla.frame.tree heading "num" -text "#"
.frame.frmtabla.frame.tree heading "nombre" -text "Suscripción"
.frame.frmtabla.frame.tree heading "costo" -text "Costo Mensual"
.frame.frmtabla.frame.tree heading "fecha" -text "Fecha Agregada"

.frame.frmtabla.frame.tree column "num" -width 40 -anchor "center" -minwidth 30
.frame.frmtabla.frame.tree column "nombre" -width 200 -anchor "w" -minwidth 100
.frame.frmtabla.frame.tree column "costo" -width 120 -anchor "center" -minwidth 80
.frame.frmtabla.frame.tree column "fecha" -width 120 -anchor "center" -minwidth 80

pack [ttk::scrollbar .frame.frmtabla.frame.scrollbar -orient "vertical" -command [list .frame.frmtabla.frame.tree  yview] ] -side "right" -fill y
.frame.frmtabla.frame.tree configure -yscrollcommand [list .frame.frmtabla.frame.scrollbar set]

# Label para cuando no hay datos
ttk::label .frame.frmtabla.frame.lbl_vacio -text "No hay suscripciones registradas\nAgrega una para comenzar" -justify "center" -style Main.TLabel

pack .frame.frmtabla.frame -fill "both" -expand 1 -padx 16 -pady {8 5}


# --- Footer ---
ttk::frame .frame.frmtabla.footer -style "Main.TFrame"

pack [ttk::button .frame.frmtabla.footer.btnelimina -text "Eliminar Seleccionada" -cursor "hand2" -style "Danger.TButton" -command {_eliminar_suscripcion}] -side "left" -pady 10
pack [ttk::label .frame.frmtabla.footer.lbl_anual -text "" -style "Anual.TLabel"] -side "left" -expand 1

pack .frame.frmtabla.footer -fill x -padx 16 -pady {0 12}
pack .frame.frmtabla -fill "both" -expand 1
pack .frame -fill x

set suscripciones [_cargar_suscripciones]

_actualizar_tabla
