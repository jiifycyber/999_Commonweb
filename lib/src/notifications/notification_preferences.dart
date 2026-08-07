class NotificationPreferences {
  final bool sound;
  final bool vibration;
  final bool visualFlash;
  final bool armedAlerts;
  final bool entryNowAlerts;

  const NotificationPreferences({
    this.sound = true,
    this.vibration = true,
    this.visualFlash = true,
    this.armedAlerts = true,
    this.entryNowAlerts = true,
  });
}
