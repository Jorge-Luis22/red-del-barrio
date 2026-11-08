// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Red del barrio';

  @override
  String get inicio => 'Inicio';

  @override
  String get vecinos => 'Vecinos';

  @override
  String get mensajes => 'Mensajes';

  @override
  String get emergencia => 'Emergencia';

  @override
  String get perfil => 'Perfil';

  @override
  String get algoNoSalioBien => 'Algo no salió bien';

  @override
  String get intentarOtraVez => 'Intentar otra vez';

  @override
  String get cargando => 'Cargando';

  @override
  String get unMomento => 'Un momento…';

  @override
  String get atajos => 'Atajos';

  @override
  String get unToqueAbreEl => 'Un toque abre el pedido ya escrito';

  @override
  String get zonaAproximadaSinDireccion =>
      'Zona aproximada · sin dirección exacta';

  @override
  String zonaAprox1Km(Object p0, Object p1) {
    return 'Zona $p0, $p1 (aprox. 1 km)';
  }

  @override
  String get queNecesitasHoy => '¿Qué necesitas hoy?';

  @override
  String get cuentaloYLosVecinos =>
      'Cuéntalo y los vecinos y negocios de tu zona te proponen cómo resolverlo.';

  @override
  String get pedirAlgo => 'Pedir algo';

  @override
  String get noPudimosVerDonde => 'No pudimos ver dónde estás';

  @override
  String get veQueHayCerca => 'Ve qué hay cerca de ti';

  @override
  String get revisaQueLaUbicacion => 'Revisa que la ubicación esté activada.';

  @override
  String get tuUbicacionSeQueda =>
      'Tu ubicación se queda en tu teléfono. Los vecinos solo verán una zona de unos 1000 m.';

  @override
  String get buscando => 'Buscando…';

  @override
  String get usarMiUbicacion => 'Usar mi ubicación';

  @override
  String pedir(Object p0) {
    return 'Pedir: $p0';
  }

  @override
  String get noPudimosLeerTus =>
      'No pudimos leer tus pedidos. Cierra y abre la app.';

  @override
  String get misPedidos => 'Mis pedidos';

  @override
  String verTodosMisPedidos(Object p0) {
    return 'Ver todos mis pedidos ($p0)';
  }

  @override
  String get listoTuPedidoQuedo =>
      'Listo: tu pedido quedó guardado. Mira su estado en la siguiente pantalla.';

  @override
  String get queNecesitas => '¿Qué necesitas?';

  @override
  String get eligeUnaFraseO =>
      'Elige una frase o escribe con tus palabras. Tu barrio te propone cómo resolverlo.';

  @override
  String get queTipoDeAyuda => 'Qué tipo de ayuda';

  @override
  String get eligeUnaFraseO2 => 'Elige una frase o escríbelo';

  @override
  String conTusPalabras(Object p0) {
    return 'Con tus palabras ($p0)';
  }

  @override
  String get paraCuandoLoNecesitas => '¿Para cuándo lo necesitas?';

  @override
  String get publicando => 'Publicando…';

  @override
  String get publicar => 'Publicar';

  @override
  String get noPudimosLeerTus2 => 'No pudimos leer tus pedidos.';

  @override
  String get enCurso => 'En curso';

  @override
  String get resueltos => 'Resueltos';

  @override
  String enCursoResueltos(int active, int done) {
    return '$active en curso · $done resueltos';
  }

  @override
  String get aunNoResolvisteNinguno => 'Aún no resolviste ninguno';

  @override
  String get noTienesPedidosEn => 'No tienes pedidos en curso';

  @override
  String get cuandoCierresUnTrato =>
      'Cuando cierres un trato y lo califiques, aparecerá aquí.';

  @override
  String get pideAlgoDesdeInicio =>
      'Pide algo desde Inicio y tu barrio te propone cómo resolverlo.';

  @override
  String para(Object p0, Object p1) {
    return '$p0 · Para: $p1';
  }

  @override
  String get explorarCerca => 'Explorar cerca';

  @override
  String get losVecinosYNegocios =>
      'Los vecinos y negocios son de ejemplo, ubicados alrededor de ti.';

  @override
  String get servicios => 'Servicios';

  @override
  String get productos => 'Productos';

  @override
  String get noPudimosCargarLo => 'No pudimos cargar lo que hay cerca.';

  @override
  String get nadaPorAhora => 'Nada por ahora';

  @override
  String get noHayResultadosCon =>
      'No hay resultados con ese rubro. Prueba con \"Todos\".';

  @override
  String get verTodos => 'Ver todos';

  @override
  String get ordenar => 'Ordenar';

  @override
  String get masRecomendados => 'Más recomendados';

  @override
  String get masCerca => 'Más cerca';

  @override
  String get recomendados => 'Recomendados';

  @override
  String get ejemplo => 'Ejemplo';

  @override
  String get aunSinRecomendaciones => 'Aún sin recomendaciones';

  @override
  String get podrasRecomendarloCuandoCierres =>
      'Podrás recomendarlo cuando cierres un trato con esta persona.';

  @override
  String get pedirEsteServicio => 'Pedir este servicio';

  @override
  String get loQuiero => 'Lo quiero';

  @override
  String get noEncontramosEstePedido => 'No encontramos este pedido';

  @override
  String get puedeQueYaNo =>
      'Puede que ya no esté en tu teléfono. Vuelve a Inicio para ver tus pedidos.';

  @override
  String get propuestasDeTuBarrio => 'Propuestas de tu barrio';

  @override
  String get aquiElPrecioLo =>
      'Aquí el precio lo pone cada persona al ver tu pedido. Tú eliges. Las propuestas son de ejemplo.';

  @override
  String get reputacion => 'Reputación';

  @override
  String get cercania => 'Cercanía';

  @override
  String get precio => 'Precio';

  @override
  String get noPudimosCargarLas => 'No pudimos cargar las propuestas.';

  @override
  String para2(Object p0) {
    return 'Para: $p0';
  }

  @override
  String get todaviaNoHayServidor =>
      'Todavía no hay servidor: las propuestas que ves son de ejemplo.';

  @override
  String get enviando => 'Enviando…';

  @override
  String get reintentarAhora => 'Reintentar ahora';

  @override
  String recomiendan(Object p0, Object p1) {
    return '$p0 · $p1 recomiendan';
  }

  @override
  String aprox(Object p0) {
    return '$p0 (aprox.)';
  }

  @override
  String ofreceVisitaDeDiagnostico(Object p0) {
    return 'Ofrece visita de diagnóstico: S/ $p0 (se descuenta)';
  }

  @override
  String get aceptarPropuesta => 'Aceptar propuesta';

  @override
  String get aceptada => 'Aceptada';

  @override
  String get faltaCalificar => 'Falta calificar';

  @override
  String get resuelta => 'Resuelta';

  @override
  String trato(Object p0) {
    return 'Trato: $p0';
  }

  @override
  String get abrirElChatDe => 'Abrir el chat de este trato';

  @override
  String get tuCodigoDeEncuentro => 'Tu código de encuentro';

  @override
  String get codigoValidadoEncuentroConfirmado =>
      'Código validado. Encuentro confirmado.';

  @override
  String get demoLaOtraPersona => 'Demo: la otra persona ingresa el código';

  @override
  String get todaviaNoHayCuentas =>
      'Todavía no hay cuentas: este botón hace de la otra persona solo para la demostración.';

  @override
  String get encuentroConfirmadoConCodigo => 'Encuentro confirmado con código';

  @override
  String get tiempoDesdeQueSe =>
      'Tiempo desde que se validó el código. Es informativo, no es un cobro.';

  @override
  String get servicioMarcadoComoHecho => 'Servicio marcado como hecho.';

  @override
  String get servicioHecho => 'Servicio hecho';

  @override
  String get comoTeFue => '¿Cómo te fue?';

  @override
  String get comentarioOpcional => 'Comentario (opcional)';

  @override
  String get sumaAVecinosQue =>
      'Suma a \"vecinos que lo recomiendan\". Solo cuenta porque hubo un trato contigo.';

  @override
  String get graciasTuCalificacionQuedo =>
      'Gracias. Tu calificación quedó guardada en tu teléfono.';

  @override
  String get enviarCalificacion => 'Enviar calificación';

  @override
  String get tratoCerrado => 'Trato cerrado.';

  @override
  String get tratoResueltoYCalificado => 'Trato resuelto y calificado';

  @override
  String get servicioRealizadoEn => 'Servicio realizado en';

  @override
  String get precioFinal => 'Precio final';

  @override
  String get calificacionesTuyas => 'Calificaciones tuyas';

  @override
  String get vecinosQueLoRecomiendan => 'Vecinos que lo recomiendan';

  @override
  String get necesidadesResueltas => 'Necesidades resueltas';

  @override
  String get cadaNecesidadResueltaDeja =>
      'Cada necesidad resuelta deja al barrio mejor preparado para la siguiente. La calificación de la otra persona hacia ti se mostrará cuando haya cuentas.';

  @override
  String etapaDe(Object p0, Object p1, Object p2) {
    return 'Etapa $p0 de $p1: $p2';
  }

  @override
  String get tu => 'Tú';

  @override
  String get favoresPrestamosYAyuda =>
      'Favores, préstamos y ayuda entre vecinos.';

  @override
  String get ofrecer => 'Ofrecer';

  @override
  String get porAhoraLosVecinos =>
      'Por ahora los vecinos del muro son de ejemplo. Lo que publiques queda guardado en tu teléfono.';

  @override
  String get piden => 'Piden';

  @override
  String get ofrecen => 'Ofrecen';

  @override
  String get todas => 'Todas';

  @override
  String get nadiePideEstoPor => 'Nadie pide esto por ahora';

  @override
  String get nadieOfreceEstoPor => 'Nadie ofrece esto por ahora';

  @override
  String get cambiaLaModalidadO =>
      'Cambia la modalidad o pide tú algo al barrio.';

  @override
  String get cambiaLaModalidadU =>
      'Cambia la modalidad u ofrece tú algo al barrio.';

  @override
  String get verTodas => 'Ver todas';

  @override
  String aAprox(Object p0) {
    return 'a $p0 (aprox.)';
  }

  @override
  String get listoTuOfertaQuedo =>
      'Listo: tu oferta quedó guardada en tu teléfono.';

  @override
  String get ofrecerAlgoAlBarrio => 'Ofrecer algo al barrio';

  @override
  String get unaHerramientaTuTiempo =>
      'Una herramienta, tu tiempo o una habilidad. Tú decides cómo.';

  @override
  String get publicarOferta => 'Publicar oferta';

  @override
  String get comoLoOfreces => '¿Cómo lo ofreces?';

  @override
  String get queOfreces => 'Qué ofreces';

  @override
  String get elChatDeCada => 'El chat de cada trato.';

  @override
  String get noPudimosLeerTus3 => 'No pudimos leer tus conversaciones.';

  @override
  String get aunNoTienesConversaciones => 'Aún no tienes conversaciones';

  @override
  String get cuandoAceptesUnaPropuesta =>
      'Cuando aceptes una propuesta, el chat de ese trato aparece aquí.';

  @override
  String get escribeElPrimerMensaje => 'Escribe el primer mensaje';

  @override
  String tu2(Object p0) {
    return 'Tú: $p0';
  }

  @override
  String get noEncontramosEsteTrato => 'No encontramos este trato';

  @override
  String get vuelveAMensajesPara =>
      'Vuelve a Mensajes para ver tus conversaciones.';

  @override
  String get verElPedido => 'Ver el pedido';

  @override
  String get todaviaNoHayCuentas2 =>
      'Todavía no hay cuentas: tus mensajes se guardan en tu teléfono. El chat con la otra persona llegará con el servidor.';

  @override
  String get noPudimosLeerLos => 'No pudimos leer los mensajes.';

  @override
  String get sinMensajesTodavia => 'Sin mensajes todavía';

  @override
  String get escribeAbajoOToca => 'Escribe abajo o toca una frase rápida.';

  @override
  String get escribeUnMensaje => 'Escribe un mensaje';

  @override
  String get enviarMensaje => 'Enviar mensaje';

  @override
  String get guardado => 'Guardado';

  @override
  String get ayudaDelBarrioCuando => 'Ayuda del barrio cuando más importa.';

  @override
  String get serviciosOficiales => 'Servicios oficiales';

  @override
  String get enPeligroLlamaAqui => 'En peligro, llama aquí primero.';

  @override
  String get verificaEstosNumerosCon =>
      'Verifica estos números con fuentes oficiales antes de depender de ellos.';

  @override
  String get ayudaDelBarrio => 'Ayuda del barrio';

  @override
  String get avisaATusVecinos =>
      'Avisa a tus vecinos. No reemplaza a los servicios oficiales.';

  @override
  String get necesitoAyuda => 'Necesito ayuda';

  @override
  String get noPudimosLeerTus4 => 'No pudimos leer tus avisos.';

  @override
  String get misAvisos => 'Mis avisos';

  @override
  String get todaviaNoHayVecinos =>
      'Todavía no hay vecinos conectados que respondan: nadie te escribirá desde la app.';

  @override
  String get unBarrioPreparado => 'Un barrio preparado';

  @override
  String get quePodriasOfrecerSi => 'Qué podrías ofrecer si pasa algo.';

  @override
  String get brigadistaVecinalVoluntario => 'Brigadista vecinal voluntario';

  @override
  String get sinVerificarSoloQueda =>
      'Sin verificar. Solo queda guardado en tu teléfono.';

  @override
  String get puntosDeAcopio => 'Puntos de acopio';

  @override
  String get lugaresParaReunirAyuda =>
      'Lugares para reunir ayuda. Los que propongas quedan sin verificar.';

  @override
  String get proponer => 'Proponer';

  @override
  String get aunNoHayPuntos =>
      'Aún no hay puntos de acopio. Propón uno: un colegio, una iglesia o un local del barrio.';

  @override
  String llamarAl(Object p0) {
    return '¿Llamar al $p0?';
  }

  @override
  String esteNumeroEstaPor(Object p0, Object p1) {
    return '$p0 · $p1.\nEste número está por verificar con fuentes oficiales.';
  }

  @override
  String get cancelar => 'Cancelar';

  @override
  String get llamar => 'Llamar';

  @override
  String noPudimosAbrirEl(Object p0) {
    return 'No pudimos abrir el teléfono. Marca el $p0 desde tu celular.';
  }

  @override
  String llamarANumero(Object p0, Object p1) {
    return 'Llamar a $p0, número $p1';
  }

  @override
  String get porVerificar => 'Por verificar';

  @override
  String get privado => 'Privado';

  @override
  String get propuestoPorTiSin => 'Propuesto por ti · sin verificar';

  @override
  String get proponerUnPuntoDe => 'Proponer un punto de acopio';

  @override
  String get unLugarDelBarrio =>
      'Un lugar del barrio donde reunir agua, comida o abrigo.';

  @override
  String get guardarPunto => 'Guardar punto';

  @override
  String get nombreDelLugar => 'Nombre del lugar';

  @override
  String get referenciaOpcional => 'Referencia (opcional)';

  @override
  String get porEjemploFrenteAl => 'Por ejemplo: frente al parque';

  @override
  String get tuAvisoQuedoGuardado =>
      'Tu aviso quedó guardado. Si es grave, llama ya a los servicios oficiales.';

  @override
  String get eligeQuePasaEl =>
      'Elige qué pasa. El texto ya está escrito: enviar es un toque.';

  @override
  String get enviarAviso => 'Enviar aviso';

  @override
  String get noSePudoGuardar => 'No se pudo guardar el aviso';

  @override
  String siEsUrgenteLlama(Object p0) {
    return '$p0 Si es urgente, llama a los servicios oficiales.';
  }

  @override
  String get primeroLosServiciosOficiales => 'Primero, los servicios oficiales';

  @override
  String get siHayPeligroAhora =>
      'Si hay peligro ahora, llama a emergencias antes de usar la app. Los vecinos no reemplazan a Bomberos, Policía ni SAMU.';

  @override
  String get quePasa => '¿Qué pasa?';

  @override
  String get esteAvisoEsPrivado =>
      'Este aviso es privado: no se muestra en el muro del barrio.';

  @override
  String get quePasoPuedesCambiarlo => 'Qué pasó (puedes cambiarlo)';

  @override
  String get tuUbicacionExactaNo =>
      'Tu ubicación exacta no se comparte. Se guarda en tu teléfono y se envía cuando haya internet.';

  @override
  String get tuAyudaAlBarrio => 'Tu ayuda al barrio y tus ajustes.';

  @override
  String get tuAyudaAlBarrio2 => 'Tu ayuda al barrio';

  @override
  String get soloTuVesEste => 'Solo tú ves este resumen.';

  @override
  String get esEvidenciaDeLo =>
      'Es evidencia de lo que hiciste, no puntos: no da prioridad ni ventaja.';

  @override
  String get verYEscucharMejor => 'Ver y escuchar mejor';

  @override
  String get tamanoDelTexto => 'Tamaño del texto';

  @override
  String get normal => 'Normal';

  @override
  String get grande => 'Grande';

  @override
  String get muyGrande => 'Muy grande';

  @override
  String get apariencia => 'Apariencia';

  @override
  String get sistema => 'Sistema';

  @override
  String get claro => 'Claro';

  @override
  String get oscuro => 'Oscuro';

  @override
  String get altoContraste => 'Alto contraste';

  @override
  String get textosMasOscurosY => 'Textos más oscuros y bordes más marcados.';

  @override
  String get vibracionAlConfirmar => 'Vibración al confirmar';

  @override
  String get unaVibracionCortaCuando =>
      'Una vibración corta cuando envías algo.';

  @override
  String get ayudaYDatos => 'Ayuda y datos';

  @override
  String get verElTutorial => 'Ver el tutorial';

  @override
  String get tresPantallasParaEmpezar => 'Tres pantallas para empezar.';

  @override
  String get sobreEstePrototipo => 'Sobre este prototipo';

  @override
  String get queEsRealY => 'Qué es real y qué es de ejemplo.';

  @override
  String get borrarMisDatosDe => 'Borrar mis datos de este teléfono';

  @override
  String get pedidosTratosMensajesY => 'Pedidos, tratos, mensajes y ajustes.';

  @override
  String get tratosResueltos => 'Tratos resueltos';

  @override
  String get personasDistintas => 'Personas distintas';

  @override
  String get calificacionQueDiste => 'Calificación que diste';

  @override
  String min(Object p0) {
    return '$p0 min';
  }

  @override
  String get tiempoEnTratos => 'Tiempo en tratos';

  @override
  String get esRealTusPedidos =>
      'Es real: tus pedidos, tratos, mensajes y ajustes se guardan en tu teléfono, funciona sin internet y la cola envía lo pendiente al volver la señal.\n\nEs de ejemplo: los vecinos, negocios, propuestas y precios que ves, y el \"enviado\", porque todavía no hay servidor ni cuentas.\n\nPor verificar: los números de emergencia deben confirmarse con fuentes oficiales.';

  @override
  String get entendido => 'Entendido';

  @override
  String get borrarTusDatos => '¿Borrar tus datos?';

  @override
  String get seBorraranTusPedidos =>
      'Se borrarán tus pedidos, tratos, calificaciones, mensajes, avisos y ajustes de este teléfono.';

  @override
  String get continuar => 'Continuar';

  @override
  String get ultimaConfirmacion => 'Última confirmación';

  @override
  String get estoNoSePuede =>
      'Esto no se puede deshacer. ¿Seguro que quieres borrar todo?';

  @override
  String get noConservar => 'No, conservar';

  @override
  String get siBorrarTodo => 'Sí, borrar todo';

  @override
  String get listoBorramosTusDatos =>
      'Listo: borramos tus datos de este teléfono.';

  @override
  String get cuentaQueNecesitas => 'Cuenta qué necesitas';

  @override
  String get tocaPedirAlgoY =>
      'Toca \"Pedir algo\" y elige una frase, o escribe con tus palabras. Con un atajo, son solo dos toques.';

  @override
  String get eligeAQuienY => 'Elige a quién y encuéntrense';

  @override
  String get tuBarrioTePropone =>
      'Tu barrio te propone cómo resolverlo y cada persona pone su precio. Al encontrarse, se dicen un código de 4 dígitos.';

  @override
  String get calificaYConstruyeConfianza => 'Califica y construye confianza';

  @override
  String get alTerminarCalificasAsi =>
      'Al terminar, calificas. Así el barrio sabe en quién confiar. También funciona sin internet: tus pedidos se envían después.';

  @override
  String get saltar => 'Saltar';

  @override
  String get empezar => 'Empezar';

  @override
  String get siguiente => 'Siguiente';

  @override
  String todoAlDiaResueltos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n resueltos',
      one: '1 resuelto',
    );
    return 'Todo al día · $_temp0';
  }

  @override
  String enCursoSolo(int active) {
    return '$active en curso';
  }

  @override
  String verTodosServicios(int n) {
    return 'Ver todos los servicios ($n)';
  }

  @override
  String verTodosProductos(int n) {
    return 'Ver todos los productos ($n)';
  }

  @override
  String aDistancia(String d) {
    return 'a $d';
  }

  @override
  String aDistanciaAprox(String d) {
    return 'a $d (aprox.)';
  }

  @override
  String vecinosRecomiendanEjemplo(int n) {
    return '$n vecinos lo recomiendan (ejemplo)';
  }

  @override
  String vecinosRecomiendanEjemploTuyas(int n, int m) {
    String _temp0 = intl.Intl.pluralLogic(
      m,
      locale: localeName,
      other: '$m tuyas',
      one: '1 tuya',
    );
    return '$n vecinos lo recomiendan (ejemplo) + $_temp0';
  }

  @override
  String codigoDigitos(String digits) {
    return 'Código $digits';
  }

  @override
  String diselo(String name) {
    return 'Díselo a $name cuando llegue. Así confirmamos que se encontraron de verdad y el trato cuenta para la reputación.';
  }

  @override
  String get servicioRealizado => 'Servicio realizado';

  @override
  String servicioRealizadoEnTiempo(String time) {
    return 'Servicio realizado en $time';
  }

  @override
  String recomendarA(String name) {
    return 'Recomendar a $name';
  }

  @override
  String reputacionDe(String name) {
    return 'Reputación de $name';
  }

  @override
  String vecinosRecomiendanResumen(int n, int m) {
    String _temp0 = intl.Intl.pluralLogic(
      m,
      locale: localeName,
      other: '$m tuyas',
      one: '1 tuya',
    );
    return '$n (ejemplo) + $_temp0';
  }

  @override
  String duracionSegundos(int s) {
    return '$s s';
  }

  @override
  String duracionMinutos(int m) {
    return '$m min';
  }

  @override
  String duracionMinutosSegundos(int m, int s) {
    return '$m min $s s';
  }

  @override
  String get kindService => 'Servicio';

  @override
  String get kindProduct => 'Producto';

  @override
  String get kindLoan => 'Préstamo';

  @override
  String get kindHelp => 'Ayuda';

  @override
  String get hintService => 'Un oficio o profesional';

  @override
  String get hintProduct => 'Algo cerca de ti';

  @override
  String get hintLoan => 'Prestar, alquilar o trueque';

  @override
  String get hintHelp => 'Un favor o tiempo de alguien';

  @override
  String get urgencyNow => 'Ahora mismo';

  @override
  String get urgencyToday => 'Hoy';

  @override
  String get urgencyTomorrow => 'Mañana';

  @override
  String get urgencyThisWeek => 'Esta semana';

  @override
  String get suggService1 => 'Necesito un gasfitero para arreglar una fuga';

  @override
  String get suggService2 =>
      'Necesito un electricista, se fue la luz en la cocina';

  @override
  String get suggProduct1 => 'Necesito 2 bidones de agua';

  @override
  String get suggProduct2 => 'Necesito pan y leche, no puedo salir';

  @override
  String get suggLoan1 => 'Necesito un taladro por una hora';

  @override
  String get suggLoan2 => 'Necesito una escalera por hoy';

  @override
  String get suggHelp1 => 'Necesito ayuda para mover un mueble';

  @override
  String get suggHelp2 => 'Necesito que alguien cuide a mi hijo 2 horas';

  @override
  String get quickPlumber => 'Gasfitero';

  @override
  String get quickElectrician => 'Electricista';

  @override
  String get quickWater => '2 bidones de agua';

  @override
  String get syncPending =>
      'Guardada en tu teléfono · se enviará cuando haya internet';

  @override
  String get syncSentDemo => 'Enviada · barrio de ejemplo (demo)';

  @override
  String get syncSent => 'Enviada';

  @override
  String get syncError => 'No se pudo enviar · toca para reintentar';

  @override
  String get badgePending => 'Pendiente';

  @override
  String get badgeSent => 'Enviada';

  @override
  String get badgeRetry => 'Reintentar';

  @override
  String get phaseSending => 'Pendiente de envío';

  @override
  String get phaseError => 'No se envió · reintentar';

  @override
  String get phaseWaiting => 'Con propuestas';

  @override
  String get phaseActive => 'En curso';

  @override
  String get phaseRate => 'Falta calificar';

  @override
  String get phaseDone => 'Resuelta';

  @override
  String get modFree => 'Gratis';

  @override
  String get modBarter => 'Trueque';

  @override
  String get modRent => 'Alquiler';

  @override
  String get modFreeHint => 'Sin costo: un favor entre vecinos.';

  @override
  String get modBarterHint => 'Cambias una cosa o un favor por otro.';

  @override
  String get modRentHint =>
      'Lo prestas a cambio de un pago acordado entre ustedes.';

  @override
  String get sitEarthquake => 'Sismo';

  @override
  String get sitFire => 'Incendio';

  @override
  String get sitMedical => 'Médico';

  @override
  String get sitElderly => 'Persona mayor en riesgo';

  @override
  String get sitViolence => 'Violencia';

  @override
  String get tplEarthquake => 'Hubo un sismo y necesito ayuda.';

  @override
  String get tplFire => 'Hay un incendio cerca y necesito ayuda.';

  @override
  String get tplMedical => 'Necesito ayuda médica urgente.';

  @override
  String get tplElderly => 'Una persona mayor necesita ayuda ahora.';

  @override
  String get tplViolence =>
      'Estoy en una situación de violencia y necesito ayuda.';

  @override
  String get offPolice => 'Policía Nacional';

  @override
  String get offPoliceUse => 'Delitos y peligro inmediato';

  @override
  String get offFire => 'Bomberos';

  @override
  String get offFireUse => 'Incendios y rescates';

  @override
  String get offSamu => 'SAMU';

  @override
  String get offSamuUse => 'Emergencias médicas';

  @override
  String get offCivil => 'Defensa Civil';

  @override
  String get offCivilUse => 'Sismos y desastres';

  @override
  String get offLine100 => 'Línea 100';

  @override
  String get offLine100Use => 'Violencia familiar y sexual';

  @override
  String get capFirstAid => 'Primeros auxilios';

  @override
  String get capMedkit => 'Botiquín';

  @override
  String get capVehicle => 'Vehículo';

  @override
  String get capTools => 'Herramientas';

  @override
  String get capSupplies => 'Agua o víveres';

  @override
  String get capCare => 'Cuidar niños o mayores';

  @override
  String get qpOnMyWay => 'Ya voy en camino';

  @override
  String get qpAtDoor => 'Estoy en la puerta';

  @override
  String get qpWhatTime => '¿A qué hora puede venir?';

  @override
  String get qpThanks => 'Gracias, todo bien';

  @override
  String get trAll => 'Todos';

  @override
  String get trPlumbing => 'Gasfitería';

  @override
  String get trElectrical => 'Electricidad';

  @override
  String get trCarpentry => 'Carpintería';

  @override
  String get trLocksmith => 'Cerrajería';

  @override
  String get trSewing => 'Costura';

  @override
  String get trLessons => 'Clases';

  @override
  String get trPets => 'Mascotas';

  @override
  String get trGrocery => 'Bodega';

  @override
  String get trMinimarket => 'Minimarket';

  @override
  String get trNeighbor => 'De un vecino';

  @override
  String get roPlumber => 'Gasfitero';

  @override
  String get roElectrician => 'Electricista';

  @override
  String get roCarpenter => 'Carpintero';

  @override
  String get roLocksmith => 'Cerrajero';

  @override
  String get roSeamstress => 'Costurera';

  @override
  String get roTutor => 'Profesora de clases particulares';

  @override
  String get roPetWalker => 'Paseadora de mascotas';

  @override
  String get roNeighbor => 'Vecino';

  @override
  String get failWriteMessage => 'Escribe un mensaje.';

  @override
  String get failSaveMessage => 'No se pudo guardar tu mensaje.';

  @override
  String get failUpdateMessage => 'No se pudo actualizar el mensaje.';

  @override
  String get failPlaceName => 'Escribe el nombre del lugar.';

  @override
  String get failSaveAlert => 'No se pudo guardar tu aviso.';

  @override
  String get failUpdateAlert => 'No se pudo actualizar el aviso.';

  @override
  String get failSavePoint => 'No se pudo guardar el punto de acopio.';

  @override
  String get failLocation =>
      'No pudimos obtener tu ubicación. Inténtalo otra vez.';

  @override
  String get failNeedShort => 'Cuéntanos qué necesitas (al menos 3 letras).';

  @override
  String get failSavePhone => 'No se pudo guardar en tu teléfono.';

  @override
  String get failUpdateStatus => 'No se pudo actualizar el estado.';

  @override
  String get failAlreadyAccepted =>
      'Este pedido ya tiene una propuesta aceptada.';

  @override
  String get failDealNotFound => 'No encontramos este trato.';

  @override
  String get failCodeValidated => 'El código de este trato ya fue validado.';

  @override
  String get failValidateCodeFirst =>
      'Primero hay que validar el código de encuentro.';

  @override
  String get failStars => 'Elige de 1 a 5 estrellas.';

  @override
  String get failMarkDoneFirst => 'Primero marca el servicio como hecho.';

  @override
  String get failPersonNotFound => 'No encontramos a esta persona.';

  @override
  String get failSaveDeal => 'No se pudo guardar el trato en tu teléfono.';

  @override
  String get failSaveRating => 'No se pudo guardar tu calificación.';

  @override
  String get failOfferShort => 'Cuéntanos qué ofreces (al menos 3 letras).';

  @override
  String get failSavePending => 'No se pudo guardar el envío pendiente.';

  @override
  String get failUpdateQueue => 'No se pudo actualizar la cola.';

  @override
  String get failLocationOff =>
      'Activa la ubicación del teléfono para ver lo que hay cerca.';

  @override
  String get failLocationPermission =>
      'Sin permiso de ubicación. Puedes elegir tu zona a mano.';

  @override
  String get idioma => 'Idioma';

  @override
  String get wall1 => 'Necesito un taladro por una hora.';

  @override
  String get wall2 => 'Presto mi escalera de 3 metros. Pasa a recogerla.';

  @override
  String get wall3 => 'Cambio clases de tejido por ayuda con el celular.';

  @override
  String get wall4 => 'Busco quien me ayude a mover un mueble el sábado.';

  @override
  String get wall5 => 'Alquilo una máquina de coser por día.';

  @override
  String get wall6 => 'Necesito una carretilla prestada para el fin de semana.';
}
