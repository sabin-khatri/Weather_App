import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmamc/service/settings_service.dart';
import 'package:mmamc/service/notification_service.dart';
import 'package:mmamc/provider/theme_provider.dart';
import 'package:mmamc/provider/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _unit = 'metric';
  String _defaultCity = '';
  bool _notifEnabled = false;
  bool _rainAlert = true;
  TimeOfDay _notifTime = const TimeOfDay(hour: 7, minute: 0);
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final unit = await SettingsService.getUnit();
    final city = await SettingsService.getDefaultCity() ?? '';
    final notif = await SettingsService.getNotifEnabled();
    final rain = await SettingsService.getRainAlert();
    final hour = await SettingsService.getNotifHour();
    final minute = await SettingsService.getNotifMinute();

    setState(() {
      _unit = unit;
      _defaultCity = city;
      _notifEnabled = notif;
      _rainAlert = rain;
      _notifTime = TimeOfDay(hour: hour, minute: minute);
      _cityController.text = city;
    });
  }

  Future<void> _pickNotifTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifTime,
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      setState(() => _notifTime = picked);
      await SettingsService.setNotifTime(picked.hour, picked.minute);
      if (_notifEnabled) {
        await NotificationService.scheduleDailyNotification(
          city: _defaultCity.isNotEmpty ? _defaultCity : 'your city',
          weather: 'Check today\'s weather!',
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1B2A4A), const Color(0xFF0F1C3A)]
                : [const Color(0xFF4A90D9), const Color(0xFF87CEEB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [

                    // ── Dark / Light Mode ─────────────────
                    _sectionTitle('🌙 Appearance'),
                    _glassCard(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: isDark
                                    ? Colors.lightBlueAccent
                                    : Colors.amber,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Dark Mode',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                  Text(
                                    isDark ? 'Dark' : 'Light',
                                    style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.5),
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            activeColor: Colors.lightBlueAccent,
                            onChanged: (_) =>
                                themeProvider.toggleTheme(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Language ──────────────────────────
                    _sectionTitle('🌐 Language'),
                    _glassCard(
                      child: Column(
                        children: [
                          _langButton(
                            'English',
                            'en',
                            '🇬🇧',
                            languageProvider,
                          ),
                          const Divider(
                              color: Colors.white12, height: 16),
                          _langButton(
                            'नेपाली',
                            'ne',
                            '🇳🇵',
                            languageProvider,
                          ),
                          const Divider(
                              color: Colors.white12, height: 16),
                          _langButton(
                            'हिन्दी',
                            'hi',
                            '🇮🇳',
                            languageProvider,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Temperature Unit ──────────────────
                    _sectionTitle('🌡 Temperature Unit'),
                    _glassCard(
                      child: Row(
                        children: [
                          _unitButton('°C', 'metric'),
                          const SizedBox(width: 12),
                          _unitButton('°F', 'imperial'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Default City ──────────────────────
                    _sectionTitle('🏙 Default City'),
                    _glassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              style: const TextStyle(
                                  color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter default city...',
                                hintStyle: TextStyle(
                                    color: Colors.white
                                        .withOpacity(0.5)),
                                border: InputBorder.none,
                                prefixIcon: const Icon(
                                  Icons.location_city,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final city =
                                  _cityController.text.trim();
                              if (city.isNotEmpty) {
                                await SettingsService.setDefaultCity(
                                    city);
                                setState(
                                    () => _defaultCity = city);
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Default city set to $city'),
                                      backgroundColor:
                                          Colors.green
                                              .withOpacity(0.8),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Save',
                                style: TextStyle(
                                    color:
                                        Colors.lightBlueAccent)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Notifications ─────────────────────
                    _sectionTitle('🔔 Notifications'),
                    _glassCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Daily Weather Alert',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                  Text('Morning weather update',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13)),
                                ],
                              ),
                              Switch(
                                value: _notifEnabled,
                                activeColor: Colors.lightBlueAccent,
                                onChanged: (value) async {
                                  setState(
                                      () => _notifEnabled = value);
                                  await SettingsService
                                      .setNotifEnabled(value);
                                  if (value) {
                                    await NotificationService
                                        .scheduleDailyNotification(
                                      city: _defaultCity.isNotEmpty
                                          ? _defaultCity
                                          : 'your city',
                                      weather:
                                          'Check today\'s weather!',
                                      hour: _notifTime.hour,
                                      minute: _notifTime.minute,
                                    );
                                  } else {
                                    await NotificationService
                                        .cancelAll();
                                  }
                                },
                              ),
                            ],
                          ),
                          if (_notifEnabled) ...[
                            const Divider(
                                color: Colors.white24, height: 24),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Notification Time',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16)),
                                GestureDetector(
                                  onTap: _pickNotifTime,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlueAccent
                                          .withOpacity(0.2),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors
                                              .lightBlueAccent
                                              .withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      _notifTime.format(context),
                                      style: const TextStyle(
                                        color:
                                            Colors.lightBlueAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(
                              color: Colors.white24, height: 24),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Rain Alert',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16)),
                                  Text('Get warned before it rains',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13)),
                                ],
                              ),
                              Switch(
                                value: _rainAlert,
                                activeColor: Colors.lightBlueAccent,
                                onChanged: (value) async {
                                  setState(
                                      () => _rainAlert = value);
                                  await SettingsService
                                      .setRainAlert(value);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── App Reset ─────────────────────────
                    _sectionTitle('⚙️ App'),
                    _glassCard(
                      child: GestureDetector(
                        onTap: () async {
                          final prefs =
                              await SharedPreferences.getInstance();
                          await prefs
                              .setBool('onboarding_done', false);
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Onboarding reset — restart app'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.refresh,
                                color: Colors.white70),
                            SizedBox(width: 12),
                            Text('Reset Onboarding',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langButton(
    String label,
    String code,
    String flag,
    LanguageProvider provider,
  ) {
    final selected = provider.langCode == code;
    return GestureDetector(
      onTap: () => provider.setLanguage(code),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.lightBlueAccent : Colors.white,
                fontSize: 16,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle,
                color: Colors.lightBlueAccent, size: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _unitButton(String label, String value) {
    final selected = _unit == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() => _unit = value);
          await SettingsService.setUnit(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? Colors.lightBlueAccent.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.lightBlueAccent
                  : Colors.white24,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  selected ? Colors.lightBlueAccent : Colors.white54,
              fontSize: 18,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}