import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pantalla de foto a pantalla completa con zoom (pinch-to-zoom) y pan.
///
/// Uso desde cualquier pagina:
/// ```dart
/// Navigator.push(context, AppPhotoViewer.route(url: imageUrl));
/// ```
///
/// La transicion es un fade-in sobre fondo negro.
/// El usuario puede:
///   - Pellizcar para hacer zoom (hasta 5x).
///   - Arrastrar cuando esta ampliada.
///   - Tocar el boton X o presionar Atras para cerrar.
///   - Doble tap para ampliar 2.5x centrado donde toco / volver a 1:1.
class AppPhotoViewer extends StatefulWidget {
  const AppPhotoViewer({
    super.key,
    required this.url,
    this.heroTag,
  });

  final String url;

  /// Tag opcional para la animacion Hero.
  /// Debe coincidir con el Hero en la pantalla de origen.
  final Object? heroTag;

  static Route<void> route({required String url, Object? heroTag}) {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          AppPhotoViewer(url: url, heroTag: heroTag),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  State<AppPhotoViewer> createState() => _AppPhotoViewerState();
}

class _AppPhotoViewerState extends State<AppPhotoViewer>
    with SingleTickerProviderStateMixin {
  final _transformationController = TransformationController();
  late final AnimationController _resetAnimController;
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _resetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformationController.value = _resetAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformationController.dispose();
    _resetAnimController.dispose();
    super.dispose();
  }

  /// Doble tap: alterna entre 1:1 y 2.5x centrado en el punto tocado.
  void _onDoubleTap(TapDownDetails details) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    if (currentScale > 1.0) {
      // Ya esta ampliada: animar de vuelta a 1:1.
      final begin = _transformationController.value;
      final end = Matrix4.identity();
      _resetAnimation = Matrix4Tween(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: _resetAnimController,
          curve: Curves.easeOutCubic,
        ),
      );
      _resetAnimController
        ..reset()
        ..forward();
    } else {
      // Zoom 2.5x centrado en el punto donde toco el usuario.
      // Construye la matriz: Scale * Translation, para que el tap point quede fijo.
      //   m[0,0] = scale (eje X)
      //   m[1,1] = scale (eje Y)
      //   m[0,3] = dx    (traslacion X = -tapX * (scale - 1))
      //   m[1,3] = dy    (traslacion Y = -tapY * (scale - 1))
      const scale = 2.5;
      final tapX = details.localPosition.dx;
      final tapY = details.localPosition.dy;
      final zoomed = Matrix4.identity();
      zoomed.setEntry(0, 0, scale);
      zoomed.setEntry(1, 1, scale);
      zoomed.setEntry(0, 3, -tapX * (scale - 1));
      zoomed.setEntry(1, 3, -tapY * (scale - 1));
      _transformationController.value = zoomed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, imageUrl) => const Center(
        child: SizedBox.square(
          dimension: 32,
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2.5,
          ),
        ),
      ),
      errorWidget: (context, imageUrl, error) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.broken_image_outlined,
            color: Colors.white38,
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar la foto',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: _onDoubleTap,
        onDoubleTap: () {}, // requerido para que onDoubleTapDown se dispare
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: widget.heroTag != null
                ? Hero(tag: widget.heroTag!, child: imageWidget)
                : imageWidget,
          ),
        ),
      ),
    );
  }
}
