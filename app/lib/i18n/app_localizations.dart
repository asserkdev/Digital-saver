import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('en'), Locale('ar'), Locale('es'), Locale('fr'),
    Locale('de'), Locale('zh'), Locale('ja'), Locale('ru'),
  ];

  static final Map<String, Map<String, String>> _t = {
    'en': {'app_name': 'Digital Saver', 'tagline': 'Your Personal Health Guardian', 'nav_dashboard': 'Dashboard', 'nav_heart': 'Heart', 'nav_bp': 'Blood Pressure', 'nav_activity': 'Activity', 'nav_sleep': 'Sleep', 'heart_rate': 'Heart Rate', 'blood_pressure': 'Blood Pressure', 'oxygen': 'Oxygen (SpO2)', 'hrv': 'HRV', 'afib': 'AFib Detection', 'bpm': 'BPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': 'Steps', 'calories': 'Calories', 'sleep': 'Sleep', 'status_normal': 'Normal', 'status_warning': 'Warning', 'status_critical': 'Critical', 'health_score': 'Health Score', 'recommendations': 'Recommendations', 'settings': 'Settings', 'language': 'Language', 'dark_mode': 'Dark Mode', 'save': 'Save', 'cancel': 'Cancel', 'connect': 'Connect', 'disconnect': 'Disconnect', 'scanning': 'Scanning...', 'watch_connected': 'Watch Connected', 'watch_disconnected': 'Watch Disconnected', 'last_sync': 'Last sync', 'battery': 'Battery', 'emergency': 'Emergency', 'emergency_alert': 'Emergency Alert!', 'are_you_okay': 'Are you okay?', 'call_emergency': 'Call Emergency', 'send_alert': 'Send Alert', 'cancel_alert': "I'm Okay", 'emergency_contacts': 'Emergency Contacts', 'loading': 'Loading...', 'no_data': 'No Data', 'medical_disclaimer': 'This app provides wellness estimates and is NOT a medical device.', 'select_language': 'Select Language', 'low_oxygen': 'Low Oxygen', 'high_blood_pressure': 'High Blood Pressure', 'irregular_heartbeat': 'Irregular Heartbeat', 'fall_detected': 'Fall Detected'},
    'ar': {'app_name': 'الحارس الصحي', 'tagline': 'حارسك الصحي الشخصي', 'nav_dashboard': 'لوحة التحكم', 'nav_heart': 'القلب', 'nav_bp': 'ضغط الدم', 'nav_activity': 'النشاط', 'nav_sleep': 'النوم', 'heart_rate': 'معدل ضربات القلب', 'blood_pressure': 'ضغط الدم', 'oxygen': 'الأكسجين', 'hrv': 'تغير معدل ضربات', 'afib': 'كشف الرجفان', 'bpm': 'نبضة/د', 'mmhg': 'مم زئبق', 'percent': '%', 'ms': 'مللي ث', 'steps': 'الخطوات', 'calories': 'السعرات', 'sleep': 'النوم', 'status_normal': 'طبيعي', 'status_warning': 'تحذير', 'status_critical': 'حرج', 'health_score': 'النتيجة الصحية', 'recommendations': 'التوصيات', 'settings': 'الإعدادات', 'language': 'اللغة', 'dark_mode': 'الوضع الداكن', 'save': 'حفظ', 'cancel': 'إلغاء', 'connect': 'اتصال', 'disconnect': 'قطع الاتصال', 'scanning': 'جاري البحث...', 'watch_connected': 'الساعة متصلة', 'watch_disconnected': 'الساعة غير متصلة', 'last_sync': 'آخر مزامنة', 'battery': 'البطارية', 'emergency': 'الطوارئ', 'emergency_alert': 'تنبيه طوارئ!', 'are_you_okay': 'هل أنت بخير؟', 'call_emergency': 'اتصال بالطوارئ', 'send_alert': 'إرسال تنبيه', 'cancel_alert': 'أنا بخير', 'emergency_contacts': 'جهات الاتصال الطارئة', 'loading': 'جاري التحميل...', 'no_data': 'لا توجد بيانات', 'medical_disclaimer': 'هذا التطبيق يوفر تقديرات صحية وليس جهازًا طبيًا.', 'select_language': 'اختر اللغة', 'low_oxygen': 'انخفاض الأكسجين', 'high_blood_pressure': 'ارتفاع ضغط الدم', 'irregular_heartbeat': 'عدم انتظام ضربات القلب', 'fall_detected': 'تم اكتشاف سقوط'},
    'es': {'app_name': 'Salvador Digital', 'tagline': 'Tu Guardián de Salud', 'nav_dashboard': 'Panel', 'nav_heart': 'Corazón', 'nav_bp': 'Presión', 'nav_activity': 'Actividad', 'nav_sleep': 'Sueño', 'heart_rate': 'Frecuencia Cardíaca', 'blood_pressure': 'Presión Arterial', 'oxygen': 'Oxígeno', 'hrv': 'VFC', 'afib': 'Detección FA', 'bpm': 'LPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': 'Pasos', 'calories': 'Calorías', 'sleep': 'Sueño', 'status_normal': 'Normal', 'status_warning': 'Advertencia', 'status_critical': 'Crítico', 'health_score': 'Puntuación de Salud', 'recommendations': 'Recomendaciones', 'settings': 'Ajustes', 'language': 'Idioma', 'dark_mode': 'Modo Oscuro', 'save': 'Guardar', 'cancel': 'Cancelar', 'connect': 'Conectar', 'disconnect': 'Desconectar', 'scanning': 'Buscando...', 'watch_connected': 'Reloj Conectado', 'watch_disconnected': 'Reloj Desconectado', 'last_sync': 'Última sincronización', 'battery': 'Batería', 'emergency': 'Emergencia', 'emergency_alert': '¡Alerta de Emergencia!', 'are_you_okay': '¿Estás bien?', 'call_emergency': 'Llamar a Emergencias', 'send_alert': 'Enviar Alerta', 'cancel_alert': 'Estoy Bien', 'emergency_contacts': 'Contactos de Emergencia', 'loading': 'Cargando...', 'no_data': 'Sin Datos', 'medical_disclaimer': 'Esta app proporciona estimaciones de bienestar y no es un dispositivo médico.', 'select_language': 'Seleccionar Idioma', 'low_oxygen': 'Oxígeno Bajo', 'high_blood_pressure': 'Presión Alta', 'irregular_heartbeat': 'Latido Irregular', 'fall_detected': 'Caída Detectada'},
    'fr': {'app_name': 'Sauvegarde Numérique', 'tagline': 'Votre Gardien de Santé', 'nav_dashboard': 'Tableau de Bord', 'nav_heart': 'Cœur', 'nav_bp': 'Tension', 'nav_activity': 'Activité', 'nav_sleep': 'Sommeil', 'heart_rate': 'Fréquence Cardiaque', 'blood_pressure': 'Tension Artérielle', 'oxygen': 'Oxygène', 'hrv': 'VRC', 'afib': 'Détection FA', 'bpm': 'BPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': 'Pas', 'calories': 'Calories', 'sleep': 'Sommeil', 'status_normal': 'Normal', 'status_warning': 'Attention', 'status_critical': 'Critique', 'health_score': 'Score de Santé', 'recommendations': 'Recommandations', 'settings': 'Paramètres', 'language': 'Langue', 'dark_mode': 'Mode Sombre', 'save': 'Enregistrer', 'cancel': 'Annuler', 'connect': 'Connecter', 'disconnect': 'Déconnecter', 'scanning': 'Recherche...', 'watch_connected': 'Montre Connectée', 'watch_disconnected': 'Montre Déconnectée', 'last_sync': 'Dernière synchro', 'battery': 'Batterie', 'emergency': 'Urgence', 'emergency_alert': 'Alerte d\'Urgence!', 'are_you_okay': 'Ça va?', 'call_emergency': 'Appeler Urgences', 'send_alert': 'Envoyer Alerte', 'cancel_alert': 'Je vais bien', 'emergency_contacts': 'Contacts d\'Urgence', 'loading': 'Chargement...', 'no_data': 'Pas de Données', 'medical_disclaimer': 'Cette app fournit des estimations de bien-être et n\'est pas un dispositif médical.', 'select_language': 'Choisir la Langue', 'low_oxygen': 'Oxygène Bas', 'high_blood_pressure': 'Hypertension', 'irregular_heartbeat': 'Rythme Irrégulier', 'fall_detected': 'Chute Détectée'},
    'de': {'app_name': 'Digital Retter', 'tagline': 'Dein Gesundheitswächter', 'nav_dashboard': 'Dashboard', 'nav_heart': 'Herz', 'nav_bp': 'Blutdruck', 'nav_activity': 'Aktivität', 'nav_sleep': 'Schlaf', 'heart_rate': 'Herzfrequenz', 'blood_pressure': 'Blutdruck', 'oxygen': 'Sauerstoff', 'hrv': 'HRV', 'afib': 'AFib Erkennung', 'bpm': 'BPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': 'Schritte', 'calories': 'Kalorien', 'sleep': 'Schlaf', 'status_normal': 'Normal', 'status_warning': 'Warnung', 'status_critical': 'Kritisch', 'health_score': 'Gesundheitswert', 'recommendations': 'Empfehlungen', 'settings': 'Einstellungen', 'language': 'Sprache', 'dark_mode': 'Dunkelmodus', 'save': 'Speichern', 'cancel': 'Abbrechen', 'connect': 'Verbinden', 'disconnect': 'Trennen', 'scanning': 'Suche...', 'watch_connected': 'Uhr Verbunden', 'watch_disconnected': 'Uhr Getrennt', 'last_sync': 'Letzte Sync', 'battery': 'Batterie', 'emergency': 'Notfall', 'emergency_alert': 'Notfallwarnung!', 'are_you_okay': 'Alles ok?', 'call_emergency': 'Notdienst rufen', 'send_alert': 'Alarm senden', 'cancel_alert': 'Mir geht es gut', 'emergency_contacts': 'Notfallkontakte', 'loading': 'Laden...', 'no_data': 'Keine Daten', 'medical_disclaimer': 'Diese App bietet Wellness-Schätzungen und ist kein Medizinprodukt.', 'select_language': 'Sprache wählen', 'low_oxygen': 'Niedriger Sauerstoff', 'high_blood_pressure': 'Hoher Blutdruck', 'irregular_heartbeat': 'Unregelmäßiger Herzschlag', 'fall_detected': 'Sturz Erkannt'},
    'zh': {'app_name': '数字守护', 'tagline': '您的个人健康守护者', 'nav_dashboard': '仪表板', 'nav_heart': '心脏', 'nav_bp': '血压', 'nav_activity': '活动', 'nav_sleep': '睡眠', 'heart_rate': '心率', 'blood_pressure': '血压', 'oxygen': '血氧', 'hrv': '心率变异', 'afib': '房颤检测', 'bpm': 'BPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': '步数', 'calories': '卡路里', 'sleep': '睡眠', 'status_normal': '正常', 'status_warning': '警告', 'status_critical': '危险', 'health_score': '健康评分', 'recommendations': '建议', 'settings': '设置', 'language': '语言', 'dark_mode': '深色模式', 'save': '保存', 'cancel': '取消', 'connect': '连接', 'disconnect': '断开', 'scanning': '搜索中...', 'watch_connected': '手表已连接', 'watch_disconnected': '手表已断开', 'last_sync': '上次同步', 'battery': '电池', 'emergency': '紧急', 'emergency_alert': '紧急警报!', 'are_you_okay': '你还好吗?', 'call_emergency': '呼叫急救', 'send_alert': '发送警报', 'cancel_alert': '我没事', 'emergency_contacts': '紧急联系人', 'loading': '加载中...', 'no_data': '无数据', 'medical_disclaimer': '此应用提供健康估计,不是医疗器械。', 'select_language': '选择语言', 'low_oxygen': '低血氧', 'high_blood_pressure': '高血压', 'irregular_heartbeat': '心律不齐', 'fall_detected': '检测到跌倒'},
    'ja': {'app_name': 'デジタルセーバー', 'tagline': 'あなたの健康守護者', 'nav_dashboard': 'ダッシュボード', 'nav_heart': '心臓', 'nav_bp': '血圧', 'nav_activity': 'アクティビティ', 'nav_sleep': '睡眠', 'heart_rate': '心拍数', 'blood_pressure': '血圧', 'oxygen': '酸素', 'hrv': '心拍変動', 'afib': 'AFib検出', 'bpm': 'BPM', 'mmhg': 'mmHg', 'percent': '%', 'ms': 'ms', 'steps': '歩数', 'calories': 'カロリー', 'sleep': '睡眠', 'status_normal': '正常', 'status_warning': '警告', 'status_critical': '危険', 'health_score': '健康スコア', 'recommendations': '推奨事項', 'settings': '設定', 'language': '言語', 'dark_mode': 'ダークモード', 'save': '保存', 'cancel': 'キャンセル', 'connect': '接続', 'disconnect': '切断', 'scanning': 'スキャン中...', 'watch_connected': 'ウォッチ接続済み', 'watch_disconnected': 'ウォッチ未接続', 'last_sync': '最終同期', 'battery': 'バッテリー', 'emergency': '緊急', 'emergency_alert': '緊急アラート!', 'are_you_okay': '大丈夫ですか?', 'call_emergency': '緊急連絡', 'send_alert': 'アラート送信', 'cancel_alert': '大丈夫です', 'emergency_contacts': '緊急連絡先', 'loading': '読み込み中...', 'no_data': 'データなし', 'medical_disclaimer': 'このアプリはウェルネス推定を提供し、医療機器ではありません。', 'select_language': '言語選択', 'low_oxygen': '低酸素', 'high_blood_pressure': '高血压', 'irregular_heartbeat': '不整脈', 'fall_detected': '転倒検出'},
    'ru': {'app_name': 'Цифровой Спасатель', 'tagline': 'Ваш личный хранитель здоровья', 'nav_dashboard': 'Панель', 'nav_heart': 'Сердце', 'nav_bp': 'Давление', 'nav_activity': 'Активность', 'nav_sleep': 'Сон', 'heart_rate': 'ЧСС', 'blood_pressure': 'АД', 'oxygen': 'Кислород', 'hrv': 'ВСР', 'afib': 'Фибрилляция', 'bpm': 'уд/мин', 'mmhg': 'мм рт.ст.', 'percent': '%', 'ms': 'мс', 'steps': 'Шаги', 'calories': 'Калории', 'sleep': 'Сон', 'status_normal': 'Норма', 'status_warning': 'Внимание', 'status_critical': 'Критично', 'health_score': 'Оценка здоровья', 'recommendations': 'Рекомендации', 'settings': 'Настройки', 'language': 'Язык', 'dark_mode': 'Тёмный режим', 'save': 'Сохранить', 'cancel': 'Отмена', 'connect': 'Подключить', 'disconnect': 'Отключить', 'scanning': 'Поиск...', 'watch_connected': 'Часы подключены', 'watch_disconnected': 'Часы отключены', 'last_sync': 'Последняя синхр.', 'battery': 'Батарея', 'emergency': 'Экстренный', 'emergency_alert': 'Экстренное оповещение!', 'are_you_okay': 'Вы в порядке?', 'call_emergency': 'Вызвать скорую', 'send_alert': 'Отправить оповещение', 'cancel_alert': 'Я в порядке', 'emergency_contacts': 'Экстренные контакты', 'loading': 'Загрузка...', 'no_data': 'Нет данных', 'medical_disclaimer': 'Это приложение提供健康估计,不是医疗器械。', 'select_language': 'Выбрать язык', 'low_oxygen': 'Низкий кислород', 'high_blood_pressure': 'Высокое давление', 'irregular_heartbeat': 'Аритмия', 'fall_detected': 'Падение обнаружено'},
  };

  String t(String key) => _t[locale.languageCode]?[key] ?? _t['en']![key]!;

  String get appName => t('app_name');
  String get tagline => t('tagline');
  String get navDashboard => t('nav_dashboard');
  String get navHeart => t('nav_heart');
  String get navBP => t('nav_bp');
  String get navActivity => t('nav_activity');
  String get navSleep => t('nav_sleep');
  String get heartRate => t('heart_rate');
  String get bloodPressure => t('blood_pressure');
  String get oxygen => t('oxygen');
  String get hrv => t('hrv');
  String get afib => t('afib');
  String get bpm => t('bpm');
  String get mmhg => t('mmhg');
  String get percent => t('percent');
  String get ms => t('ms');
  String get steps => t('steps');
  String get calories => t('calories');
  String get sleep => t('sleep');
  String get statusNormal => t('status_normal');
  String get statusWarning => t('status_warning');
  String get statusCritical => t('status_critical');
  String get healthScore => t('health_score');
  String get recommendations => t('recommendations');
  String get settings => t('settings');
  String get language => t('language');
  String get darkMode => t('dark_mode');
  String get save => t('save');
  String get cancel => t('cancel');
  String get connect => t('connect');
  String get disconnect => t('disconnect');
  String get scanning => t('scanning');
  String get watchConnected => t('watch_connected');
  String get watchDisconnected => t('watch_disconnected');
  String get lastSync => t('last_sync');
  String get battery => t('battery');
  String get emergency => t('emergency');
  String get emergencyAlert => t('emergency_alert');
  String get areYouOkay => t('are_you_okay');
  String get callEmergency => t('call_emergency');
  String get sendAlert => t('send_alert');
  String get cancelAlert => t('cancel_alert');
  String get emergencyContacts => t('emergency_contacts');
  String get loading => t('loading');
  String get noData => t('no_data');
  String get medicalDisclaimer => t('medical_disclaimer');
  String get selectLanguage => t('select_language');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['en', 'ar', 'es', 'fr', 'de', 'zh', 'ja', 'ru'].contains(locale.languageCode);
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}
