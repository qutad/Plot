import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot/app/plot_app.dart';
import 'package:plot/core/theme/plot_theme.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isMobilePlatform) {
    await _configureMobileSystemUi();
  } else if (_isDesktopPlatform) {
    await _configureDesktopWindow();
  }

  runApp(const ProviderScope(child: PlotApp()));
}

bool get _isMobilePlatform {
  if (kIsWeb) {
    return false;
  }

  return {
    TargetPlatform.android,
    TargetPlatform.iOS,
  }.contains(defaultTargetPlatform);
}

bool get _isDesktopPlatform {
  if (kIsWeb) {
    return false;
  }

  return {
    TargetPlatform.linux,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  }.contains(defaultTargetPlatform);
}

Future<void> _configureMobileSystemUi() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
  SystemChrome.setSystemUIOverlayStyle(PlotTheme.systemUiOverlayStyle);
}

Future<void> _configureDesktopWindow() async {
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1440, 920),
    minimumSize: Size(1200, 720),
    center: true,
    title: 'Plot',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
