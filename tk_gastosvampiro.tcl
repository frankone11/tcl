#!/usr/bin/tclsh

package require Tk

wm title . "Gastos vampiro"
wm geometry . 700x680
wm resizable . 0 0

# Aplicar estilos
ttk::style theme use clam

# Barra de menú
menu .mbar
. configure -menu .mbar

menu .mbar.file -tearoff 0

.mbar.file add command -label "Exportar en PDF" -command {_exportar_pdf} -accelerator "Ctrl+P"
.mbar.file add command -label "Salir" -command {_salir} -accelerator "Ctrl+Q"
.mbar add cascade -menu .mbar.file -label "Archivo"

.mbar add command -label "Acerca de" -command {_mostrar_acerca_de}

bind . <Control-q> {_salir}
bind . <Control-p> {_exportar_pdf}

# --- Formulario ---

ttk::frame .inner
ttk::label .inner.titulo -text "Gatos Vampiro"
ttk::label .inner.subtitulo -text "Rastreador de suscripciones que chupan tu dinero"
pack .inner.titulo -pady {28 0}
pack .inner.subtitulo -pady {2 0}
pack .inner -fill x -ipadx 24 -ipady 28

ttk::labelframe .formulario -text "+ Agregar nueva suscripción" -padding {20 14}

# --- Fila 0 ---
grid [ttk::label .formulario.nombre -text "Nombre:"] -row 0 -column 0 -sticky w -padx 8 -pady {8 0}
grid [ttk::label .formulario.costo -text "Costo (MXN $):"] -row 0 -column 2 -sticky w -padx 8 -pady {8 0}

# --- Fila 1 ---
grid [ttk::entry .formulario.entry_nombre -width 30] -row 1 -column 0 -sticky ew -columnspan 2 -padx 8 -pady 8
grid [ttk::entry .formulario.entry_costo -width 14] -row 1 -column 2 -sticky ew -padx 8 -pady 8
grid [ttk::button .formulario.agregar -text "Agregar" -cursor "hand2"] -row 1 -column 3 -sticky e -padx 8 -pady 8

grid columnconfigure .formulario 0 -weight 0
grid columnconfigure .formulario 1 -weight 1
grid columnconfigure .formulario 2 -weight 0
grid columnconfigure .formulario 3 -weight 0

pack .formulario -fill x -padx 16 -pady  {16 0}

ttk::frame .frmtabla

# --- Resumen ---
ttk::frame .frmtabla.resumen

pack [ttk::label .frmtabla.resumen.suscripciones -text "Tus susctipciones"] -side "left"
pack [ttk::label .frmtabla.resumen.lbl_total -text "Total mensual: \$0.00 MXN"] -side "right"

pack .frmtabla.resumen -fill x -pady 16 -padx 16

# --- Tabla ---
ttk::frame .frmtabla.frame

set columnas {"num" "nombre" "costo" "fecha"}

pack [ttk::treeview .frmtabla.frame.tree -columns $columnas -show "headings" -selectmode "browse" -height 5] -side "left" -fill "both" -expand 1

.frmtabla.frame.tree heading "num" -text "#"
.frmtabla.frame.tree heading "nombre" -text "Suscripción"
.frmtabla.frame.tree heading "costo" -text "Costo Mensual"
.frmtabla.frame.tree heading "fecha" -text "Fecha Agregada"

.frmtabla.frame.tree column "num" -width 40 -anchor "center" -minwidth 30
.frmtabla.frame.tree column "nombre" -width 200 -anchor "w" -minwidth 100
.frmtabla.frame.tree column "costo" -width 120 -anchor "center" -minwidth 80
.frmtabla.frame.tree column "fecha" -width 120 -anchor "center" -minwidth 80

pack [ttk::scrollbar .frmtabla.frame.scrollbar -orient "vertical" -command [list .frmtabla.frame.tree  yview] ] -side "right" -fill y
.frmtabla.frame.tree configure -yscrollcommand [list .frmtabla.frame.scrollbar set]

# Label para cuando no hay datos
ttk::label .frmtabla.frame.lbl_vacio -text "No hay suscripciones registradas\nAgrega una para comenzar" -justify "center"

pack .frmtabla.frame -fill "both" -expand 1 -padx 16 -pady {8 5}


# --- Footer ---
ttk::frame .frmtabla.footer

pack [ttk::button .frmtabla.footer.btnelimina -text "Eliminar Seleccionada" -cursor "hand2"] -side "left" -pady 10
pack [ttk::label .frmtabla.footer.lbl_anual -text ""] -side "left" -expand 1

pack .frmtabla.footer -fill x -padx 16 -pady {0 12}
pack .frmtabla -fill "both" -expand 1

proc _salir {} {
	destroy .
}

proc _exportar_pdf {} {
	puts "Exportar en PDF"
}

proc _mostrar_acerca_de {} {
	puts "Acerca de Gatos Vampiro"
}