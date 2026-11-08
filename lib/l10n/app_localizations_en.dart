// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Neighborhood Network';

  @override
  String get inicio => 'Home';

  @override
  String get vecinos => 'Neighbors';

  @override
  String get mensajes => 'Messages';

  @override
  String get emergencia => 'Emergency';

  @override
  String get perfil => 'Profile';

  @override
  String get algoNoSalioBien => 'Something went wrong';

  @override
  String get intentarOtraVez => 'Try again';

  @override
  String get cargando => 'Loading';

  @override
  String get unMomento => 'One moment…';

  @override
  String get atajos => 'Shortcuts';

  @override
  String get unToqueAbreEl => 'One tap opens the request already written';

  @override
  String get zonaAproximadaSinDireccion =>
      'Approximate area · no exact address';

  @override
  String zonaAprox1Km(Object p0, Object p1) {
    return 'Area $p0, $p1 (approx. 1 km)';
  }

  @override
  String get queNecesitasHoy => 'What do you need today?';

  @override
  String get cuentaloYLosVecinos =>
      'Tell us and your neighborhood will suggest how to solve it.';

  @override
  String get pedirAlgo => 'Request something';

  @override
  String get noPudimosVerDonde => 'We couldn’t see where you are';

  @override
  String get veQueHayCerca => 'See what’s near you';

  @override
  String get revisaQueLaUbicacion => 'Check that location is turned on.';

  @override
  String get tuUbicacionSeQueda =>
      'Your location stays on your phone. Neighbors will only see an area of about 1000 m.';

  @override
  String get buscando => 'Searching…';

  @override
  String get usarMiUbicacion => 'Use my location';

  @override
  String pedir(Object p0) {
    return 'Request: $p0';
  }

  @override
  String get noPudimosLeerTus =>
      'We couldn’t read your requests. Close and reopen the app.';

  @override
  String get misPedidos => 'My requests';

  @override
  String verTodosMisPedidos(Object p0) {
    return 'See all my requests ($p0)';
  }

  @override
  String get listoTuPedidoQuedo =>
      'Done: your request was saved. See its status on the next screen.';

  @override
  String get queNecesitas => 'What do you need?';

  @override
  String get eligeUnaFraseO =>
      'Choose a phrase or write in your own words. Your neighborhood will suggest how to solve it.';

  @override
  String get queTipoDeAyuda => 'What kind of help';

  @override
  String get eligeUnaFraseO2 => 'Choose a phrase or write it yourself';

  @override
  String conTusPalabras(Object p0) {
    return 'In your own words ($p0)';
  }

  @override
  String get paraCuandoLoNecesitas => 'When do you need it?';

  @override
  String get publicando => 'Posting…';

  @override
  String get publicar => 'Post';

  @override
  String get noPudimosLeerTus2 => 'We couldn’t read your requests.';

  @override
  String get enCurso => 'In progress';

  @override
  String get resueltos => 'Resolved';

  @override
  String enCursoResueltos(int active, int done) {
    return '$active in progress · $done resolved';
  }

  @override
  String get aunNoResolvisteNinguno => 'You haven’t resolved any yet';

  @override
  String get noTienesPedidosEn => 'You have no requests in progress';

  @override
  String get cuandoCierresUnTrato =>
      'When you close a deal and rate it, it will appear here.';

  @override
  String get pideAlgoDesdeInicio =>
      'Request something from Home and your neighborhood will suggest how to solve it.';

  @override
  String para(Object p0, Object p1) {
    return '$p0 · For: $p1';
  }

  @override
  String get explorarCerca => 'Explore nearby';

  @override
  String get losVecinosYNegocios =>
      'The neighbors and businesses are examples, placed around you.';

  @override
  String get servicios => 'Services';

  @override
  String get productos => 'Products';

  @override
  String get noPudimosCargarLo => 'We couldn’t load what is nearby.';

  @override
  String get nadaPorAhora => 'Nothing for now';

  @override
  String get noHayResultadosCon => 'No results for that category. Try \"All\".';

  @override
  String get verTodos => 'See all';

  @override
  String get ordenar => 'Sort';

  @override
  String get masRecomendados => 'Most recommended';

  @override
  String get masCerca => 'Closest';

  @override
  String get recomendados => 'Recommended';

  @override
  String get ejemplo => 'Example';

  @override
  String get aunSinRecomendaciones => 'No recommendations yet';

  @override
  String get podrasRecomendarloCuandoCierres =>
      'You will be able to recommend them once you close a deal with this person.';

  @override
  String get pedirEsteServicio => 'Request this service';

  @override
  String get loQuiero => 'I want it';

  @override
  String get noEncontramosEstePedido => 'We couldn’t find this request';

  @override
  String get puedeQueYaNo =>
      'It may no longer be on your phone. Go back to Home to see your requests.';

  @override
  String get propuestasDeTuBarrio => 'Proposals from your neighborhood';

  @override
  String get aquiElPrecioLo =>
      'Here each person sets the price after seeing your request. You choose. The proposals are examples.';

  @override
  String get reputacion => 'Reputation';

  @override
  String get cercania => 'Distance';

  @override
  String get precio => 'Price';

  @override
  String get noPudimosCargarLas => 'We couldn’t load the proposals.';

  @override
  String para2(Object p0) {
    return 'For: $p0';
  }

  @override
  String get todaviaNoHayServidor =>
      'There is no server yet: the proposals you see are examples.';

  @override
  String get enviando => 'Sending…';

  @override
  String get reintentarAhora => 'Retry now';

  @override
  String recomiendan(Object p0, Object p1) {
    return '$p0 · $p1 recommend';
  }

  @override
  String aprox(Object p0) {
    return '$p0 (approx.)';
  }

  @override
  String ofreceVisitaDeDiagnostico(Object p0) {
    return 'Offers a diagnostic visit: S/ $p0 (deducted from the final price)';
  }

  @override
  String get aceptarPropuesta => 'Accept proposal';

  @override
  String get aceptada => 'Accepted';

  @override
  String get faltaCalificar => 'Needs rating';

  @override
  String get resuelta => 'Resolved';

  @override
  String trato(Object p0) {
    return 'Deal: $p0';
  }

  @override
  String get abrirElChatDe => 'Open this deal’s chat';

  @override
  String get tuCodigoDeEncuentro => 'Your meeting code';

  @override
  String get codigoValidadoEncuentroConfirmado =>
      'Code verified. Meeting confirmed.';

  @override
  String get demoLaOtraPersona => 'Demo: the other person enters the code';

  @override
  String get todaviaNoHayCuentas =>
      'There are no accounts yet: this button acts as the other person, for the demo only.';

  @override
  String get encuentroConfirmadoConCodigo => 'Meeting confirmed with code';

  @override
  String get tiempoDesdeQueSe =>
      'Time since the code was verified. It is informational, not a charge.';

  @override
  String get servicioMarcadoComoHecho => 'Service marked as done.';

  @override
  String get servicioHecho => 'Service done';

  @override
  String get comoTeFue => 'How did it go?';

  @override
  String get comentarioOpcional => 'Comment (optional)';

  @override
  String get sumaAVecinosQue =>
      'Adds to \"neighbors who recommend\". It only counts because there was a deal with you.';

  @override
  String get graciasTuCalificacionQuedo =>
      'Thank you. Your rating was saved on your phone.';

  @override
  String get enviarCalificacion => 'Submit rating';

  @override
  String get tratoCerrado => 'Deal closed.';

  @override
  String get tratoResueltoYCalificado => 'Deal resolved and rated';

  @override
  String get servicioRealizadoEn => 'Service completed in';

  @override
  String get precioFinal => 'Final price';

  @override
  String get calificacionesTuyas => 'Your ratings';

  @override
  String get vecinosQueLoRecomiendan => 'Neighbors who recommend';

  @override
  String get necesidadesResueltas => 'Requests resolved';

  @override
  String get cadaNecesidadResueltaDeja =>
      'Every request you resolve leaves the neighborhood better prepared for the next one. The other person’s rating of you will be shown once there are accounts.';

  @override
  String etapaDe(Object p0, Object p1, Object p2) {
    return 'Step $p0 of $p1: $p2';
  }

  @override
  String get tu => 'You';

  @override
  String get favoresPrestamosYAyuda =>
      'Favors, loans and help between neighbors.';

  @override
  String get ofrecer => 'Offer';

  @override
  String get porAhoraLosVecinos =>
      'For now the neighbors on the wall are examples. What you post is saved on your phone.';

  @override
  String get piden => 'Asking';

  @override
  String get ofrecen => 'Offering';

  @override
  String get todas => 'All';

  @override
  String get nadiePideEstoPor => 'Nobody is asking for this right now';

  @override
  String get nadieOfreceEstoPor => 'Nobody is offering this right now';

  @override
  String get cambiaLaModalidadO =>
      'Change the type or ask the neighborhood for something yourself.';

  @override
  String get cambiaLaModalidadU =>
      'Change the type or offer something to the neighborhood yourself.';

  @override
  String get verTodas => 'See all';

  @override
  String aAprox(Object p0) {
    return '$p0 away (approx.)';
  }

  @override
  String get listoTuOfertaQuedo => 'Done: your offer was saved on your phone.';

  @override
  String get ofrecerAlgoAlBarrio => 'Offer something to the neighborhood';

  @override
  String get unaHerramientaTuTiempo =>
      'A tool, your time or a skill. You decide how.';

  @override
  String get publicarOferta => 'Post offer';

  @override
  String get comoLoOfreces => 'How do you offer it?';

  @override
  String get queOfreces => 'What do you offer';

  @override
  String get elChatDeCada => 'The chat for each deal.';

  @override
  String get noPudimosLeerTus3 => 'We couldn’t read your conversations.';

  @override
  String get aunNoTienesConversaciones => 'You have no conversations yet';

  @override
  String get cuandoAceptesUnaPropuesta =>
      'When you accept a proposal, that deal’s chat appears here.';

  @override
  String get escribeElPrimerMensaje => 'Write the first message';

  @override
  String tu2(Object p0) {
    return 'You: $p0';
  }

  @override
  String get noEncontramosEsteTrato => 'We couldn’t find this deal';

  @override
  String get vuelveAMensajesPara =>
      'Go back to Messages to see your conversations.';

  @override
  String get verElPedido => 'View the request';

  @override
  String get todaviaNoHayCuentas2 =>
      'There are no accounts yet: your messages are saved on your phone. Chat with the other person will arrive with the server.';

  @override
  String get noPudimosLeerLos => 'We couldn’t read the messages.';

  @override
  String get sinMensajesTodavia => 'No messages yet';

  @override
  String get escribeAbajoOToca => 'Write below or tap a quick phrase.';

  @override
  String get escribeUnMensaje => 'Write a message';

  @override
  String get enviarMensaje => 'Send message';

  @override
  String get guardado => 'Saved';

  @override
  String get ayudaDelBarrioCuando => 'Neighborhood help when it matters most.';

  @override
  String get serviciosOficiales => 'Official services';

  @override
  String get enPeligroLlamaAqui => 'In danger, call here first.';

  @override
  String get verificaEstosNumerosCon =>
      'Check these numbers against official sources before relying on them.';

  @override
  String get ayudaDelBarrio => 'Neighborhood help';

  @override
  String get avisaATusVecinos =>
      'Alert your neighbors. It does not replace official services.';

  @override
  String get necesitoAyuda => 'I need help';

  @override
  String get noPudimosLeerTus4 => 'We couldn’t read your alerts.';

  @override
  String get misAvisos => 'My alerts';

  @override
  String get todaviaNoHayVecinos =>
      'There are no connected neighbors who can respond yet: nobody will write to you from the app.';

  @override
  String get unBarrioPreparado => 'A prepared neighborhood';

  @override
  String get quePodriasOfrecerSi =>
      'What you could offer if something happens.';

  @override
  String get brigadistaVecinalVoluntario =>
      'Volunteer neighborhood brigade member';

  @override
  String get sinVerificarSoloQueda =>
      'Unverified. It is only saved on your phone.';

  @override
  String get puntosDeAcopio => 'Collection points';

  @override
  String get lugaresParaReunirAyuda =>
      'Places to gather aid. The ones you suggest stay unverified.';

  @override
  String get proponer => 'Suggest';

  @override
  String get aunNoHayPuntos =>
      'There are no collection points yet. Suggest one: a school, a church or a local shop.';

  @override
  String llamarAl(Object p0) {
    return 'Call $p0?';
  }

  @override
  String esteNumeroEstaPor(Object p0, Object p1) {
    return '$p0 · $p1.\nThis number still needs to be verified with official sources.';
  }

  @override
  String get cancelar => 'Cancel';

  @override
  String get llamar => 'Call';

  @override
  String noPudimosAbrirEl(Object p0) {
    return 'We couldn’t open the phone. Dial $p0 from your phone.';
  }

  @override
  String llamarANumero(Object p0, Object p1) {
    return 'Call $p0, number $p1';
  }

  @override
  String get porVerificar => 'To be verified';

  @override
  String get privado => 'Private';

  @override
  String get propuestoPorTiSin => 'Suggested by you · unverified';

  @override
  String get proponerUnPuntoDe => 'Suggest a collection point';

  @override
  String get unLugarDelBarrio =>
      'A place in the neighborhood to gather water, food or blankets.';

  @override
  String get guardarPunto => 'Save point';

  @override
  String get nombreDelLugar => 'Name of the place';

  @override
  String get referenciaOpcional => 'Landmark (optional)';

  @override
  String get porEjemploFrenteAl => 'For example: across from the park';

  @override
  String get tuAvisoQuedoGuardado =>
      'Your alert was saved. If it is serious, call official services now.';

  @override
  String get eligeQuePasaEl =>
      'Choose what is happening. The text is already written: sending takes one tap.';

  @override
  String get enviarAviso => 'Send alert';

  @override
  String get noSePudoGuardar => 'The alert could not be saved';

  @override
  String siEsUrgenteLlama(Object p0) {
    return '$p0 If it is urgent, call the official services.';
  }

  @override
  String get primeroLosServiciosOficiales => 'First, the official services';

  @override
  String get siHayPeligroAhora =>
      'If there is danger now, call emergency services before using the app. Neighbors do not replace the Fire Department, Police or SAMU.';

  @override
  String get quePasa => 'What is happening?';

  @override
  String get esteAvisoEsPrivado =>
      'This alert is private: it is not shown on the neighborhood wall.';

  @override
  String get quePasoPuedesCambiarlo => 'What happened (you can change it)';

  @override
  String get tuUbicacionExactaNo =>
      'Your exact location is not shared. It is saved on your phone and sent when there is internet.';

  @override
  String get tuAyudaAlBarrio =>
      'Your help to the neighborhood and your settings.';

  @override
  String get tuAyudaAlBarrio2 => 'Your help to the neighborhood';

  @override
  String get soloTuVesEste => 'Only you see this summary.';

  @override
  String get esEvidenciaDeLo =>
      'It is evidence of what you did, not points: it gives no priority or advantage.';

  @override
  String get verYEscucharMejor => 'See and hear better';

  @override
  String get tamanoDelTexto => 'Text size';

  @override
  String get normal => 'Normal';

  @override
  String get grande => 'Large';

  @override
  String get muyGrande => 'Extra large';

  @override
  String get apariencia => 'Appearance';

  @override
  String get sistema => 'System';

  @override
  String get claro => 'Light';

  @override
  String get oscuro => 'Dark';

  @override
  String get altoContraste => 'High contrast';

  @override
  String get textosMasOscurosY => 'Darker text and stronger borders.';

  @override
  String get vibracionAlConfirmar => 'Vibrate on confirm';

  @override
  String get unaVibracionCortaCuando =>
      'A short vibration when you send something.';

  @override
  String get ayudaYDatos => 'Help and data';

  @override
  String get verElTutorial => 'View the tutorial';

  @override
  String get tresPantallasParaEmpezar => 'Three screens to get started.';

  @override
  String get sobreEstePrototipo => 'About this prototype';

  @override
  String get queEsRealY => 'What is real and what is an example.';

  @override
  String get borrarMisDatosDe => 'Erase my data from this phone';

  @override
  String get pedidosTratosMensajesY =>
      'Requests, deals, messages and settings.';

  @override
  String get tratosResueltos => 'Deals resolved';

  @override
  String get personasDistintas => 'Different people';

  @override
  String get calificacionQueDiste => 'Rating you gave';

  @override
  String min(Object p0) {
    return '$p0 min';
  }

  @override
  String get tiempoEnTratos => 'Time in deals';

  @override
  String get esRealTusPedidos =>
      'It is real: your requests, deals, messages and settings are saved on your phone, it works without internet and the queue sends what is pending when the signal returns.\n\nIt is an example: the neighbors, businesses, proposals and prices you see, and the “sent” status, because there is no server or accounts yet.\n\nTo be verified: emergency numbers must be confirmed with official sources.';

  @override
  String get entendido => 'Got it';

  @override
  String get borrarTusDatos => 'Erase your data?';

  @override
  String get seBorraranTusPedidos =>
      'Your requests, deals, ratings, messages, alerts and settings will be erased from this phone.';

  @override
  String get continuar => 'Continue';

  @override
  String get ultimaConfirmacion => 'Final confirmation';

  @override
  String get estoNoSePuede =>
      'This cannot be undone. Are you sure you want to erase everything?';

  @override
  String get noConservar => 'No, keep it';

  @override
  String get siBorrarTodo => 'Yes, erase everything';

  @override
  String get listoBorramosTusDatos =>
      'Done: we erased your data from this phone.';

  @override
  String get cuentaQueNecesitas => 'Tell us what you need';

  @override
  String get tocaPedirAlgoY =>
      'Tap \"Request something\" and choose a phrase, or write in your own words. With a shortcut, it takes just two taps.';

  @override
  String get eligeAQuienY => 'Choose who and meet up';

  @override
  String get tuBarrioTePropone =>
      'Your neighborhood suggests how to solve it and each person sets their price. When you meet, you tell each other a 4-digit code.';

  @override
  String get calificaYConstruyeConfianza => 'Rate and build trust';

  @override
  String get alTerminarCalificasAsi =>
      'When it is done, you rate. That way the neighborhood knows who to trust. It also works without internet: your requests are sent later.';

  @override
  String get saltar => 'Skip';

  @override
  String get empezar => 'Get started';

  @override
  String get siguiente => 'Next';

  @override
  String todoAlDiaResueltos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n resolved',
      one: '1 resolved',
    );
    return 'All caught up · $_temp0';
  }

  @override
  String enCursoSolo(int active) {
    return '$active in progress';
  }

  @override
  String verTodosServicios(int n) {
    return 'See all services ($n)';
  }

  @override
  String verTodosProductos(int n) {
    return 'See all products ($n)';
  }

  @override
  String aDistancia(String d) {
    return '$d away';
  }

  @override
  String aDistanciaAprox(String d) {
    return '$d away (approx.)';
  }

  @override
  String vecinosRecomiendanEjemplo(int n) {
    return '$n neighbors recommend them (example)';
  }

  @override
  String vecinosRecomiendanEjemploTuyas(int n, int m) {
    String _temp0 = intl.Intl.pluralLogic(
      m,
      locale: localeName,
      other: '$m of yours',
      one: '1 of yours',
    );
    return '$n neighbors recommend them (example) + $_temp0';
  }

  @override
  String codigoDigitos(String digits) {
    return 'Code $digits';
  }

  @override
  String diselo(String name) {
    return 'Tell $name when they arrive. That way we confirm you really met and the deal counts toward reputation.';
  }

  @override
  String get servicioRealizado => 'Service completed';

  @override
  String servicioRealizadoEnTiempo(String time) {
    return 'Service completed in $time';
  }

  @override
  String recomendarA(String name) {
    return 'Recommend $name';
  }

  @override
  String reputacionDe(String name) {
    return '$name’s reputation';
  }

  @override
  String vecinosRecomiendanResumen(int n, int m) {
    String _temp0 = intl.Intl.pluralLogic(
      m,
      locale: localeName,
      other: '$m of yours',
      one: '1 of yours',
    );
    return '$n (example) + $_temp0';
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
  String get kindService => 'Service';

  @override
  String get kindProduct => 'Product';

  @override
  String get kindLoan => 'Loan';

  @override
  String get kindHelp => 'Help';

  @override
  String get hintService => 'A trade or professional';

  @override
  String get hintProduct => 'Something near you';

  @override
  String get hintLoan => 'Lend, rent or swap';

  @override
  String get hintHelp => 'A favor or time from someone';

  @override
  String get urgencyNow => 'Right now';

  @override
  String get urgencyToday => 'Today';

  @override
  String get urgencyTomorrow => 'Tomorrow';

  @override
  String get urgencyThisWeek => 'This week';

  @override
  String get suggService1 => 'I need a plumber to fix a leak';

  @override
  String get suggService2 =>
      'I need an electrician, the kitchen lights went out';

  @override
  String get suggProduct1 => 'I need 2 water jugs';

  @override
  String get suggProduct2 => 'I need bread and milk, I am unable to go out';

  @override
  String get suggLoan1 => 'I need a drill for an hour';

  @override
  String get suggLoan2 => 'I need a ladder for today';

  @override
  String get suggHelp1 => 'I need help moving a piece of furniture';

  @override
  String get suggHelp2 => 'I need someone to watch my child for 2 hours';

  @override
  String get quickPlumber => 'Plumber';

  @override
  String get quickElectrician => 'Electrician';

  @override
  String get quickWater => '2 water jugs';

  @override
  String get syncPending =>
      'Saved on your phone · it will be sent when there is internet';

  @override
  String get syncSentDemo => 'Sent · example neighborhood (demo)';

  @override
  String get syncSent => 'Sent';

  @override
  String get syncError => 'Could not send · tap to retry';

  @override
  String get badgePending => 'Pending';

  @override
  String get badgeSent => 'Sent';

  @override
  String get badgeRetry => 'Retry';

  @override
  String get phaseSending => 'Waiting to send';

  @override
  String get phaseError => 'Not sent · retry';

  @override
  String get phaseWaiting => 'With proposals';

  @override
  String get phaseActive => 'In progress';

  @override
  String get phaseRate => 'Needs rating';

  @override
  String get phaseDone => 'Resolved';

  @override
  String get modFree => 'Free';

  @override
  String get modBarter => 'Barter';

  @override
  String get modRent => 'Rent';

  @override
  String get modFreeHint => 'No cost: a favor between neighbors.';

  @override
  String get modBarterHint => 'You swap one thing or favor for another.';

  @override
  String get modRentHint =>
      'You lend it in exchange for a payment you both agree on.';

  @override
  String get sitEarthquake => 'Earthquake';

  @override
  String get sitFire => 'Fire';

  @override
  String get sitMedical => 'Medical';

  @override
  String get sitElderly => 'Elderly person at risk';

  @override
  String get sitViolence => 'Violence';

  @override
  String get tplEarthquake => 'There was an earthquake and I need help.';

  @override
  String get tplFire => 'There is a fire nearby and I need help.';

  @override
  String get tplMedical => 'I need urgent medical help.';

  @override
  String get tplElderly => 'An elderly person needs help right now.';

  @override
  String get tplViolence => 'I am in a situation of violence and I need help.';

  @override
  String get offPolice => 'National Police';

  @override
  String get offPoliceUse => 'Crime and immediate danger';

  @override
  String get offFire => 'Fire Department';

  @override
  String get offFireUse => 'Fires and rescues';

  @override
  String get offSamu => 'SAMU (ambulance)';

  @override
  String get offSamuUse => 'Medical emergencies';

  @override
  String get offCivil => 'Civil Defense';

  @override
  String get offCivilUse => 'Earthquakes and disasters';

  @override
  String get offLine100 => 'Line 100';

  @override
  String get offLine100Use => 'Family and sexual violence';

  @override
  String get capFirstAid => 'First aid';

  @override
  String get capMedkit => 'First-aid kit';

  @override
  String get capVehicle => 'Vehicle';

  @override
  String get capTools => 'Tools';

  @override
  String get capSupplies => 'Water or food';

  @override
  String get capCare => 'Caring for children or older adults';

  @override
  String get qpOnMyWay => 'I am on my way';

  @override
  String get qpAtDoor => 'I am at the door';

  @override
  String get qpWhatTime => 'What time can you come?';

  @override
  String get qpThanks => 'Thanks, all good';

  @override
  String get trAll => 'All';

  @override
  String get trPlumbing => 'Plumbing';

  @override
  String get trElectrical => 'Electrical';

  @override
  String get trCarpentry => 'Carpentry';

  @override
  String get trLocksmith => 'Locksmith';

  @override
  String get trSewing => 'Sewing';

  @override
  String get trLessons => 'Lessons';

  @override
  String get trPets => 'Pets';

  @override
  String get trGrocery => 'Grocery store';

  @override
  String get trMinimarket => 'Minimarket';

  @override
  String get trNeighbor => 'From a neighbor';

  @override
  String get roPlumber => 'Plumber';

  @override
  String get roElectrician => 'Electrician';

  @override
  String get roCarpenter => 'Carpenter';

  @override
  String get roLocksmith => 'Locksmith';

  @override
  String get roSeamstress => 'Seamstress';

  @override
  String get roTutor => 'Private tutor';

  @override
  String get roPetWalker => 'Pet walker';

  @override
  String get roNeighbor => 'Neighbor';

  @override
  String get failWriteMessage => 'Write a message.';

  @override
  String get failSaveMessage => 'Your message could not be saved.';

  @override
  String get failUpdateMessage => 'The message could not be updated.';

  @override
  String get failPlaceName => 'Write the name of the place.';

  @override
  String get failSaveAlert => 'Your alert could not be saved.';

  @override
  String get failUpdateAlert => 'The alert could not be updated.';

  @override
  String get failSavePoint => 'The collection point could not be saved.';

  @override
  String get failLocation => 'We couldn’t get your location. Please try again.';

  @override
  String get failNeedShort => 'Tell us what you need (at least 3 letters).';

  @override
  String get failSavePhone => 'It could not be saved on your phone.';

  @override
  String get failUpdateStatus => 'The status could not be updated.';

  @override
  String get failAlreadyAccepted =>
      'This request already has an accepted proposal.';

  @override
  String get failDealNotFound => 'We couldn’t find this deal.';

  @override
  String get failCodeValidated => 'This deal’s code was already verified.';

  @override
  String get failValidateCodeFirst =>
      'First the meeting code must be verified.';

  @override
  String get failStars => 'Choose 1 to 5 stars.';

  @override
  String get failMarkDoneFirst => 'First mark the service as done.';

  @override
  String get failPersonNotFound => 'We couldn’t find this person.';

  @override
  String get failSaveDeal => 'The deal could not be saved on your phone.';

  @override
  String get failSaveRating => 'Your rating could not be saved.';

  @override
  String get failOfferShort => 'Tell us what you offer (at least 3 letters).';

  @override
  String get failSavePending => 'The pending item could not be saved.';

  @override
  String get failUpdateQueue => 'The queue could not be updated.';

  @override
  String get failLocationOff =>
      'Turn on your phone’s location to see what is nearby.';

  @override
  String get failLocationPermission =>
      'Location permission denied. You can choose your area by hand.';

  @override
  String get idioma => 'Language';

  @override
  String get wall1 => 'I need a drill for an hour.';

  @override
  String get wall2 => 'I am lending my 3-meter ladder. Come pick it up.';

  @override
  String get wall3 => 'I will swap knitting lessons for help with my phone.';

  @override
  String get wall4 =>
      'Looking for someone to help me move a piece of furniture on Saturday.';

  @override
  String get wall5 => 'I rent out a sewing machine by the day.';

  @override
  String get wall6 => 'I need to borrow a wheelbarrow for the weekend.';

  @override
  String get locBannerLastTitle => 'Using your last known area';

  @override
  String get locBannerLastBody =>
      'Distances are approximate until the GPS signal returns.';

  @override
  String get locSourceLive => 'location on';

  @override
  String get locSourceLast => 'last known position';

  @override
  String get locSourceSaved => 'saved area';

  @override
  String locZoneLine(String zone, String source) {
    return '$zone · $source';
  }

  @override
  String get locRefresh => 'Update location';

  @override
  String get locEnable => 'Turn on location';

  @override
  String get locOpenSettings => 'Open settings';

  @override
  String get failLocationBlocked =>
      'Location permission is blocked. Turn it on in your phone settings.';

  @override
  String get locSettingTitle => 'Use my location';

  @override
  String get locSettingHint =>
      'It shows what is nearby. Only your ~1 km area is remembered, never your exact location.';

  @override
  String get locForget => 'Forget my saved area';

  @override
  String get locForgotten => 'Done: we forgot your saved area.';

  @override
  String get connOffline => 'No connection · you can keep using the app';

  @override
  String connOfflinePending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n items waiting to send',
      one: '1 item waiting to send',
    );
    return 'No connection · $_temp0';
  }

  @override
  String connSyncing(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pending items',
      one: '1 pending item',
    );
    return 'Sending $_temp0…';
  }

  @override
  String get connSynced => 'Everything sent';

  @override
  String get profTitle => 'My profile';

  @override
  String get profNone => 'You don’t have a profile yet';

  @override
  String get profNoneHint =>
      'Create one so your neighborhood knows what to call you.';

  @override
  String get profCreate => 'Create my profile';

  @override
  String get profEdit => 'Edit profile';

  @override
  String get profLocalNote =>
      'Your profile is saved only on this phone. There are no accounts yet: it cannot be used to sign in from another phone.';

  @override
  String get profUsername => 'Username';

  @override
  String get profUsernameHelp =>
      '3 to 20 letters, numbers, dots or underscores';

  @override
  String get profEmail => 'Email (optional)';

  @override
  String get profEmailHelp =>
      'For now it is only saved on your phone; it is not verified.';

  @override
  String get profConsent =>
      'I understand that my neighbors can see my username and my ~1 km area, and that my exact address never leaves my phone.';

  @override
  String get profSave => 'Save';

  @override
  String get profSaved => 'Profile saved';

  @override
  String get welcomeTitle => 'Welcome to the neighborhood!';

  @override
  String get welcomeStep1 => 'Step 1 of 2 · Your profile';

  @override
  String get welcomeStep2 => 'Step 2 of 2 · Where you are';

  @override
  String get welcomeSkip => 'Not now';

  @override
  String get welcomeFinish => 'Finish';

  @override
  String get welcomeWhere =>
      'Mark where you are to see what is nearby. You can change it any time.';

  @override
  String get welcomeMark => 'Mark where I am';

  @override
  String get welcomeDone => 'All set, you marked where you are.';

  @override
  String get addrTitle => 'My addresses';

  @override
  String get addrSubtitle => 'Distances are measured from the active address.';

  @override
  String get addrAdd => 'Add address';

  @override
  String get addrActive => 'Active';

  @override
  String get addrUse => 'Use this one';

  @override
  String get addrDelete => 'Delete';

  @override
  String get addrEmpty => 'You haven’t marked where you are yet';

  @override
  String get addrEmptyHint =>
      'Use your location and give it a name, such as Home or Work.';

  @override
  String get addrNameLabel => 'Name (Home, Work…)';

  @override
  String get addrHome => 'Home';

  @override
  String get addrWork => 'Work';

  @override
  String get addrOther => 'Other';

  @override
  String get addrRef => 'Landmark (optional)';

  @override
  String get addrRefHelp => 'For example: across from the park, 2nd floor';

  @override
  String get addrGetLocation => 'Use my current location';

  @override
  String get addrRelocate => 'Mark again';

  @override
  String addrGot(String zone) {
    return 'Location marked · $zone';
  }

  @override
  String get addrPrivacy =>
      'Your exact address stays on your phone. Neighbors only see your ~1 km area.';

  @override
  String get addrSave => 'Save address';

  @override
  String get addrSaved => 'Address saved';

  @override
  String get addrDeleted => 'Address deleted';

  @override
  String addrDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get addrDeleteBody =>
      'It is removed from your phone. You can mark it again any time.';

  @override
  String addrHeroLine(String name, String zone) {
    return '$name · $zone';
  }

  @override
  String get failUsername =>
      'The username must be 3 to 20 letters, numbers, dots or underscores.';

  @override
  String get failEmail => 'Enter a valid email or leave it empty.';

  @override
  String get failAddressName => 'Give the address a name.';

  @override
  String get failAddressNoLocation => 'Mark your location first.';

  @override
  String get failSaveProfile => 'Your profile could not be saved.';

  @override
  String get failSaveAddress => 'The address could not be saved.';

  @override
  String get failUpdateAddress => 'The address could not be updated.';

  @override
  String get planTitle => 'My emergency plan';

  @override
  String get planSubtitle =>
      'Get ready before something happens. Everything works without internet.';

  @override
  String get contactsTitle => 'Trusted contacts';

  @override
  String get contactsHint =>
      'We alert them by SMS when you ask for help. Works without internet.';

  @override
  String get contactsEmpty => 'You have no contacts yet';

  @override
  String get contactAdd => 'Add contact';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone';

  @override
  String get contactPhoneHelp =>
      'Numbers only; with the country code if abroad';

  @override
  String get contactSave => 'Save contact';

  @override
  String get contactDeleted => 'Contact deleted';

  @override
  String contactDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get meetingTitle => 'Meeting point';

  @override
  String get meetingHint =>
      'A safe place where your family meets if they cannot get home.';

  @override
  String get meetingEmpty => 'Tap to choose the place';

  @override
  String get meetingLabel => 'Place (for example: the park on the corner)';

  @override
  String get meetingSave => 'Save place';

  @override
  String get backpackTitle => 'Emergency backpack';

  @override
  String get backpackHint => 'Mark what you already have packed.';

  @override
  String backpackProgress(int done, int total) {
    return '$done of $total ready';
  }

  @override
  String get bpWater => 'Water for 3 days';

  @override
  String get bpFood => 'Non-perishable food';

  @override
  String get bpFlashlight => 'Flashlight and batteries';

  @override
  String get bpRadio => 'Battery radio';

  @override
  String get bpFirstAid => 'First-aid kit';

  @override
  String get bpMeds => 'Family medicines';

  @override
  String get bpDocs => 'Copies of documents';

  @override
  String get bpCash => 'Cash';

  @override
  String get bpCharger => 'Portable charger';

  @override
  String get bpWhistle => 'Whistle';

  @override
  String get bpClothes => 'Clothes and a blanket';

  @override
  String get sosNotifyTitle => 'Also alert my contacts';

  @override
  String get sosNotifySub =>
      'Your messages app opens with the alert already written; you tap Send. Works without internet.';

  @override
  String get sosNoContacts =>
      'Add trusted contacts in your emergency plan to alert them by SMS.';

  @override
  String get sosSmsFailed =>
      'We couldn’t open your messages. Call them instead.';

  @override
  String smsAlert(String situation, String text) {
    return 'ALERT ($situation): $text';
  }

  @override
  String smsZone(String lat, String lng, String link) {
    return 'My approx. area: $lat, $lng (~1 km) $link';
  }

  @override
  String smsRef(String ref) {
    return 'Landmark: $ref';
  }

  @override
  String get smsFooter =>
      'Sent from Neighborhood Network. If it is serious, call emergency services.';

  @override
  String get failContactName => 'Write the contact’s name.';

  @override
  String get failContactPhone => 'Enter a valid phone number (numbers only).';

  @override
  String get failContactDup => 'You already have that contact.';

  @override
  String get failContactMax => 'You can have up to 5 contacts.';

  @override
  String get failSaveContact => 'The contact could not be saved.';

  @override
  String get hintNeed3 => 'Write at least 3 letters to continue.';

  @override
  String get hintAddr => 'Mark your location and give it a name to save.';

  @override
  String get hintContact => 'Write a name and a phone number to save.';

  @override
  String get hintProfile =>
      'Write a username of 3 or more letters and accept to continue.';

  @override
  String get hintStars => 'Choose how many stars to give in order to send.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsRowSub => 'Text size, language, appearance and location.';

  @override
  String get bidOfferBtn => 'Make an offer';

  @override
  String get bidHelpBtn => 'Offer my help';

  @override
  String get bidMakeOffer => 'Make my offer';

  @override
  String get bidMakeProposal => 'Make my proposal';

  @override
  String get bidChangeOffer => 'Change my offer';

  @override
  String get bidChangeProposal => 'Change my proposal';

  @override
  String get bidMyOffer => 'My offer';

  @override
  String get bidMyProposal => 'My proposal';

  @override
  String bidsTitle(int n) {
    return 'Offers ($n)';
  }

  @override
  String proposalsCount(int n) {
    return 'Proposals ($n)';
  }

  @override
  String get bidRuleHigh => 'The highest offer wins.';

  @override
  String bidRuleHighRef(String ref) {
    return 'The highest offer wins. Reference price: $ref.';
  }

  @override
  String get bidRuleLow =>
      'The lowest proposal wins. You can propose 0 for a solidarity exchange.';

  @override
  String get bidBestOffer => 'Best offer';

  @override
  String get bidBestProposal => 'Best proposal';

  @override
  String get bidPriceLabel => 'Price in soles (0 = solidarity exchange)';

  @override
  String get bidPriceOfferLabel => 'Your offer in soles';

  @override
  String get bidMessageLabel => 'Message (optional)';

  @override
  String get bidMessageHint => 'What you offer, materials, conditions…';

  @override
  String get bidWhenLabel => 'When you can';

  @override
  String get bidWhenHint => 'Today 4:00 p.m.';

  @override
  String get bidSendOffer => 'Send offer';

  @override
  String get bidSendProposal => 'Send proposal';

  @override
  String get bidSaved => 'Done: your offer was saved on your phone.';

  @override
  String get bidHint => 'Enter a price (0 = solidarity exchange).';

  @override
  String get bidNone => 'No offers yet. Be the first!';

  @override
  String bidYourOffer(String price) {
    return 'Your offer: $price';
  }

  @override
  String get bidNotFound => 'We couldn’t find this listing';

  @override
  String get bidDemoNote =>
      'The other offers are examples. Yours is saved on your phone and sent when there is internet.';

  @override
  String get bidDemoSale1 => 'I can pick it up today.';

  @override
  String get bidDemoSale2 => 'I pay cash and will come by tomorrow.';

  @override
  String get bidDemoReq1 => 'I can handle it with my own tools.';

  @override
  String get bidDemoReq2 => 'I can come first thing tomorrow.';

  @override
  String get bidDemoWhen1 => 'Today 6:00 p.m.';

  @override
  String get bidDemoWhen2 => 'Tomorrow 9:00 a.m.';

  @override
  String get failBidAmount => 'Enter a valid price, from 0 to 99,999 soles.';

  @override
  String get failBidSave => 'Your offer could not be saved.';

  @override
  String get failBidUpdate => 'The offer could not be updated.';
}
