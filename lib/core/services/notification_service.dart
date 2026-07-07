import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService(this._notifications);

  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> initialize() {
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open Plot');
    const windows = WindowsInitializationSettings(
      appName: 'Plot',
      appUserModelId: 'app.plot.plot',
      guid: '37b3b8e7-8509-4421-8f03-a1efdf7cbb4f',
    );

    const settings = InitializationSettings(
      macOS: darwin,
      linux: linux,
      windows: windows,
    );

    return _notifications.initialize(settings: settings).then((_) {});
  }
}
