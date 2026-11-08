import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Red del barrio'**
  String get appName;

  /// No description provided for @inicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get inicio;

  /// No description provided for @vecinos.
  ///
  /// In es, this message translates to:
  /// **'Vecinos'**
  String get vecinos;

  /// No description provided for @mensajes.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get mensajes;

  /// No description provided for @emergencia.
  ///
  /// In es, this message translates to:
  /// **'Emergencia'**
  String get emergencia;

  /// No description provided for @perfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @algoNoSalioBien.
  ///
  /// In es, this message translates to:
  /// **'Algo no salió bien'**
  String get algoNoSalioBien;

  /// No description provided for @intentarOtraVez.
  ///
  /// In es, this message translates to:
  /// **'Intentar otra vez'**
  String get intentarOtraVez;

  /// No description provided for @cargando.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get cargando;

  /// No description provided for @unMomento.
  ///
  /// In es, this message translates to:
  /// **'Un momento…'**
  String get unMomento;

  /// No description provided for @atajos.
  ///
  /// In es, this message translates to:
  /// **'Atajos'**
  String get atajos;

  /// No description provided for @unToqueAbreEl.
  ///
  /// In es, this message translates to:
  /// **'Un toque abre el pedido ya escrito'**
  String get unToqueAbreEl;

  /// No description provided for @zonaAproximadaSinDireccion.
  ///
  /// In es, this message translates to:
  /// **'Zona aproximada · sin dirección exacta'**
  String get zonaAproximadaSinDireccion;

  /// No description provided for @zonaAprox1Km.
  ///
  /// In es, this message translates to:
  /// **'Zona {p0}, {p1} (aprox. 1 km)'**
  String zonaAprox1Km(Object p0, Object p1);

  /// No description provided for @queNecesitasHoy.
  ///
  /// In es, this message translates to:
  /// **'¿Qué necesitas hoy?'**
  String get queNecesitasHoy;

  /// No description provided for @cuentaloYLosVecinos.
  ///
  /// In es, this message translates to:
  /// **'Cuéntalo y tu barrio te propone cómo resolverlo.'**
  String get cuentaloYLosVecinos;

  /// No description provided for @pedirAlgo.
  ///
  /// In es, this message translates to:
  /// **'Pedir algo'**
  String get pedirAlgo;

  /// No description provided for @noPudimosVerDonde.
  ///
  /// In es, this message translates to:
  /// **'No pudimos ver dónde estás'**
  String get noPudimosVerDonde;

  /// No description provided for @veQueHayCerca.
  ///
  /// In es, this message translates to:
  /// **'Ve qué hay cerca de ti'**
  String get veQueHayCerca;

  /// No description provided for @revisaQueLaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Revisa que la ubicación esté activada.'**
  String get revisaQueLaUbicacion;

  /// No description provided for @tuUbicacionSeQueda.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación se queda en tu teléfono. Los vecinos solo verán una zona de unos 1000 m.'**
  String get tuUbicacionSeQueda;

  /// No description provided for @buscando.
  ///
  /// In es, this message translates to:
  /// **'Buscando…'**
  String get buscando;

  /// No description provided for @usarMiUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get usarMiUbicacion;

  /// No description provided for @pedir.
  ///
  /// In es, this message translates to:
  /// **'Pedir: {p0}'**
  String pedir(Object p0);

  /// No description provided for @noPudimosLeerTus.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer tus pedidos. Cierra y abre la app.'**
  String get noPudimosLeerTus;

  /// No description provided for @misPedidos.
  ///
  /// In es, this message translates to:
  /// **'Mis pedidos'**
  String get misPedidos;

  /// No description provided for @verTodosMisPedidos.
  ///
  /// In es, this message translates to:
  /// **'Ver todos mis pedidos ({p0})'**
  String verTodosMisPedidos(Object p0);

  /// No description provided for @listoTuPedidoQuedo.
  ///
  /// In es, this message translates to:
  /// **'Listo: tu pedido quedó guardado. Mira su estado en la siguiente pantalla.'**
  String get listoTuPedidoQuedo;

  /// No description provided for @queNecesitas.
  ///
  /// In es, this message translates to:
  /// **'¿Qué necesitas?'**
  String get queNecesitas;

  /// No description provided for @eligeUnaFraseO.
  ///
  /// In es, this message translates to:
  /// **'Elige una frase o escribe con tus palabras. Tu barrio te propone cómo resolverlo.'**
  String get eligeUnaFraseO;

  /// No description provided for @queTipoDeAyuda.
  ///
  /// In es, this message translates to:
  /// **'Qué tipo de ayuda'**
  String get queTipoDeAyuda;

  /// No description provided for @eligeUnaFraseO2.
  ///
  /// In es, this message translates to:
  /// **'Elige una frase o escríbelo'**
  String get eligeUnaFraseO2;

  /// No description provided for @conTusPalabras.
  ///
  /// In es, this message translates to:
  /// **'Con tus palabras ({p0})'**
  String conTusPalabras(Object p0);

  /// No description provided for @paraCuandoLoNecesitas.
  ///
  /// In es, this message translates to:
  /// **'¿Para cuándo lo necesitas?'**
  String get paraCuandoLoNecesitas;

  /// No description provided for @publicando.
  ///
  /// In es, this message translates to:
  /// **'Publicando…'**
  String get publicando;

  /// No description provided for @publicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicar;

  /// No description provided for @noPudimosLeerTus2.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer tus pedidos.'**
  String get noPudimosLeerTus2;

  /// No description provided for @enCurso.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get enCurso;

  /// No description provided for @resueltos.
  ///
  /// In es, this message translates to:
  /// **'Resueltos'**
  String get resueltos;

  /// No description provided for @enCursoResueltos.
  ///
  /// In es, this message translates to:
  /// **'{active} en curso · {done} resueltos'**
  String enCursoResueltos(int active, int done);

  /// No description provided for @aunNoResolvisteNinguno.
  ///
  /// In es, this message translates to:
  /// **'Aún no resolviste ninguno'**
  String get aunNoResolvisteNinguno;

  /// No description provided for @noTienesPedidosEn.
  ///
  /// In es, this message translates to:
  /// **'No tienes pedidos en curso'**
  String get noTienesPedidosEn;

  /// No description provided for @cuandoCierresUnTrato.
  ///
  /// In es, this message translates to:
  /// **'Cuando cierres un trato y lo califiques, aparecerá aquí.'**
  String get cuandoCierresUnTrato;

  /// No description provided for @pideAlgoDesdeInicio.
  ///
  /// In es, this message translates to:
  /// **'Pide algo desde Inicio y tu barrio te propone cómo resolverlo.'**
  String get pideAlgoDesdeInicio;

  /// No description provided for @para.
  ///
  /// In es, this message translates to:
  /// **'{p0} · Para: {p1}'**
  String para(Object p0, Object p1);

  /// No description provided for @explorarCerca.
  ///
  /// In es, this message translates to:
  /// **'Explorar cerca'**
  String get explorarCerca;

  /// No description provided for @losVecinosYNegocios.
  ///
  /// In es, this message translates to:
  /// **'Los vecinos y negocios son de ejemplo, ubicados alrededor de ti.'**
  String get losVecinosYNegocios;

  /// No description provided for @servicios.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get servicios;

  /// No description provided for @productos.
  ///
  /// In es, this message translates to:
  /// **'Productos'**
  String get productos;

  /// No description provided for @noPudimosCargarLo.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar lo que hay cerca.'**
  String get noPudimosCargarLo;

  /// No description provided for @nadaPorAhora.
  ///
  /// In es, this message translates to:
  /// **'Nada por ahora'**
  String get nadaPorAhora;

  /// No description provided for @noHayResultadosCon.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados con ese rubro. Prueba con \"Todos\".'**
  String get noHayResultadosCon;

  /// No description provided for @verTodos.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get verTodos;

  /// No description provided for @ordenar.
  ///
  /// In es, this message translates to:
  /// **'Ordenar'**
  String get ordenar;

  /// No description provided for @masRecomendados.
  ///
  /// In es, this message translates to:
  /// **'Más recomendados'**
  String get masRecomendados;

  /// No description provided for @masCerca.
  ///
  /// In es, this message translates to:
  /// **'Más cerca'**
  String get masCerca;

  /// No description provided for @recomendados.
  ///
  /// In es, this message translates to:
  /// **'Recomendados'**
  String get recomendados;

  /// No description provided for @ejemplo.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo'**
  String get ejemplo;

  /// No description provided for @aunSinRecomendaciones.
  ///
  /// In es, this message translates to:
  /// **'Aún sin recomendaciones'**
  String get aunSinRecomendaciones;

  /// No description provided for @podrasRecomendarloCuandoCierres.
  ///
  /// In es, this message translates to:
  /// **'Podrás recomendarlo cuando cierres un trato con esta persona.'**
  String get podrasRecomendarloCuandoCierres;

  /// No description provided for @pedirEsteServicio.
  ///
  /// In es, this message translates to:
  /// **'Pedir este servicio'**
  String get pedirEsteServicio;

  /// No description provided for @loQuiero.
  ///
  /// In es, this message translates to:
  /// **'Lo quiero'**
  String get loQuiero;

  /// No description provided for @noEncontramosEstePedido.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este pedido'**
  String get noEncontramosEstePedido;

  /// No description provided for @puedeQueYaNo.
  ///
  /// In es, this message translates to:
  /// **'Puede que ya no esté en tu teléfono. Vuelve a Inicio para ver tus pedidos.'**
  String get puedeQueYaNo;

  /// No description provided for @propuestasDeTuBarrio.
  ///
  /// In es, this message translates to:
  /// **'Propuestas de tu barrio'**
  String get propuestasDeTuBarrio;

  /// No description provided for @aquiElPrecioLo.
  ///
  /// In es, this message translates to:
  /// **'Aquí el precio lo pone cada persona al ver tu pedido. Tú eliges. Las propuestas son de ejemplo.'**
  String get aquiElPrecioLo;

  /// No description provided for @reputacion.
  ///
  /// In es, this message translates to:
  /// **'Reputación'**
  String get reputacion;

  /// No description provided for @cercania.
  ///
  /// In es, this message translates to:
  /// **'Cercanía'**
  String get cercania;

  /// No description provided for @precio.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get precio;

  /// No description provided for @noPudimosCargarLas.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las propuestas.'**
  String get noPudimosCargarLas;

  /// No description provided for @para2.
  ///
  /// In es, this message translates to:
  /// **'Para: {p0}'**
  String para2(Object p0);

  /// No description provided for @todaviaNoHayServidor.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay servidor: las propuestas que ves son de ejemplo.'**
  String get todaviaNoHayServidor;

  /// No description provided for @enviando.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get enviando;

  /// No description provided for @reintentarAhora.
  ///
  /// In es, this message translates to:
  /// **'Reintentar ahora'**
  String get reintentarAhora;

  /// No description provided for @recomiendan.
  ///
  /// In es, this message translates to:
  /// **'{p0} · {p1} recomiendan'**
  String recomiendan(Object p0, Object p1);

  /// No description provided for @aprox.
  ///
  /// In es, this message translates to:
  /// **'{p0} (aprox.)'**
  String aprox(Object p0);

  /// No description provided for @ofreceVisitaDeDiagnostico.
  ///
  /// In es, this message translates to:
  /// **'Ofrece visita de diagnóstico: S/ {p0} (se descuenta)'**
  String ofreceVisitaDeDiagnostico(Object p0);

  /// No description provided for @aceptarPropuesta.
  ///
  /// In es, this message translates to:
  /// **'Aceptar propuesta'**
  String get aceptarPropuesta;

  /// No description provided for @aceptada.
  ///
  /// In es, this message translates to:
  /// **'Aceptada'**
  String get aceptada;

  /// No description provided for @faltaCalificar.
  ///
  /// In es, this message translates to:
  /// **'Falta calificar'**
  String get faltaCalificar;

  /// No description provided for @resuelta.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get resuelta;

  /// No description provided for @trato.
  ///
  /// In es, this message translates to:
  /// **'Trato: {p0}'**
  String trato(Object p0);

  /// No description provided for @abrirElChatDe.
  ///
  /// In es, this message translates to:
  /// **'Abrir el chat de este trato'**
  String get abrirElChatDe;

  /// No description provided for @tuCodigoDeEncuentro.
  ///
  /// In es, this message translates to:
  /// **'Tu código de encuentro'**
  String get tuCodigoDeEncuentro;

  /// No description provided for @codigoValidadoEncuentroConfirmado.
  ///
  /// In es, this message translates to:
  /// **'Código validado. Encuentro confirmado.'**
  String get codigoValidadoEncuentroConfirmado;

  /// No description provided for @demoLaOtraPersona.
  ///
  /// In es, this message translates to:
  /// **'Demo: la otra persona ingresa el código'**
  String get demoLaOtraPersona;

  /// No description provided for @todaviaNoHayCuentas.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cuentas: este botón hace de la otra persona solo para la demostración.'**
  String get todaviaNoHayCuentas;

  /// No description provided for @encuentroConfirmadoConCodigo.
  ///
  /// In es, this message translates to:
  /// **'Encuentro confirmado con código'**
  String get encuentroConfirmadoConCodigo;

  /// No description provided for @tiempoDesdeQueSe.
  ///
  /// In es, this message translates to:
  /// **'Tiempo desde que se validó el código. Es informativo, no es un cobro.'**
  String get tiempoDesdeQueSe;

  /// No description provided for @servicioMarcadoComoHecho.
  ///
  /// In es, this message translates to:
  /// **'Servicio marcado como hecho.'**
  String get servicioMarcadoComoHecho;

  /// No description provided for @servicioHecho.
  ///
  /// In es, this message translates to:
  /// **'Servicio hecho'**
  String get servicioHecho;

  /// No description provided for @comoTeFue.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te fue?'**
  String get comoTeFue;

  /// No description provided for @comentarioOpcional.
  ///
  /// In es, this message translates to:
  /// **'Comentario (opcional)'**
  String get comentarioOpcional;

  /// No description provided for @sumaAVecinosQue.
  ///
  /// In es, this message translates to:
  /// **'Suma a \"vecinos que lo recomiendan\". Solo cuenta porque hubo un trato contigo.'**
  String get sumaAVecinosQue;

  /// No description provided for @graciasTuCalificacionQuedo.
  ///
  /// In es, this message translates to:
  /// **'Gracias. Tu calificación quedó guardada en tu teléfono.'**
  String get graciasTuCalificacionQuedo;

  /// No description provided for @enviarCalificacion.
  ///
  /// In es, this message translates to:
  /// **'Enviar calificación'**
  String get enviarCalificacion;

  /// No description provided for @tratoCerrado.
  ///
  /// In es, this message translates to:
  /// **'Trato cerrado.'**
  String get tratoCerrado;

  /// No description provided for @tratoResueltoYCalificado.
  ///
  /// In es, this message translates to:
  /// **'Trato resuelto y calificado'**
  String get tratoResueltoYCalificado;

  /// No description provided for @servicioRealizadoEn.
  ///
  /// In es, this message translates to:
  /// **'Servicio realizado en'**
  String get servicioRealizadoEn;

  /// No description provided for @precioFinal.
  ///
  /// In es, this message translates to:
  /// **'Precio final'**
  String get precioFinal;

  /// No description provided for @calificacionesTuyas.
  ///
  /// In es, this message translates to:
  /// **'Calificaciones tuyas'**
  String get calificacionesTuyas;

  /// No description provided for @vecinosQueLoRecomiendan.
  ///
  /// In es, this message translates to:
  /// **'Vecinos que lo recomiendan'**
  String get vecinosQueLoRecomiendan;

  /// No description provided for @necesidadesResueltas.
  ///
  /// In es, this message translates to:
  /// **'Necesidades resueltas'**
  String get necesidadesResueltas;

  /// No description provided for @cadaNecesidadResueltaDeja.
  ///
  /// In es, this message translates to:
  /// **'Cada necesidad resuelta deja al barrio mejor preparado para la siguiente. La calificación de la otra persona hacia ti se mostrará cuando haya cuentas.'**
  String get cadaNecesidadResueltaDeja;

  /// No description provided for @etapaDe.
  ///
  /// In es, this message translates to:
  /// **'Etapa {p0} de {p1}: {p2}'**
  String etapaDe(Object p0, Object p1, Object p2);

  /// No description provided for @tu.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get tu;

  /// No description provided for @favoresPrestamosYAyuda.
  ///
  /// In es, this message translates to:
  /// **'Favores, préstamos y ayuda entre vecinos.'**
  String get favoresPrestamosYAyuda;

  /// No description provided for @ofrecer.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer'**
  String get ofrecer;

  /// No description provided for @porAhoraLosVecinos.
  ///
  /// In es, this message translates to:
  /// **'Por ahora los vecinos del muro son de ejemplo. Lo que publiques queda guardado en tu teléfono.'**
  String get porAhoraLosVecinos;

  /// No description provided for @piden.
  ///
  /// In es, this message translates to:
  /// **'Piden'**
  String get piden;

  /// No description provided for @ofrecen.
  ///
  /// In es, this message translates to:
  /// **'Ofrecen'**
  String get ofrecen;

  /// No description provided for @todas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get todas;

  /// No description provided for @nadiePideEstoPor.
  ///
  /// In es, this message translates to:
  /// **'Nadie pide esto por ahora'**
  String get nadiePideEstoPor;

  /// No description provided for @nadieOfreceEstoPor.
  ///
  /// In es, this message translates to:
  /// **'Nadie ofrece esto por ahora'**
  String get nadieOfreceEstoPor;

  /// No description provided for @cambiaLaModalidadO.
  ///
  /// In es, this message translates to:
  /// **'Cambia la modalidad o pide tú algo al barrio.'**
  String get cambiaLaModalidadO;

  /// No description provided for @cambiaLaModalidadU.
  ///
  /// In es, this message translates to:
  /// **'Cambia la modalidad u ofrece tú algo al barrio.'**
  String get cambiaLaModalidadU;

  /// No description provided for @verTodas.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get verTodas;

  /// No description provided for @aAprox.
  ///
  /// In es, this message translates to:
  /// **'a {p0} (aprox.)'**
  String aAprox(Object p0);

  /// No description provided for @listoTuOfertaQuedo.
  ///
  /// In es, this message translates to:
  /// **'Listo: tu oferta quedó guardada en tu teléfono.'**
  String get listoTuOfertaQuedo;

  /// No description provided for @ofrecerAlgoAlBarrio.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer algo al barrio'**
  String get ofrecerAlgoAlBarrio;

  /// No description provided for @unaHerramientaTuTiempo.
  ///
  /// In es, this message translates to:
  /// **'Una herramienta, tu tiempo o una habilidad. Tú decides cómo.'**
  String get unaHerramientaTuTiempo;

  /// No description provided for @publicarOferta.
  ///
  /// In es, this message translates to:
  /// **'Publicar oferta'**
  String get publicarOferta;

  /// No description provided for @comoLoOfreces.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo lo ofreces?'**
  String get comoLoOfreces;

  /// No description provided for @queOfreces.
  ///
  /// In es, this message translates to:
  /// **'Qué ofreces'**
  String get queOfreces;

  /// No description provided for @elChatDeCada.
  ///
  /// In es, this message translates to:
  /// **'El chat de cada trato.'**
  String get elChatDeCada;

  /// No description provided for @noPudimosLeerTus3.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer tus conversaciones.'**
  String get noPudimosLeerTus3;

  /// No description provided for @aunNoTienesConversaciones.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes conversaciones'**
  String get aunNoTienesConversaciones;

  /// No description provided for @cuandoAceptesUnaPropuesta.
  ///
  /// In es, this message translates to:
  /// **'Cuando aceptes una propuesta, el chat de ese trato aparece aquí.'**
  String get cuandoAceptesUnaPropuesta;

  /// No description provided for @escribeElPrimerMensaje.
  ///
  /// In es, this message translates to:
  /// **'Escribe el primer mensaje'**
  String get escribeElPrimerMensaje;

  /// No description provided for @tu2.
  ///
  /// In es, this message translates to:
  /// **'Tú: {p0}'**
  String tu2(Object p0);

  /// No description provided for @noEncontramosEsteTrato.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este trato'**
  String get noEncontramosEsteTrato;

  /// No description provided for @vuelveAMensajesPara.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a Mensajes para ver tus conversaciones.'**
  String get vuelveAMensajesPara;

  /// No description provided for @verElPedido.
  ///
  /// In es, this message translates to:
  /// **'Ver el pedido'**
  String get verElPedido;

  /// No description provided for @todaviaNoHayCuentas2.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay cuentas: tus mensajes se guardan en tu teléfono. El chat con la otra persona llegará con el servidor.'**
  String get todaviaNoHayCuentas2;

  /// No description provided for @noPudimosLeerLos.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer los mensajes.'**
  String get noPudimosLeerLos;

  /// No description provided for @sinMensajesTodavia.
  ///
  /// In es, this message translates to:
  /// **'Sin mensajes todavía'**
  String get sinMensajesTodavia;

  /// No description provided for @escribeAbajoOToca.
  ///
  /// In es, this message translates to:
  /// **'Escribe abajo o toca una frase rápida.'**
  String get escribeAbajoOToca;

  /// No description provided for @escribeUnMensaje.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje'**
  String get escribeUnMensaje;

  /// No description provided for @enviarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get enviarMensaje;

  /// No description provided for @guardado.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get guardado;

  /// No description provided for @ayudaDelBarrioCuando.
  ///
  /// In es, this message translates to:
  /// **'Ayuda del barrio cuando más importa.'**
  String get ayudaDelBarrioCuando;

  /// No description provided for @serviciosOficiales.
  ///
  /// In es, this message translates to:
  /// **'Servicios oficiales'**
  String get serviciosOficiales;

  /// No description provided for @enPeligroLlamaAqui.
  ///
  /// In es, this message translates to:
  /// **'En peligro, llama aquí primero.'**
  String get enPeligroLlamaAqui;

  /// No description provided for @verificaEstosNumerosCon.
  ///
  /// In es, this message translates to:
  /// **'Verifica estos números con fuentes oficiales antes de depender de ellos.'**
  String get verificaEstosNumerosCon;

  /// No description provided for @ayudaDelBarrio.
  ///
  /// In es, this message translates to:
  /// **'Ayuda del barrio'**
  String get ayudaDelBarrio;

  /// No description provided for @avisaATusVecinos.
  ///
  /// In es, this message translates to:
  /// **'Avisa a tus vecinos. No reemplaza a los servicios oficiales.'**
  String get avisaATusVecinos;

  /// No description provided for @necesitoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Necesito ayuda'**
  String get necesitoAyuda;

  /// No description provided for @noPudimosLeerTus4.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer tus avisos.'**
  String get noPudimosLeerTus4;

  /// No description provided for @misAvisos.
  ///
  /// In es, this message translates to:
  /// **'Mis avisos'**
  String get misAvisos;

  /// No description provided for @todaviaNoHayVecinos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay vecinos conectados que respondan: nadie te escribirá desde la app.'**
  String get todaviaNoHayVecinos;

  /// No description provided for @unBarrioPreparado.
  ///
  /// In es, this message translates to:
  /// **'Un barrio preparado'**
  String get unBarrioPreparado;

  /// No description provided for @quePodriasOfrecerSi.
  ///
  /// In es, this message translates to:
  /// **'Qué podrías ofrecer si pasa algo.'**
  String get quePodriasOfrecerSi;

  /// No description provided for @brigadistaVecinalVoluntario.
  ///
  /// In es, this message translates to:
  /// **'Brigadista vecinal voluntario'**
  String get brigadistaVecinalVoluntario;

  /// No description provided for @sinVerificarSoloQueda.
  ///
  /// In es, this message translates to:
  /// **'Sin verificar. Solo queda guardado en tu teléfono.'**
  String get sinVerificarSoloQueda;

  /// No description provided for @puntosDeAcopio.
  ///
  /// In es, this message translates to:
  /// **'Puntos de acopio'**
  String get puntosDeAcopio;

  /// No description provided for @lugaresParaReunirAyuda.
  ///
  /// In es, this message translates to:
  /// **'Lugares para reunir ayuda. Los que propongas quedan sin verificar.'**
  String get lugaresParaReunirAyuda;

  /// No description provided for @proponer.
  ///
  /// In es, this message translates to:
  /// **'Proponer'**
  String get proponer;

  /// No description provided for @aunNoHayPuntos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay puntos de acopio. Propón uno: un colegio, una iglesia o un local del barrio.'**
  String get aunNoHayPuntos;

  /// No description provided for @llamarAl.
  ///
  /// In es, this message translates to:
  /// **'¿Llamar al {p0}?'**
  String llamarAl(Object p0);

  /// No description provided for @esteNumeroEstaPor.
  ///
  /// In es, this message translates to:
  /// **'{p0} · {p1}.\nEste número está por verificar con fuentes oficiales.'**
  String esteNumeroEstaPor(Object p0, Object p1);

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @llamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get llamar;

  /// No description provided for @noPudimosAbrirEl.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el teléfono. Marca el {p0} desde tu celular.'**
  String noPudimosAbrirEl(Object p0);

  /// No description provided for @llamarANumero.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {p0}, número {p1}'**
  String llamarANumero(Object p0, Object p1);

  /// No description provided for @porVerificar.
  ///
  /// In es, this message translates to:
  /// **'Por verificar'**
  String get porVerificar;

  /// No description provided for @privado.
  ///
  /// In es, this message translates to:
  /// **'Privado'**
  String get privado;

  /// No description provided for @propuestoPorTiSin.
  ///
  /// In es, this message translates to:
  /// **'Propuesto por ti · sin verificar'**
  String get propuestoPorTiSin;

  /// No description provided for @proponerUnPuntoDe.
  ///
  /// In es, this message translates to:
  /// **'Proponer un punto de acopio'**
  String get proponerUnPuntoDe;

  /// No description provided for @unLugarDelBarrio.
  ///
  /// In es, this message translates to:
  /// **'Un lugar del barrio donde reunir agua, comida o abrigo.'**
  String get unLugarDelBarrio;

  /// No description provided for @guardarPunto.
  ///
  /// In es, this message translates to:
  /// **'Guardar punto'**
  String get guardarPunto;

  /// No description provided for @nombreDelLugar.
  ///
  /// In es, this message translates to:
  /// **'Nombre del lugar'**
  String get nombreDelLugar;

  /// No description provided for @referenciaOpcional.
  ///
  /// In es, this message translates to:
  /// **'Referencia (opcional)'**
  String get referenciaOpcional;

  /// No description provided for @porEjemploFrenteAl.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: frente al parque'**
  String get porEjemploFrenteAl;

  /// No description provided for @tuAvisoQuedoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Tu aviso quedó guardado. Si es grave, llama ya a los servicios oficiales.'**
  String get tuAvisoQuedoGuardado;

  /// No description provided for @eligeQuePasaEl.
  ///
  /// In es, this message translates to:
  /// **'Elige qué pasa. El texto ya está escrito: enviar es un toque.'**
  String get eligeQuePasaEl;

  /// No description provided for @enviarAviso.
  ///
  /// In es, this message translates to:
  /// **'Enviar aviso'**
  String get enviarAviso;

  /// No description provided for @noSePudoGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el aviso'**
  String get noSePudoGuardar;

  /// No description provided for @siEsUrgenteLlama.
  ///
  /// In es, this message translates to:
  /// **'{p0} Si es urgente, llama a los servicios oficiales.'**
  String siEsUrgenteLlama(Object p0);

  /// No description provided for @primeroLosServiciosOficiales.
  ///
  /// In es, this message translates to:
  /// **'Primero, los servicios oficiales'**
  String get primeroLosServiciosOficiales;

  /// No description provided for @siHayPeligroAhora.
  ///
  /// In es, this message translates to:
  /// **'Si hay peligro ahora, llama a emergencias antes de usar la app. Los vecinos no reemplazan a Bomberos, Policía ni SAMU.'**
  String get siHayPeligroAhora;

  /// No description provided for @quePasa.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasa?'**
  String get quePasa;

  /// No description provided for @esteAvisoEsPrivado.
  ///
  /// In es, this message translates to:
  /// **'Este aviso es privado: no se muestra en el muro del barrio.'**
  String get esteAvisoEsPrivado;

  /// No description provided for @quePasoPuedesCambiarlo.
  ///
  /// In es, this message translates to:
  /// **'Qué pasó (puedes cambiarlo)'**
  String get quePasoPuedesCambiarlo;

  /// No description provided for @tuUbicacionExactaNo.
  ///
  /// In es, this message translates to:
  /// **'Tu ubicación exacta no se comparte. Se guarda en tu teléfono y se envía cuando haya internet.'**
  String get tuUbicacionExactaNo;

  /// No description provided for @tuAyudaAlBarrio.
  ///
  /// In es, this message translates to:
  /// **'Tu ayuda al barrio y tus ajustes.'**
  String get tuAyudaAlBarrio;

  /// No description provided for @tuAyudaAlBarrio2.
  ///
  /// In es, this message translates to:
  /// **'Tu ayuda al barrio'**
  String get tuAyudaAlBarrio2;

  /// No description provided for @soloTuVesEste.
  ///
  /// In es, this message translates to:
  /// **'Solo tú ves este resumen.'**
  String get soloTuVesEste;

  /// No description provided for @esEvidenciaDeLo.
  ///
  /// In es, this message translates to:
  /// **'Es evidencia de lo que hiciste, no puntos: no da prioridad ni ventaja.'**
  String get esEvidenciaDeLo;

  /// No description provided for @verYEscucharMejor.
  ///
  /// In es, this message translates to:
  /// **'Ver y escuchar mejor'**
  String get verYEscucharMejor;

  /// No description provided for @tamanoDelTexto.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto'**
  String get tamanoDelTexto;

  /// No description provided for @normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @grande.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get grande;

  /// No description provided for @muyGrande.
  ///
  /// In es, this message translates to:
  /// **'Muy grande'**
  String get muyGrande;

  /// No description provided for @apariencia.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get apariencia;

  /// No description provided for @sistema.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get sistema;

  /// No description provided for @claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get claro;

  /// No description provided for @oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get oscuro;

  /// No description provided for @altoContraste.
  ///
  /// In es, this message translates to:
  /// **'Alto contraste'**
  String get altoContraste;

  /// No description provided for @textosMasOscurosY.
  ///
  /// In es, this message translates to:
  /// **'Textos más oscuros y bordes más marcados.'**
  String get textosMasOscurosY;

  /// No description provided for @vibracionAlConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Vibración al confirmar'**
  String get vibracionAlConfirmar;

  /// No description provided for @unaVibracionCortaCuando.
  ///
  /// In es, this message translates to:
  /// **'Una vibración corta cuando envías algo.'**
  String get unaVibracionCortaCuando;

  /// No description provided for @ayudaYDatos.
  ///
  /// In es, this message translates to:
  /// **'Ayuda y datos'**
  String get ayudaYDatos;

  /// No description provided for @verElTutorial.
  ///
  /// In es, this message translates to:
  /// **'Ver el tutorial'**
  String get verElTutorial;

  /// No description provided for @tresPantallasParaEmpezar.
  ///
  /// In es, this message translates to:
  /// **'Tres pantallas para empezar.'**
  String get tresPantallasParaEmpezar;

  /// No description provided for @sobreEstePrototipo.
  ///
  /// In es, this message translates to:
  /// **'Sobre este prototipo'**
  String get sobreEstePrototipo;

  /// No description provided for @queEsRealY.
  ///
  /// In es, this message translates to:
  /// **'Qué es real y qué es de ejemplo.'**
  String get queEsRealY;

  /// No description provided for @borrarMisDatosDe.
  ///
  /// In es, this message translates to:
  /// **'Borrar mis datos de este teléfono'**
  String get borrarMisDatosDe;

  /// No description provided for @pedidosTratosMensajesY.
  ///
  /// In es, this message translates to:
  /// **'Pedidos, tratos, mensajes y ajustes.'**
  String get pedidosTratosMensajesY;

  /// No description provided for @tratosResueltos.
  ///
  /// In es, this message translates to:
  /// **'Tratos resueltos'**
  String get tratosResueltos;

  /// No description provided for @personasDistintas.
  ///
  /// In es, this message translates to:
  /// **'Personas distintas'**
  String get personasDistintas;

  /// No description provided for @calificacionQueDiste.
  ///
  /// In es, this message translates to:
  /// **'Calificación que diste'**
  String get calificacionQueDiste;

  /// No description provided for @min.
  ///
  /// In es, this message translates to:
  /// **'{p0} min'**
  String min(Object p0);

  /// No description provided for @tiempoEnTratos.
  ///
  /// In es, this message translates to:
  /// **'Tiempo en tratos'**
  String get tiempoEnTratos;

  /// No description provided for @esRealTusPedidos.
  ///
  /// In es, this message translates to:
  /// **'Es real: tus pedidos, tratos, mensajes y ajustes se guardan en tu teléfono, funciona sin internet y la cola envía lo pendiente al volver la señal.\n\nEs de ejemplo: los vecinos, negocios, propuestas y precios que ves, y el \"enviado\", porque todavía no hay servidor ni cuentas.\n\nPor verificar: los números de emergencia deben confirmarse con fuentes oficiales.'**
  String get esRealTusPedidos;

  /// No description provided for @entendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// No description provided for @borrarTusDatos.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar tus datos?'**
  String get borrarTusDatos;

  /// No description provided for @seBorraranTusPedidos.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán tus pedidos, tratos, calificaciones, mensajes, avisos y ajustes de este teléfono.'**
  String get seBorraranTusPedidos;

  /// No description provided for @continuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// No description provided for @ultimaConfirmacion.
  ///
  /// In es, this message translates to:
  /// **'Última confirmación'**
  String get ultimaConfirmacion;

  /// No description provided for @estoNoSePuede.
  ///
  /// In es, this message translates to:
  /// **'Esto no se puede deshacer. ¿Seguro que quieres borrar todo?'**
  String get estoNoSePuede;

  /// No description provided for @noConservar.
  ///
  /// In es, this message translates to:
  /// **'No, conservar'**
  String get noConservar;

  /// No description provided for @siBorrarTodo.
  ///
  /// In es, this message translates to:
  /// **'Sí, borrar todo'**
  String get siBorrarTodo;

  /// No description provided for @listoBorramosTusDatos.
  ///
  /// In es, this message translates to:
  /// **'Listo: borramos tus datos de este teléfono.'**
  String get listoBorramosTusDatos;

  /// No description provided for @cuentaQueNecesitas.
  ///
  /// In es, this message translates to:
  /// **'Cuenta qué necesitas'**
  String get cuentaQueNecesitas;

  /// No description provided for @tocaPedirAlgoY.
  ///
  /// In es, this message translates to:
  /// **'Toca \"Pedir algo\" y elige una frase, o escribe con tus palabras. Con un atajo, son solo dos toques.'**
  String get tocaPedirAlgoY;

  /// No description provided for @eligeAQuienY.
  ///
  /// In es, this message translates to:
  /// **'Elige a quién y encuéntrense'**
  String get eligeAQuienY;

  /// No description provided for @tuBarrioTePropone.
  ///
  /// In es, this message translates to:
  /// **'Tu barrio te propone cómo resolverlo y cada persona pone su precio. Al encontrarse, se dicen un código de 4 dígitos.'**
  String get tuBarrioTePropone;

  /// No description provided for @calificaYConstruyeConfianza.
  ///
  /// In es, this message translates to:
  /// **'Califica y construye confianza'**
  String get calificaYConstruyeConfianza;

  /// No description provided for @alTerminarCalificasAsi.
  ///
  /// In es, this message translates to:
  /// **'Al terminar, calificas. Así el barrio sabe en quién confiar. También funciona sin internet: tus pedidos se envían después.'**
  String get alTerminarCalificasAsi;

  /// No description provided for @saltar.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get saltar;

  /// No description provided for @empezar.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get empezar;

  /// No description provided for @siguiente.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get siguiente;

  /// No description provided for @todoAlDiaResueltos.
  ///
  /// In es, this message translates to:
  /// **'Todo al día · {n, plural, =1{1 resuelto} other{{n} resueltos}}'**
  String todoAlDiaResueltos(int n);

  /// No description provided for @enCursoSolo.
  ///
  /// In es, this message translates to:
  /// **'{active} en curso'**
  String enCursoSolo(int active);

  /// No description provided for @verTodosServicios.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los servicios ({n})'**
  String verTodosServicios(int n);

  /// No description provided for @verTodosProductos.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los productos ({n})'**
  String verTodosProductos(int n);

  /// No description provided for @aDistancia.
  ///
  /// In es, this message translates to:
  /// **'a {d}'**
  String aDistancia(String d);

  /// No description provided for @aDistanciaAprox.
  ///
  /// In es, this message translates to:
  /// **'a {d} (aprox.)'**
  String aDistanciaAprox(String d);

  /// No description provided for @vecinosRecomiendanEjemplo.
  ///
  /// In es, this message translates to:
  /// **'{n} vecinos lo recomiendan (ejemplo)'**
  String vecinosRecomiendanEjemplo(int n);

  /// No description provided for @vecinosRecomiendanEjemploTuyas.
  ///
  /// In es, this message translates to:
  /// **'{n} vecinos lo recomiendan (ejemplo) + {m, plural, =1{1 tuya} other{{m} tuyas}}'**
  String vecinosRecomiendanEjemploTuyas(int n, int m);

  /// No description provided for @codigoDigitos.
  ///
  /// In es, this message translates to:
  /// **'Código {digits}'**
  String codigoDigitos(String digits);

  /// No description provided for @diselo.
  ///
  /// In es, this message translates to:
  /// **'Díselo a {name} cuando llegue. Así confirmamos que se encontraron de verdad y el trato cuenta para la reputación.'**
  String diselo(String name);

  /// No description provided for @servicioRealizado.
  ///
  /// In es, this message translates to:
  /// **'Servicio realizado'**
  String get servicioRealizado;

  /// No description provided for @servicioRealizadoEnTiempo.
  ///
  /// In es, this message translates to:
  /// **'Servicio realizado en {time}'**
  String servicioRealizadoEnTiempo(String time);

  /// No description provided for @recomendarA.
  ///
  /// In es, this message translates to:
  /// **'Recomendar a {name}'**
  String recomendarA(String name);

  /// No description provided for @reputacionDe.
  ///
  /// In es, this message translates to:
  /// **'Reputación de {name}'**
  String reputacionDe(String name);

  /// No description provided for @vecinosRecomiendanResumen.
  ///
  /// In es, this message translates to:
  /// **'{n} (ejemplo) + {m, plural, =1{1 tuya} other{{m} tuyas}}'**
  String vecinosRecomiendanResumen(int n, int m);

  /// No description provided for @duracionSegundos.
  ///
  /// In es, this message translates to:
  /// **'{s} s'**
  String duracionSegundos(int s);

  /// No description provided for @duracionMinutos.
  ///
  /// In es, this message translates to:
  /// **'{m} min'**
  String duracionMinutos(int m);

  /// No description provided for @duracionMinutosSegundos.
  ///
  /// In es, this message translates to:
  /// **'{m} min {s} s'**
  String duracionMinutosSegundos(int m, int s);

  /// No description provided for @kindService.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get kindService;

  /// No description provided for @kindProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get kindProduct;

  /// No description provided for @kindLoan.
  ///
  /// In es, this message translates to:
  /// **'Préstamo'**
  String get kindLoan;

  /// No description provided for @kindHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get kindHelp;

  /// No description provided for @hintService.
  ///
  /// In es, this message translates to:
  /// **'Un oficio o profesional'**
  String get hintService;

  /// No description provided for @hintProduct.
  ///
  /// In es, this message translates to:
  /// **'Algo cerca de ti'**
  String get hintProduct;

  /// No description provided for @hintLoan.
  ///
  /// In es, this message translates to:
  /// **'Prestar, alquilar o trueque'**
  String get hintLoan;

  /// No description provided for @hintHelp.
  ///
  /// In es, this message translates to:
  /// **'Un favor o tiempo de alguien'**
  String get hintHelp;

  /// No description provided for @urgencyNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo'**
  String get urgencyNow;

  /// No description provided for @urgencyToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get urgencyToday;

  /// No description provided for @urgencyTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get urgencyTomorrow;

  /// No description provided for @urgencyThisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get urgencyThisWeek;

  /// No description provided for @suggService1.
  ///
  /// In es, this message translates to:
  /// **'Necesito un gasfitero para arreglar una fuga'**
  String get suggService1;

  /// No description provided for @suggService2.
  ///
  /// In es, this message translates to:
  /// **'Necesito un electricista, se fue la luz en la cocina'**
  String get suggService2;

  /// No description provided for @suggProduct1.
  ///
  /// In es, this message translates to:
  /// **'Necesito 2 bidones de agua'**
  String get suggProduct1;

  /// No description provided for @suggProduct2.
  ///
  /// In es, this message translates to:
  /// **'Necesito pan y leche, no puedo salir'**
  String get suggProduct2;

  /// No description provided for @suggLoan1.
  ///
  /// In es, this message translates to:
  /// **'Necesito un taladro por una hora'**
  String get suggLoan1;

  /// No description provided for @suggLoan2.
  ///
  /// In es, this message translates to:
  /// **'Necesito una escalera por hoy'**
  String get suggLoan2;

  /// No description provided for @suggHelp1.
  ///
  /// In es, this message translates to:
  /// **'Necesito ayuda para mover un mueble'**
  String get suggHelp1;

  /// No description provided for @suggHelp2.
  ///
  /// In es, this message translates to:
  /// **'Necesito que alguien cuide a mi hijo 2 horas'**
  String get suggHelp2;

  /// No description provided for @quickPlumber.
  ///
  /// In es, this message translates to:
  /// **'Gasfitero'**
  String get quickPlumber;

  /// No description provided for @quickElectrician.
  ///
  /// In es, this message translates to:
  /// **'Electricista'**
  String get quickElectrician;

  /// No description provided for @quickWater.
  ///
  /// In es, this message translates to:
  /// **'2 bidones de agua'**
  String get quickWater;

  /// No description provided for @syncPending.
  ///
  /// In es, this message translates to:
  /// **'Guardada en tu teléfono · se enviará cuando haya internet'**
  String get syncPending;

  /// No description provided for @syncSentDemo.
  ///
  /// In es, this message translates to:
  /// **'Enviada · barrio de ejemplo (demo)'**
  String get syncSentDemo;

  /// No description provided for @syncSent.
  ///
  /// In es, this message translates to:
  /// **'Enviada'**
  String get syncSent;

  /// No description provided for @syncError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar · toca para reintentar'**
  String get syncError;

  /// No description provided for @badgePending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get badgePending;

  /// No description provided for @badgeSent.
  ///
  /// In es, this message translates to:
  /// **'Enviada'**
  String get badgeSent;

  /// No description provided for @badgeRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get badgeRetry;

  /// No description provided for @phaseSending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de envío'**
  String get phaseSending;

  /// No description provided for @phaseError.
  ///
  /// In es, this message translates to:
  /// **'No se envió · reintentar'**
  String get phaseError;

  /// No description provided for @phaseWaiting.
  ///
  /// In es, this message translates to:
  /// **'Con propuestas'**
  String get phaseWaiting;

  /// No description provided for @phaseActive.
  ///
  /// In es, this message translates to:
  /// **'En curso'**
  String get phaseActive;

  /// No description provided for @phaseRate.
  ///
  /// In es, this message translates to:
  /// **'Falta calificar'**
  String get phaseRate;

  /// No description provided for @phaseDone.
  ///
  /// In es, this message translates to:
  /// **'Resuelta'**
  String get phaseDone;

  /// No description provided for @modFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get modFree;

  /// No description provided for @modBarter.
  ///
  /// In es, this message translates to:
  /// **'Trueque'**
  String get modBarter;

  /// No description provided for @modRent.
  ///
  /// In es, this message translates to:
  /// **'Alquiler'**
  String get modRent;

  /// No description provided for @modFreeHint.
  ///
  /// In es, this message translates to:
  /// **'Sin costo: un favor entre vecinos.'**
  String get modFreeHint;

  /// No description provided for @modBarterHint.
  ///
  /// In es, this message translates to:
  /// **'Cambias una cosa o un favor por otro.'**
  String get modBarterHint;

  /// No description provided for @modRentHint.
  ///
  /// In es, this message translates to:
  /// **'Lo prestas a cambio de un pago acordado entre ustedes.'**
  String get modRentHint;

  /// No description provided for @sitEarthquake.
  ///
  /// In es, this message translates to:
  /// **'Sismo'**
  String get sitEarthquake;

  /// No description provided for @sitFire.
  ///
  /// In es, this message translates to:
  /// **'Incendio'**
  String get sitFire;

  /// No description provided for @sitMedical.
  ///
  /// In es, this message translates to:
  /// **'Médico'**
  String get sitMedical;

  /// No description provided for @sitElderly.
  ///
  /// In es, this message translates to:
  /// **'Persona mayor en riesgo'**
  String get sitElderly;

  /// No description provided for @sitViolence.
  ///
  /// In es, this message translates to:
  /// **'Violencia'**
  String get sitViolence;

  /// No description provided for @tplEarthquake.
  ///
  /// In es, this message translates to:
  /// **'Hubo un sismo y necesito ayuda.'**
  String get tplEarthquake;

  /// No description provided for @tplFire.
  ///
  /// In es, this message translates to:
  /// **'Hay un incendio cerca y necesito ayuda.'**
  String get tplFire;

  /// No description provided for @tplMedical.
  ///
  /// In es, this message translates to:
  /// **'Necesito ayuda médica urgente.'**
  String get tplMedical;

  /// No description provided for @tplElderly.
  ///
  /// In es, this message translates to:
  /// **'Una persona mayor necesita ayuda ahora.'**
  String get tplElderly;

  /// No description provided for @tplViolence.
  ///
  /// In es, this message translates to:
  /// **'Estoy en una situación de violencia y necesito ayuda.'**
  String get tplViolence;

  /// No description provided for @offPolice.
  ///
  /// In es, this message translates to:
  /// **'Policía Nacional'**
  String get offPolice;

  /// No description provided for @offPoliceUse.
  ///
  /// In es, this message translates to:
  /// **'Delitos y peligro inmediato'**
  String get offPoliceUse;

  /// No description provided for @offFire.
  ///
  /// In es, this message translates to:
  /// **'Bomberos'**
  String get offFire;

  /// No description provided for @offFireUse.
  ///
  /// In es, this message translates to:
  /// **'Incendios y rescates'**
  String get offFireUse;

  /// No description provided for @offSamu.
  ///
  /// In es, this message translates to:
  /// **'SAMU'**
  String get offSamu;

  /// No description provided for @offSamuUse.
  ///
  /// In es, this message translates to:
  /// **'Emergencias médicas'**
  String get offSamuUse;

  /// No description provided for @offCivil.
  ///
  /// In es, this message translates to:
  /// **'Defensa Civil'**
  String get offCivil;

  /// No description provided for @offCivilUse.
  ///
  /// In es, this message translates to:
  /// **'Sismos y desastres'**
  String get offCivilUse;

  /// No description provided for @offLine100.
  ///
  /// In es, this message translates to:
  /// **'Línea 100'**
  String get offLine100;

  /// No description provided for @offLine100Use.
  ///
  /// In es, this message translates to:
  /// **'Violencia familiar y sexual'**
  String get offLine100Use;

  /// No description provided for @capFirstAid.
  ///
  /// In es, this message translates to:
  /// **'Primeros auxilios'**
  String get capFirstAid;

  /// No description provided for @capMedkit.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get capMedkit;

  /// No description provided for @capVehicle.
  ///
  /// In es, this message translates to:
  /// **'Vehículo'**
  String get capVehicle;

  /// No description provided for @capTools.
  ///
  /// In es, this message translates to:
  /// **'Herramientas'**
  String get capTools;

  /// No description provided for @capSupplies.
  ///
  /// In es, this message translates to:
  /// **'Agua o víveres'**
  String get capSupplies;

  /// No description provided for @capCare.
  ///
  /// In es, this message translates to:
  /// **'Cuidar niños o mayores'**
  String get capCare;

  /// No description provided for @qpOnMyWay.
  ///
  /// In es, this message translates to:
  /// **'Ya voy en camino'**
  String get qpOnMyWay;

  /// No description provided for @qpAtDoor.
  ///
  /// In es, this message translates to:
  /// **'Estoy en la puerta'**
  String get qpAtDoor;

  /// No description provided for @qpWhatTime.
  ///
  /// In es, this message translates to:
  /// **'¿A qué hora puede venir?'**
  String get qpWhatTime;

  /// No description provided for @qpThanks.
  ///
  /// In es, this message translates to:
  /// **'Gracias, todo bien'**
  String get qpThanks;

  /// No description provided for @trAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get trAll;

  /// No description provided for @trPlumbing.
  ///
  /// In es, this message translates to:
  /// **'Gasfitería'**
  String get trPlumbing;

  /// No description provided for @trElectrical.
  ///
  /// In es, this message translates to:
  /// **'Electricidad'**
  String get trElectrical;

  /// No description provided for @trCarpentry.
  ///
  /// In es, this message translates to:
  /// **'Carpintería'**
  String get trCarpentry;

  /// No description provided for @trLocksmith.
  ///
  /// In es, this message translates to:
  /// **'Cerrajería'**
  String get trLocksmith;

  /// No description provided for @trSewing.
  ///
  /// In es, this message translates to:
  /// **'Costura'**
  String get trSewing;

  /// No description provided for @trLessons.
  ///
  /// In es, this message translates to:
  /// **'Clases'**
  String get trLessons;

  /// No description provided for @trPets.
  ///
  /// In es, this message translates to:
  /// **'Mascotas'**
  String get trPets;

  /// No description provided for @trGrocery.
  ///
  /// In es, this message translates to:
  /// **'Bodega'**
  String get trGrocery;

  /// No description provided for @trMinimarket.
  ///
  /// In es, this message translates to:
  /// **'Minimarket'**
  String get trMinimarket;

  /// No description provided for @trNeighbor.
  ///
  /// In es, this message translates to:
  /// **'De un vecino'**
  String get trNeighbor;

  /// No description provided for @roPlumber.
  ///
  /// In es, this message translates to:
  /// **'Gasfitero'**
  String get roPlumber;

  /// No description provided for @roElectrician.
  ///
  /// In es, this message translates to:
  /// **'Electricista'**
  String get roElectrician;

  /// No description provided for @roCarpenter.
  ///
  /// In es, this message translates to:
  /// **'Carpintero'**
  String get roCarpenter;

  /// No description provided for @roLocksmith.
  ///
  /// In es, this message translates to:
  /// **'Cerrajero'**
  String get roLocksmith;

  /// No description provided for @roSeamstress.
  ///
  /// In es, this message translates to:
  /// **'Costurera'**
  String get roSeamstress;

  /// No description provided for @roTutor.
  ///
  /// In es, this message translates to:
  /// **'Profesora de clases particulares'**
  String get roTutor;

  /// No description provided for @roPetWalker.
  ///
  /// In es, this message translates to:
  /// **'Paseadora de mascotas'**
  String get roPetWalker;

  /// No description provided for @roNeighbor.
  ///
  /// In es, this message translates to:
  /// **'Vecino'**
  String get roNeighbor;

  /// No description provided for @failWriteMessage.
  ///
  /// In es, this message translates to:
  /// **'Escribe un mensaje.'**
  String get failWriteMessage;

  /// No description provided for @failSaveMessage.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu mensaje.'**
  String get failSaveMessage;

  /// No description provided for @failUpdateMessage.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el mensaje.'**
  String get failUpdateMessage;

  /// No description provided for @failPlaceName.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del lugar.'**
  String get failPlaceName;

  /// No description provided for @failSaveAlert.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu aviso.'**
  String get failSaveAlert;

  /// No description provided for @failUpdateAlert.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el aviso.'**
  String get failUpdateAlert;

  /// No description provided for @failSavePoint.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el punto de acopio.'**
  String get failSavePoint;

  /// No description provided for @failLocation.
  ///
  /// In es, this message translates to:
  /// **'No pudimos obtener tu ubicación. Inténtalo otra vez.'**
  String get failLocation;

  /// No description provided for @failNeedShort.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué necesitas (al menos 3 letras).'**
  String get failNeedShort;

  /// No description provided for @failSavePhone.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar en tu teléfono.'**
  String get failSavePhone;

  /// No description provided for @failUpdateStatus.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar el estado.'**
  String get failUpdateStatus;

  /// No description provided for @failAlreadyAccepted.
  ///
  /// In es, this message translates to:
  /// **'Este pedido ya tiene una propuesta aceptada.'**
  String get failAlreadyAccepted;

  /// No description provided for @failDealNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este trato.'**
  String get failDealNotFound;

  /// No description provided for @failCodeValidated.
  ///
  /// In es, this message translates to:
  /// **'El código de este trato ya fue validado.'**
  String get failCodeValidated;

  /// No description provided for @failValidateCodeFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero hay que validar el código de encuentro.'**
  String get failValidateCodeFirst;

  /// No description provided for @failStars.
  ///
  /// In es, this message translates to:
  /// **'Elige de 1 a 5 estrellas.'**
  String get failStars;

  /// No description provided for @failMarkDoneFirst.
  ///
  /// In es, this message translates to:
  /// **'Primero marca el servicio como hecho.'**
  String get failMarkDoneFirst;

  /// No description provided for @failPersonNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos a esta persona.'**
  String get failPersonNotFound;

  /// No description provided for @failSaveDeal.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el trato en tu teléfono.'**
  String get failSaveDeal;

  /// No description provided for @failSaveRating.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu calificación.'**
  String get failSaveRating;

  /// No description provided for @failOfferShort.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué ofreces (al menos 3 letras).'**
  String get failOfferShort;

  /// No description provided for @failSavePending.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el envío pendiente.'**
  String get failSavePending;

  /// No description provided for @failUpdateQueue.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la cola.'**
  String get failUpdateQueue;

  /// No description provided for @failLocationOff.
  ///
  /// In es, this message translates to:
  /// **'Activa la ubicación del teléfono para ver lo que hay cerca.'**
  String get failLocationOff;

  /// No description provided for @failLocationPermission.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de ubicación. Puedes elegir tu zona a mano.'**
  String get failLocationPermission;

  /// No description provided for @idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get idioma;

  /// No description provided for @wall1.
  ///
  /// In es, this message translates to:
  /// **'Necesito un taladro por una hora.'**
  String get wall1;

  /// No description provided for @wall2.
  ///
  /// In es, this message translates to:
  /// **'Presto mi escalera de 3 metros. Pasa a recogerla.'**
  String get wall2;

  /// No description provided for @wall3.
  ///
  /// In es, this message translates to:
  /// **'Cambio clases de tejido por ayuda con el celular.'**
  String get wall3;

  /// No description provided for @wall4.
  ///
  /// In es, this message translates to:
  /// **'Busco quien me ayude a mover un mueble el sábado.'**
  String get wall4;

  /// No description provided for @wall5.
  ///
  /// In es, this message translates to:
  /// **'Alquilo una máquina de coser por día.'**
  String get wall5;

  /// No description provided for @wall6.
  ///
  /// In es, this message translates to:
  /// **'Necesito una carretilla prestada para el fin de semana.'**
  String get wall6;

  /// No description provided for @locBannerLastTitle.
  ///
  /// In es, this message translates to:
  /// **'Usando tu última zona conocida'**
  String get locBannerLastTitle;

  /// No description provided for @locBannerLastBody.
  ///
  /// In es, this message translates to:
  /// **'Las distancias son aproximadas hasta que vuelva la señal del GPS.'**
  String get locBannerLastBody;

  /// No description provided for @locSourceLive.
  ///
  /// In es, this message translates to:
  /// **'ubicación activa'**
  String get locSourceLive;

  /// No description provided for @locSourceLast.
  ///
  /// In es, this message translates to:
  /// **'última posición conocida'**
  String get locSourceLast;

  /// No description provided for @locSourceSaved.
  ///
  /// In es, this message translates to:
  /// **'zona guardada'**
  String get locSourceSaved;

  /// No description provided for @locZoneLine.
  ///
  /// In es, this message translates to:
  /// **'{zone} · {source}'**
  String locZoneLine(String zone, String source);

  /// No description provided for @locRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar ubicación'**
  String get locRefresh;

  /// No description provided for @locEnable.
  ///
  /// In es, this message translates to:
  /// **'Activar ubicación'**
  String get locEnable;

  /// No description provided for @locOpenSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get locOpenSettings;

  /// No description provided for @failLocationBlocked.
  ///
  /// In es, this message translates to:
  /// **'El permiso de ubicación está bloqueado. Actívalo en los ajustes del teléfono.'**
  String get failLocationBlocked;

  /// No description provided for @locSettingTitle.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación'**
  String get locSettingTitle;

  /// No description provided for @locSettingHint.
  ///
  /// In es, this message translates to:
  /// **'Sirve para ver lo que hay cerca. Solo se recuerda tu zona de ~1 km, nunca tu ubicación exacta.'**
  String get locSettingHint;

  /// No description provided for @locForget.
  ///
  /// In es, this message translates to:
  /// **'Olvidar mi zona guardada'**
  String get locForget;

  /// No description provided for @locForgotten.
  ///
  /// In es, this message translates to:
  /// **'Listo: olvidamos tu zona guardada.'**
  String get locForgotten;

  /// No description provided for @connOffline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · puedes seguir usando la app'**
  String get connOffline;

  /// No description provided for @connOfflinePending.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión · {n, plural, =1{1 envío pendiente} other{{n} envíos pendientes}}'**
  String connOfflinePending(int n);

  /// No description provided for @connSyncing.
  ///
  /// In es, this message translates to:
  /// **'Enviando {n, plural, =1{1 pendiente} other{{n} pendientes}}…'**
  String connSyncing(int n);

  /// No description provided for @connSynced.
  ///
  /// In es, this message translates to:
  /// **'Todo enviado'**
  String get connSynced;

  /// No description provided for @profTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profTitle;

  /// No description provided for @profNone.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes perfil'**
  String get profNone;

  /// No description provided for @profNoneHint.
  ///
  /// In es, this message translates to:
  /// **'Crea uno para que tu barrio sepa cómo llamarte.'**
  String get profNoneHint;

  /// No description provided for @profCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear mi perfil'**
  String get profCreate;

  /// No description provided for @profEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profEdit;

  /// No description provided for @profLocalNote.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil se guarda solo en este teléfono. Todavía no hay cuentas: no sirve para entrar desde otro celular.'**
  String get profLocalNote;

  /// No description provided for @profUsername.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get profUsername;

  /// No description provided for @profUsernameHelp.
  ///
  /// In es, this message translates to:
  /// **'De 3 a 20 letras, números, punto o guion bajo'**
  String get profUsernameHelp;

  /// No description provided for @profEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo (opcional)'**
  String get profEmail;

  /// No description provided for @profEmailHelp.
  ///
  /// In es, this message translates to:
  /// **'Por ahora solo se guarda en tu teléfono; no se verifica.'**
  String get profEmailHelp;

  /// No description provided for @profConsent.
  ///
  /// In es, this message translates to:
  /// **'Entiendo que mi usuario y mi zona de ~1 km pueden verlos mis vecinos, y que mi dirección exacta nunca sale de mi teléfono.'**
  String get profConsent;

  /// No description provided for @profSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get profSave;

  /// No description provided for @profSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil guardado'**
  String get profSaved;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido al barrio!'**
  String get welcomeTitle;

  /// No description provided for @welcomeStep1.
  ///
  /// In es, this message translates to:
  /// **'Paso 1 de 2 · Tu perfil'**
  String get welcomeStep1;

  /// No description provided for @welcomeStep2.
  ///
  /// In es, this message translates to:
  /// **'Paso 2 de 2 · Dónde estás'**
  String get welcomeStep2;

  /// No description provided for @welcomeSkip.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get welcomeSkip;

  /// No description provided for @welcomeFinish.
  ///
  /// In es, this message translates to:
  /// **'Terminar'**
  String get welcomeFinish;

  /// No description provided for @welcomeWhere.
  ///
  /// In es, this message translates to:
  /// **'Marca dónde estás para ver lo que hay cerca. Puedes cambiarlo cuando quieras.'**
  String get welcomeWhere;

  /// No description provided for @welcomeMark.
  ///
  /// In es, this message translates to:
  /// **'Marcar dónde estoy'**
  String get welcomeMark;

  /// No description provided for @welcomeDone.
  ///
  /// In es, this message translates to:
  /// **'Listo, ya marcaste dónde estás.'**
  String get welcomeDone;

  /// No description provided for @addrTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis direcciones'**
  String get addrTitle;

  /// No description provided for @addrSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las distancias se miden desde la dirección activa.'**
  String get addrSubtitle;

  /// No description provided for @addrAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar dirección'**
  String get addrAdd;

  /// No description provided for @addrActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get addrActive;

  /// No description provided for @addrUse.
  ///
  /// In es, this message translates to:
  /// **'Usar esta'**
  String get addrUse;

  /// No description provided for @addrDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get addrDelete;

  /// No description provided for @addrEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no marcaste dónde estás'**
  String get addrEmpty;

  /// No description provided for @addrEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Usa tu ubicación y ponle un nombre, como Casa o Trabajo.'**
  String get addrEmptyHint;

  /// No description provided for @addrNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre (Casa, Trabajo…)'**
  String get addrNameLabel;

  /// No description provided for @addrHome.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get addrHome;

  /// No description provided for @addrWork.
  ///
  /// In es, this message translates to:
  /// **'Trabajo'**
  String get addrWork;

  /// No description provided for @addrOther.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get addrOther;

  /// No description provided for @addrRef.
  ///
  /// In es, this message translates to:
  /// **'Referencia (opcional)'**
  String get addrRef;

  /// No description provided for @addrRefHelp.
  ///
  /// In es, this message translates to:
  /// **'Por ejemplo: frente al parque, 2.º piso'**
  String get addrRefHelp;

  /// No description provided for @addrGetLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar mi ubicación actual'**
  String get addrGetLocation;

  /// No description provided for @addrRelocate.
  ///
  /// In es, this message translates to:
  /// **'Volver a marcar'**
  String get addrRelocate;

  /// No description provided for @addrGot.
  ///
  /// In es, this message translates to:
  /// **'Ubicación marcada · {zone}'**
  String addrGot(String zone);

  /// No description provided for @addrPrivacy.
  ///
  /// In es, this message translates to:
  /// **'La dirección exacta se queda en tu teléfono. Los vecinos solo ven tu zona de ~1 km.'**
  String get addrPrivacy;

  /// No description provided for @addrSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar dirección'**
  String get addrSave;

  /// No description provided for @addrSaved.
  ///
  /// In es, this message translates to:
  /// **'Dirección guardada'**
  String get addrSaved;

  /// No description provided for @addrDeleted.
  ///
  /// In es, this message translates to:
  /// **'Dirección eliminada'**
  String get addrDeleted;

  /// No description provided for @addrDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String addrDeleteTitle(String name);

  /// No description provided for @addrDeleteBody.
  ///
  /// In es, this message translates to:
  /// **'Se borra de tu teléfono. Podrás volver a marcarla cuando quieras.'**
  String get addrDeleteBody;

  /// No description provided for @addrHeroLine.
  ///
  /// In es, this message translates to:
  /// **'{name} · {zone}'**
  String addrHeroLine(String name, String zone);

  /// No description provided for @failUsername.
  ///
  /// In es, this message translates to:
  /// **'El usuario debe tener de 3 a 20 letras, números, punto o guion bajo.'**
  String get failUsername;

  /// No description provided for @failEmail.
  ///
  /// In es, this message translates to:
  /// **'Escribe un correo válido o déjalo vacío.'**
  String get failEmail;

  /// No description provided for @failAddressName.
  ///
  /// In es, this message translates to:
  /// **'Ponle un nombre a la dirección.'**
  String get failAddressName;

  /// No description provided for @failAddressNoLocation.
  ///
  /// In es, this message translates to:
  /// **'Primero marca tu ubicación.'**
  String get failAddressNoLocation;

  /// No description provided for @failSaveProfile.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu perfil.'**
  String get failSaveProfile;

  /// No description provided for @failSaveAddress.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la dirección.'**
  String get failSaveAddress;

  /// No description provided for @failUpdateAddress.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la dirección.'**
  String get failUpdateAddress;

  /// No description provided for @planTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi plan de emergencia'**
  String get planTitle;

  /// No description provided for @planSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Prepárate antes de que pase algo. Todo funciona sin internet.'**
  String get planSubtitle;

  /// No description provided for @contactsTitle.
  ///
  /// In es, this message translates to:
  /// **'Contactos de confianza'**
  String get contactsTitle;

  /// No description provided for @contactsHint.
  ///
  /// In es, this message translates to:
  /// **'Les avisamos por SMS cuando pidas ayuda. Funciona sin internet.'**
  String get contactsHint;

  /// No description provided for @contactsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes contactos'**
  String get contactsEmpty;

  /// No description provided for @contactAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar contacto'**
  String get contactAdd;

  /// No description provided for @contactName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get contactPhone;

  /// No description provided for @contactPhoneHelp.
  ///
  /// In es, this message translates to:
  /// **'Solo números; con código de país si es de otro país'**
  String get contactPhoneHelp;

  /// No description provided for @contactSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar contacto'**
  String get contactSave;

  /// No description provided for @contactDeleted.
  ///
  /// In es, this message translates to:
  /// **'Contacto eliminado'**
  String get contactDeleted;

  /// No description provided for @contactDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a {name}?'**
  String contactDeleteTitle(String name);

  /// No description provided for @meetingTitle.
  ///
  /// In es, this message translates to:
  /// **'Punto de encuentro'**
  String get meetingTitle;

  /// No description provided for @meetingHint.
  ///
  /// In es, this message translates to:
  /// **'Un lugar seguro donde tu familia se junta si no puede volver a casa.'**
  String get meetingHint;

  /// No description provided for @meetingEmpty.
  ///
  /// In es, this message translates to:
  /// **'Toca para elegir el lugar'**
  String get meetingEmpty;

  /// No description provided for @meetingLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar (por ejemplo: el parque de la esquina)'**
  String get meetingLabel;

  /// No description provided for @meetingSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar lugar'**
  String get meetingSave;

  /// No description provided for @backpackTitle.
  ///
  /// In es, this message translates to:
  /// **'Mochila de emergencia'**
  String get backpackTitle;

  /// No description provided for @backpackHint.
  ///
  /// In es, this message translates to:
  /// **'Marca lo que ya tienes guardado.'**
  String get backpackHint;

  /// No description provided for @backpackProgress.
  ///
  /// In es, this message translates to:
  /// **'{done} de {total} listos'**
  String backpackProgress(int done, int total);

  /// No description provided for @bpWater.
  ///
  /// In es, this message translates to:
  /// **'Agua para 3 días'**
  String get bpWater;

  /// No description provided for @bpFood.
  ///
  /// In es, this message translates to:
  /// **'Comida no perecible'**
  String get bpFood;

  /// No description provided for @bpFlashlight.
  ///
  /// In es, this message translates to:
  /// **'Linterna y pilas'**
  String get bpFlashlight;

  /// No description provided for @bpRadio.
  ///
  /// In es, this message translates to:
  /// **'Radio a pilas'**
  String get bpRadio;

  /// No description provided for @bpFirstAid.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get bpFirstAid;

  /// No description provided for @bpMeds.
  ///
  /// In es, this message translates to:
  /// **'Medicinas de la familia'**
  String get bpMeds;

  /// No description provided for @bpDocs.
  ///
  /// In es, this message translates to:
  /// **'Copias de documentos'**
  String get bpDocs;

  /// No description provided for @bpCash.
  ///
  /// In es, this message translates to:
  /// **'Dinero en efectivo'**
  String get bpCash;

  /// No description provided for @bpCharger.
  ///
  /// In es, this message translates to:
  /// **'Cargador portátil'**
  String get bpCharger;

  /// No description provided for @bpWhistle.
  ///
  /// In es, this message translates to:
  /// **'Silbato'**
  String get bpWhistle;

  /// No description provided for @bpClothes.
  ///
  /// In es, this message translates to:
  /// **'Ropa y abrigo'**
  String get bpClothes;

  /// No description provided for @sosNotifyTitle.
  ///
  /// In es, this message translates to:
  /// **'Avisar también a mis contactos'**
  String get sosNotifyTitle;

  /// No description provided for @sosNotifySub.
  ///
  /// In es, this message translates to:
  /// **'Se abre tu app de mensajes con el aviso ya escrito; tú tocas Enviar. Funciona sin internet.'**
  String get sosNotifySub;

  /// No description provided for @sosNoContacts.
  ///
  /// In es, this message translates to:
  /// **'Agrega contactos de confianza en tu plan de emergencia para avisarles por SMS.'**
  String get sosNoContacts;

  /// No description provided for @sosSmsFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir tus mensajes. Avísales por llamada.'**
  String get sosSmsFailed;

  /// No description provided for @smsAlert.
  ///
  /// In es, this message translates to:
  /// **'ALERTA ({situation}): {text}'**
  String smsAlert(String situation, String text);

  /// No description provided for @smsZone.
  ///
  /// In es, this message translates to:
  /// **'Mi zona aprox.: {lat}, {lng} (~1 km) {link}'**
  String smsZone(String lat, String lng, String link);

  /// No description provided for @smsRef.
  ///
  /// In es, this message translates to:
  /// **'Referencia: {ref}'**
  String smsRef(String ref);

  /// No description provided for @smsFooter.
  ///
  /// In es, this message translates to:
  /// **'Enviado desde Red del barrio. Si es grave, llama a emergencias.'**
  String get smsFooter;

  /// No description provided for @failContactName.
  ///
  /// In es, this message translates to:
  /// **'Escribe el nombre del contacto.'**
  String get failContactName;

  /// No description provided for @failContactPhone.
  ///
  /// In es, this message translates to:
  /// **'Escribe un teléfono válido (solo números).'**
  String get failContactPhone;

  /// No description provided for @failContactDup.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes ese contacto.'**
  String get failContactDup;

  /// No description provided for @failContactMax.
  ///
  /// In es, this message translates to:
  /// **'Puedes tener hasta 5 contactos.'**
  String get failContactMax;

  /// No description provided for @failSaveContact.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el contacto.'**
  String get failSaveContact;

  /// No description provided for @hintNeed3.
  ///
  /// In es, this message translates to:
  /// **'Escribe al menos 3 letras para continuar.'**
  String get hintNeed3;

  /// No description provided for @hintAddr.
  ///
  /// In es, this message translates to:
  /// **'Marca tu ubicación y ponle un nombre para guardar.'**
  String get hintAddr;

  /// No description provided for @hintContact.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre y un teléfono para guardar.'**
  String get hintContact;

  /// No description provided for @hintProfile.
  ///
  /// In es, this message translates to:
  /// **'Escribe un usuario de 3 letras o más y acepta para continuar.'**
  String get hintProfile;

  /// No description provided for @hintStars.
  ///
  /// In es, this message translates to:
  /// **'Elige cuántas estrellas das para enviar.'**
  String get hintStars;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsRowSub.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto, idioma, apariencia y ubicación.'**
  String get settingsRowSub;

  /// No description provided for @bidOfferBtn.
  ///
  /// In es, this message translates to:
  /// **'Ofertar'**
  String get bidOfferBtn;

  /// No description provided for @bidHelpBtn.
  ///
  /// In es, this message translates to:
  /// **'Ofrecer mi ayuda'**
  String get bidHelpBtn;

  /// No description provided for @bidMakeOffer.
  ///
  /// In es, this message translates to:
  /// **'Hacer mi oferta'**
  String get bidMakeOffer;

  /// No description provided for @bidMakeProposal.
  ///
  /// In es, this message translates to:
  /// **'Hacer mi propuesta'**
  String get bidMakeProposal;

  /// No description provided for @bidChangeOffer.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi oferta'**
  String get bidChangeOffer;

  /// No description provided for @bidChangeProposal.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi propuesta'**
  String get bidChangeProposal;

  /// No description provided for @bidMyOffer.
  ///
  /// In es, this message translates to:
  /// **'Mi oferta'**
  String get bidMyOffer;

  /// No description provided for @bidMyProposal.
  ///
  /// In es, this message translates to:
  /// **'Mi propuesta'**
  String get bidMyProposal;

  /// No description provided for @bidsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ofertas ({n})'**
  String bidsTitle(int n);

  /// No description provided for @proposalsCount.
  ///
  /// In es, this message translates to:
  /// **'Propuestas ({n})'**
  String proposalsCount(int n);

  /// No description provided for @bidRuleHigh.
  ///
  /// In es, this message translates to:
  /// **'Gana la oferta más alta.'**
  String get bidRuleHigh;

  /// No description provided for @bidRuleHighRef.
  ///
  /// In es, this message translates to:
  /// **'Gana la oferta más alta. Precio de referencia: {ref}.'**
  String bidRuleHighRef(String ref);

  /// No description provided for @bidRuleLow.
  ///
  /// In es, this message translates to:
  /// **'Gana la propuesta más baja. Puedes proponer 0 para un intercambio solidario.'**
  String get bidRuleLow;

  /// No description provided for @bidBestOffer.
  ///
  /// In es, this message translates to:
  /// **'Mejor oferta'**
  String get bidBestOffer;

  /// No description provided for @bidBestProposal.
  ///
  /// In es, this message translates to:
  /// **'Mejor propuesta'**
  String get bidBestProposal;

  /// No description provided for @bidPriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio en soles (0 = intercambio solidario)'**
  String get bidPriceLabel;

  /// No description provided for @bidPriceOfferLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu oferta en soles'**
  String get bidPriceOfferLabel;

  /// No description provided for @bidMessageLabel.
  ///
  /// In es, this message translates to:
  /// **'Mensaje (opcional)'**
  String get bidMessageLabel;

  /// No description provided for @bidMessageHint.
  ///
  /// In es, this message translates to:
  /// **'Qué ofreces, materiales, condiciones…'**
  String get bidMessageHint;

  /// No description provided for @bidWhenLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuándo puedes'**
  String get bidWhenLabel;

  /// No description provided for @bidWhenHint.
  ///
  /// In es, this message translates to:
  /// **'Hoy 4:00 p. m.'**
  String get bidWhenHint;

  /// No description provided for @bidSendOffer.
  ///
  /// In es, this message translates to:
  /// **'Enviar oferta'**
  String get bidSendOffer;

  /// No description provided for @bidSendProposal.
  ///
  /// In es, this message translates to:
  /// **'Enviar propuesta'**
  String get bidSendProposal;

  /// No description provided for @bidSaved.
  ///
  /// In es, this message translates to:
  /// **'Listo: tu oferta quedó guardada en tu teléfono.'**
  String get bidSaved;

  /// No description provided for @bidHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe un precio (0 = intercambio solidario).'**
  String get bidHint;

  /// No description provided for @bidNone.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay ofertas. ¡Sé el primero!'**
  String get bidNone;

  /// No description provided for @bidYourOffer.
  ///
  /// In es, this message translates to:
  /// **'Tu oferta: {price}'**
  String bidYourOffer(String price);

  /// No description provided for @bidNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este anuncio'**
  String get bidNotFound;

  /// No description provided for @bidDemoNote.
  ///
  /// In es, this message translates to:
  /// **'Las demás ofertas son de ejemplo. La tuya queda guardada en tu teléfono y se envía cuando haya internet.'**
  String get bidDemoNote;

  /// No description provided for @bidDemoSale1.
  ///
  /// In es, this message translates to:
  /// **'Lo recojo hoy mismo.'**
  String get bidDemoSale1;

  /// No description provided for @bidDemoSale2.
  ///
  /// In es, this message translates to:
  /// **'Pago al contado y paso por él mañana.'**
  String get bidDemoSale2;

  /// No description provided for @bidDemoReq1.
  ///
  /// In es, this message translates to:
  /// **'Lo resuelvo con mis propias herramientas.'**
  String get bidDemoReq1;

  /// No description provided for @bidDemoReq2.
  ///
  /// In es, this message translates to:
  /// **'Puedo ir mañana a primera hora.'**
  String get bidDemoReq2;

  /// No description provided for @bidDemoWhen1.
  ///
  /// In es, this message translates to:
  /// **'Hoy 6:00 p. m.'**
  String get bidDemoWhen1;

  /// No description provided for @bidDemoWhen2.
  ///
  /// In es, this message translates to:
  /// **'Mañana 9:00 a. m.'**
  String get bidDemoWhen2;

  /// No description provided for @failBidAmount.
  ///
  /// In es, this message translates to:
  /// **'Escribe un precio válido, de 0 a 99 999 soles.'**
  String get failBidAmount;

  /// No description provided for @failBidSave.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar tu oferta.'**
  String get failBidSave;

  /// No description provided for @failBidUpdate.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la oferta.'**
  String get failBidUpdate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
