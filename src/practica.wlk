class Dia {
    const temperaturaMedia
    const horasDeSol
    const precipitacionesEnMM

    method temperaturaMedia() = temperaturaMedia
    method horasDeSol() = horasDeSol
    method precipitacionesEnMM() = precipitacionesEnMM
    method soleado() = horasDeSol >= 12
    method nivelDeHumedad() = precipitacionesEnMM + (temperaturaMedia - 10).max(0)
}

class MensajeDemasiadoLargoException inherits Exception {}

class Planta {
    const abecedario = "abcdefghijklmnñopqrstuvwxyz"

    method decodificarMensaje()
    method serializarMensaje(mensaje) {
        if(mensaje.size() > self.cantidadDeCaracteresQuePuedeSerializar()) {
            throw new MensajeDemasiadoLargoException(message = "El mensaje no entra en esta planta")
        }
        self.escribirMensaje(mensaje)
    }
    method cantidadDeCaracteresQuePuedeSerializar()
    method escribirMensaje(mensaje)

    method caracterACodigo(caracter) = if(abecedario.contains(caracter)) abecedario.indexOf(caracter) + 1 else 4267
    method codigoACaracter(codigo) = if(codigo >= 1 && codigo <= abecedario.size()) abecedario.charAt(codigo - 1) else " "
    method mensajeACodigo(mensaje, capacidad) {
        const caracteres = mensaje.split("")
        const mensajeCodificado = caracteres.map { caracter => self.caracterACodigo(caracter) }
        const cantidadDeEspacioAAgregar = (capacidad - mensaje.size()).max(0)
        cantidadDeEspacioAAgregar.times { _ => mensajeCodificado.add(4267) }

        return mensajeCodificado
    }

    method pasarDia(dia)
    method clorofila()
    method enRiesgo() = self.clorofila() > 0 && self.clorofila() <= 5
    method marchita() = self.clorofila() == 0
}

class Herbuleana inherits Planta {
    var fueDiaHumedo = false

    override method pasarDia(dia) {
        fueDiaHumedo = dia.nivelDeHumedad() >= 150
    }

    override method clorofila() = if(fueDiaHumedo) 15 else 1

    override method cantidadDeCaracteresQuePuedeSerializar() = 0

    override method escribirMensaje(mensaje) {}

    override method decodificarMensaje() = ""
}

class Flor {
    const petalos
    var nectar

    method petalos() = petalos
    method nectar() = nectar
    method nectar(unNectar) { nectar = unNectar }
    method clorofila() = petalos * nectar
}

class PilastackisPatagonica inherits Planta {
    const flores = []

    override method pasarDia(dia) {
        if(dia.soleado()) {
            flores.add(new Flor(petalos = dia.horasDeSol(), nectar = dia.precipitacionesEnMM()))
        } else if(!flores.isEmpty()) {
            flores.remove(flores.last())
        }
    }

    override method clorofila() = flores.sum { flor => flor.clorofila() }

    override method cantidadDeCaracteresQuePuedeSerializar() = flores.size()

    override method escribirMensaje(mensaje) {
        const codigos = self.mensajeACodigo(mensaje, flores.size())

        (0..flores.size()-1).forEach { i =>
            const flor = flores.get(i)
            const codigo = codigos.get(i)
            flor.nectar(codigo)
        }
    }

    override method decodificarMensaje() = flores.map { flor =>
        const codigo = flor.nectar()

        self.codigoACaracter(codigo)
    }.join("")
}

class Cromatica inherits Planta {
    var clorofila = 10

    override method pasarDia(dia) {
        clorofila = (clorofila + self.varianzaDeClorofila(dia)).max(1)
    }

    override method clorofila() = clorofila

    override method cantidadDeCaracteresQuePuedeSerializar() = 1

    override method escribirMensaje(mensaje) {
        clorofila = self.mensajeACodigo(mensaje, 1).head()
    }

    override method decodificarMensaje() = self.codigoACaracter(clorofila)

    method varianzaDeClorofila(dia)
}

class CromaticaRoja inherits Cromatica {
    override method varianzaDeClorofila(dia) {
        return (dia.temperaturaMedia() - 20).abs()
    }
}

class CromaticaVerde inherits Cromatica {
    override method varianzaDeClorofila(dia) {
        return if(dia.soleado()) 1 else -0.5
    }
}

class CromaticaEsmeralda inherits CromaticaVerde {
    override method varianzaDeClorofila(dia) {
        return super(dia) * 2
    }
}

class CromaticaAzul inherits Cromatica {
    override method varianzaDeClorofila(dia) {
        return dia.nivelDeHumedad() * 0.1
    }
}

object sinPlanta {
    method pasarDia(dia) {
    }
    method clorofila() = 0
    method cantidadDeCaracteresQuePuedeSerializar() = 0
    method serializarMensaje(mensaje) {
    }
    method decodificarMensaje() = ""
}

class RamusDuplus inherits Planta {
    var talloIzquierdo = sinPlanta
    var talloDerecho = sinPlanta

    method talloIzquierdo(planta) { talloIzquierdo = planta }
    method talloDerecho(planta) { talloDerecho = planta }

    override method pasarDia(dia) {
        talloIzquierdo.pasarDia(dia)
        talloDerecho.pasarDia(dia)
    }

    override method clorofila() = talloIzquierdo.clorofila().max(talloDerecho.clorofila())

    override method cantidadDeCaracteresQuePuedeSerializar() =
        talloIzquierdo.cantidadDeCaracteresQuePuedeSerializar() + talloDerecho.cantidadDeCaracteresQuePuedeSerializar()

    override method escribirMensaje(mensaje) {
        const mensajeParaIzquierda = mensaje.take(talloIzquierdo.cantidadDeCaracteresQuePuedeSerializar())
        const mensajeParaDerecha = mensaje.drop(mensajeParaIzquierda.size())
        talloIzquierdo.serializarMensaje(mensajeParaIzquierda)
        talloDerecho.serializarMensaje(mensajeParaDerecha)
    }

    override method decodificarMensaje() = talloIzquierdo.decodificarMensaje() + talloDerecho.decodificarMensaje()
}

class SwitchSorrel inherits Planta {
    var raiz = sinPlanta
    var talloIzquierdo = sinPlanta
    var talloDerecho = sinPlanta

    method raiz(planta) { raiz = planta }
    method talloIzquierdo(planta) { talloIzquierdo = planta }
    method talloDerecho(planta) { talloDerecho = planta }

    method plantaActiva() = if(raiz.clorofila() >= 10) talloIzquierdo else talloDerecho

    override method pasarDia(dia) {
        self.plantaActiva().pasarDia(dia)
    }

    override method clorofila() = self.plantaActiva().clorofila()

    override method cantidadDeCaracteresQuePuedeSerializar() = self.plantaActiva().cantidadDeCaracteresQuePuedeSerializar()

    override method escribirMensaje(mensaje) {
        self.plantaActiva().serializarMensaje(mensaje)
    }

    override method decodificarMensaje() = self.plantaActiva().decodificarMensaje()
}

class EquipoDeInvestigacion {
    const plantas = new Set()

    method agregarPlanta(planta) {
        plantas.add(planta)
    }

    method clorofilaPromedio() = if(plantas.isEmpty()) 0 else plantas.sum { planta => planta.clorofila() } / plantas.size()

    method plantasEnRiesgo() = plantas.filter { planta => planta.enRiesgo() }

    method dejarDeInvestigarPlantasMarchitas() {
        plantas.removeAllSuchThat { planta => planta.marchita() }
    }

    method hacerlasPasarDia(dia) {
        plantas.forEach { planta => planta.pasarDia(dia) }
    }
}
