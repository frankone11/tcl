#!/usr/bin/tclsh

package require Thread

# Código que ejecutará el hilo 1
set script1 {
    proc tarea {nombre} {
        for {set i 1} {$i <= 5} {incr i} {
            puts "$nombre: iteración $i"
            after 500
        }
        return "Hilo 1 terminado"
    }

	thread::wait
#    tarea "Hilo 1"
}

# Código que ejecutará el hilo 2
set script2 {
    proc tarea {nombre} {
        for {set i 1} {$i <= 5} {incr i} {
            puts "$nombre: iteración $i"
            after 700
        }
        return "Hilo 2 terminado"
    }

	thread::wait
#    tarea "Hilo 2"
}

# Crear los hilos
set tid1 [thread::create $script1]
set tid2 [thread::create $script2]

puts "Hilos creados:"
puts "  Hilo 1: $tid1"
puts "  Hilo 2: $tid2"

# Esperar a que terminen
set resultado1 [thread::send -async $tid1 {tarea "Hilo 1"}]
set resultado2 [thread::send $tid2 {tarea "Hilo 2"}]

puts $resultado1
puts $resultado2

# Eliminar los hilos
thread::release $tid1
thread::release $tid2