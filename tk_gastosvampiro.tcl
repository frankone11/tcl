#!/usr/bin/tclsh

package require Tcl
package require Tk
package require json

# ----- Paleta de colores -----
set BG_MAIN 	"#EEE9FE" ;# Fondo principal lavanda suave
set BG_WHITE 	"#FCFCFD" ;# Tarjetas y superficies blancas
set ACCENT		"#7C4DFF" ;# Púrpura vibrante - color principal
set GREEN		"#00C9A7" ;# Verde menta - acciones positivas
set CORAL		"#FF6B6B" ;# Coral - acciones descriptivas / alertas
set TEXT_DARK	"#06040D" ;# Texto principal oscuro
set TEXT_LIGHT	"#FAFAFA" ;# Texto secundario, placeholders, bordes, sombras

# Colores derivados

set ACCENT_HOVER	"#651FFF" ;# Acento más oscuro para hover
set GREEN_HOVER		"#00B396" ;# Verde más oscuro para hover
set CORAL_HOVER		"#E55A5A" ;# Coral más oscuro para hover
set BG_ENTRY		"#F0ECFA" ;# Fondo sutil para entradas de texto
set BORDER_LIGHT	"#D8D3E8" ;# Borde suave para entradas de texto

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

ttk::style configure Accent.TButton -background $ACCENT -foreground "#FFFFFF" -font {"Segoe UI" 12 "bold"} -padding {16 8} -borderwidth 0
ttk::style map Accent.TButton -background [list active $ACCENT_HOVER pressed $ACCENT_HOVER] -foreground [list active "#FFFFFF"]

ttk::style configure Danger.TButton -background $CORAL -foreground "#FFFFFF" -font {"Segoe UI" 12 "bold"} -padding {16 0} -borderwidth 0
ttk::style map Danger.TButton -background [list active $CORAL_HOVER pressed $CORAL_HOVER] -foreground [list active "#FFFFFF"]

ttk::style configure Main.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 12}
ttk::style configure MainBold.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 12 "bold"}
ttk::style configure TotalLabel.TLabel -background $BG_MAIN -foreground $ACCENT -font {"Segoe UI" 14 "bold"}
ttk::style configure Anual.TLabel -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 10}

ttk::style configure Treeview -background $BG_WHITE -foreground $TEXT_DARK -fieldbackground $BG_WHITE -rowheight 32 -font {"Segoe UI" 12}
ttk::style configure Treeview.Heading -background $BG_MAIN -foreground $TEXT_DARK -font {"Segoe UI" 11 "bold"} -relief "flat"
ttk::style map Treeview -background [list selected $ACCENT] -foreground [list selected "#FFFFFF"]

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
grid [ttk::button .frame.formulario.agregar -text "Agregar" -cursor "hand2" -style "Accent.TButton"] -row 1 -column 3 -sticky e -padx 8 -pady 8

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
ttk::label .frame.frmtabla.frame.lbl_vacio -text "No hay suscripciones registradas\nAgrega una para comenzar" -justify "center"

pack .frame.frmtabla.frame -fill "both" -expand 1 -padx 16 -pady {8 5}


# --- Footer ---
ttk::frame .frame.frmtabla.footer -style "Main.TFrame"

pack [ttk::button .frame.frmtabla.footer.btnelimina -text "Eliminar Seleccionada" -cursor "hand2" -style "Danger.TButton"] -side "left" -pady 10
pack [ttk::label .frame.frmtabla.footer.lbl_anual -text "" -style "Anual.TLabel"] -side "left" -expand 1

pack .frame.frmtabla.footer -fill x -padx 16 -pady {0 12}
pack .frame.frmtabla -fill "both" -expand 1
pack .frame -fill x

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

proc _agregar_suscripcion {} {

}

proc _actualizar_tabla {} {

}

proc _eliminar_suscripcion {} {

}

proc _cargar_suscripciones {} {

}

proc _guarda_suscripciones {} {
	
}