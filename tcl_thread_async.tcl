#!/usr/bin/tclsh

package require Thread

# Crear un hilo trabajador
set tid [thread::create {
    proc trabajador {} {
        for {set i 1} {$i <= 10} {incr i} {
            puts "Trabajador: procesando $i"
            after 500
        }

        return "Trabajo terminado"
    }

    thread::wait
}]

# Iniciar el trabajo sin bloquear inmediatamente
thread::send -async $tid {trabajador}

puts "El hilo principal continúa trabajando..."

for {set i 1} {$i <= 10} {incr i} {
    puts "Principal: $i"
    after 300
}

puts "Principal terminado"

thread::release $tid