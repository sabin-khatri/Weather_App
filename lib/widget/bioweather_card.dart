import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmamc/model/weather.dart';
import 'package:mmamc/model/forecast.dart';
import 'package:mmamc/service/translation_service.dart';
import 'package:mmamc/util/responsive.dart';

class BioweatherCard extends StatefulWidget {
  final Weather weather;
  final AirQuality? airQuality;

  const BioweatherCard({
    super.key,
    required this.weather,
    this.airQuality,
  });

  @override
  State<BioweatherCard> createState() => _BioweatherCardState();
}

class _BioweatherCardState extends State<BioweatherCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  // Calculates Joint Pain Risk
  String get _jointPainRisk {
    final temp = widget.weather.temperature;
    final humidity = widget.weather.humidity;

    if (humidity > 75 && temp < 15) {
      return 'high';
    } else if (humidity > 60 && temp < 22) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  // Calculates Headache / Migraine Risk
  String get _migraineRisk {
    final pressure = widget.weather.pressure;
    if (pressure < 1009) {
      return 'high';
    } else if (pressure < 1014) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  // Calculates Allergy & Asthma Risk
  String get _allergyRisk {
    final wind = widget.weather.windSpeed;
    final aqi = widget.airQuality?.aqi ?? 1;

    if (wind > 8.0 || aqi >= 4) {
      return 'high';
    } else if (wind > 4.5 || aqi >= 3) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  // Calculates Wardrobe Recommendations
  String get _wardrobeAdvice {
    final temp = widget.weather.temperature;
    final desc = widget.weather.description.toLowerCase();

    bool isRaining = desc.contains('rain') || desc.contains('drizzle') || desc.contains('thunder');
    
    if (isRaining) {
      return TranslationService.get('ne' == TranslationService.get('language_code_test') ? 'umbrella_rain' : 'Bring an umbrella or raincoat! Wear waterproof shoes.');
    } else if (temp < 12) {
      return 'Heavy coat, winter jacket, and gloves are highly recommended.';
    } else if (temp < 20) {
      return 'A light jacket, sweater, or hoodie is perfect for this cool weather.';
    } else if (temp > 30) {
      return 'Wear loose, breathable cotton clothes. Put on sunglasses and stay hydrated!';
    } else if (desc.contains('clear')) {
      return 'Sun is bright! Lightweight clothes, sunglasses, and sunscreen are ideal.';
    } else {
      return 'Casual comfortable clothing is great. Perfect day for standard wear.';
    }
  }

  // Localized Wardrobe Advice
  String get _localizedWardrobeAdvice {
    final desc = widget.weather.description.toLowerCase();
    final temp = widget.weather.temperature;
    final bool isRaining = desc.contains('rain') || desc.contains('drizzle') || desc.contains('thunder');
    final String currentLang = TranslationService.get('save') == 'सेभ' ? 'ne' : (TranslationService.get('save') == 'सेव करें' ? 'hi' : 'en');

    if (currentLang == 'ne') {
      if (isRaining) return 'पानी परिरहेको छ! छाता वा बर्सादी (raincoat) बोक्नुहोला र वाटरप्रूफ जुत्ता लगाउनुहोला।';
      if (temp < 12) return 'चिसो छ! बाक्लो ज्याकेट, स्वीटर र पन्जा लगाउनुहोला।';
      if (temp < 20) return 'हल्का चिसो छ! पातलो ज्याकेट वा हुडी लगाउनु उपयुक्त हुन्छ।';
      if (temp > 30) return 'गर्मी छ! खुकुलो सुती (cotton) कपडा लगाउनुस्, सनग्लास प्रयोग गर्नुस् र पानी प्रशस्त पिउनुस्।';
      if (desc.contains('clear')) return 'घाम लागेको छ! पातलो कपडा र घामबाट बच्न सनग्लास वा टोपी लगाउनुहोला।';
      return 'सामान्य आरामदायी कपडा लगाउनुहोला। आजको दिनका लागि साधारण कपडा ठीक छ।';
    } else if (currentLang == 'hi') {
      if (isRaining) return 'बारिश हो रही है! छाता या रेनकोट साथ रखें और वाटरप्रूफ जूते पहनें।';
      if (temp < 12) return 'ठंड है! भारी कोट, स्वेटर और दस्ताने पहनना उचित रहेगा।';
      if (temp < 20) return 'हल्की ठंड है! हल्का जैकेट या स्वेटर इस सुहावने मौसम के लिए सही है।';
      if (temp > 30) return 'गर्मी है! ढीले सूती कपड़े पहनें, धूप का चश्मा लगाएं और खूब पानी पिएं।';
      if (desc.contains('clear')) return 'तेज धूप है! हल्के कपड़े पहनें, धूप का चश्मा और सनस्क्रीन का प्रयोग करें।';
      return 'सामान्य आरामदायक कपड़े पहनें। आज के लिए सामान्य कपड़े बढ़िया हैं।';
    } else {
      return _wardrobeAdvice;
    }
  }

  // Calculates Outdoor Fitness Score (0-100)
  int get _fitnessScore {
    int score = 100;
    final temp = widget.weather.temperature;
    final desc = widget.weather.description.toLowerCase();
    final wind = widget.weather.windSpeed;
    final aqi = widget.airQuality?.aqi ?? 1;

    // Precipitation check
    if (desc.contains('rain') || desc.contains('drizzle') || desc.contains('thunder')) {
      score -= 55;
    } else if (desc.contains('snow')) {
      score -= 50;
    }

    // Temperature checks
    if (temp > 35) {
      score -= 40;
    } else if (temp > 30) {
      score -= 15;
    } else if (temp < 8) {
      score -= 25;
    } else if (temp < 0) {
      score -= 45;
    }

    // Wind speed check
    if (wind > 10) {
      score -= 20;
    } else if (wind > 6) {
      score -= 10;
    }

    // AQI checks
    if (aqi >= 4) {
      score -= 30;
    } else if (aqi >= 3) {
      score -= 12;
    }

    return score.clamp(5, 100);
  }

  // Localized Fitness Advice
  String get _fitnessAdvice {
    final score = _fitnessScore;
    final String currentLang = TranslationService.get('save') == 'सेभ' ? 'ne' : (TranslationService.get('save') == 'सेव करें' ? 'hi' : 'en');

    if (currentLang == 'ne') {
      if (score >= 85) return 'बाहिर दौडिन, हिँड्न वा व्यायाम गर्नका लागि सर्वोत्कृष्ट मौसम छ!';
      if (score >= 60) return 'बाहिरी व्यायामका लागि राम्रो छ, तर हल्का हावा वा गर्मीको ख्याल गर्नुहोला।';
      if (score >= 30) return 'मौसम प्रतिकूल छ। सम्भव भएसम्म घरभित्रै व्यायाम (indoor workout) गर्नुहोला।';
      return 'बाहिर मौसम धेरै खराब छ। घरभित्रै आरामपूर्वक बस्नुहोला।';
    } else if (currentLang == 'hi') {
      if (score >= 85) return 'बाहर दौड़ने, टहलने या कसरत करने के लिए सर्वोत्तम मौसम है!';
      if (score >= 60) return 'बाहरी व्यायाम के लिए अच्छा है, लेकिन हल्की हवा या धूप का ध्यान रखें।';
      if (score >= 30) return 'मौसम प्रतिकूल है। घर के अंदर ही कसरत (indoor workout) करना बेहतर रहेगा।';
      return 'बाहर मौसम काफी खराब है। कृपया घर के भीतर सुरक्षित रहें।';
    } else {
      if (score >= 85) return 'Excellent conditions for jogging, outdoor workouts, or hiking!';
      if (score >= 60) return 'Good for outdoors, but watch out for slight wind or heat.';
      if (score >= 30) return 'Sub-optimal weather. Indoor workouts are recommended today.';
      return 'Unfavorable conditions. Stay indoors and enjoy light stretching.';
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'high': return const Color(0xFFEF4444); // Neon Red
      case 'moderate': return const Color(0xFFFACC15); // Neon Yellow
      case 'low': return const Color(0xFF22C55E); // Neon Green
      default: return Colors.white54;
    }
  }

  IconData _getWardrobeIcon() {
    final temp = widget.weather.temperature;
    final desc = widget.weather.description.toLowerCase();
    
    if (desc.contains('rain') || desc.contains('drizzle')) {
      return Icons.umbrella;
    } else if (temp < 15) {
      return Icons.checkroom; // warm layers
    } else if (temp > 28) {
      return Icons.dry_cleaning; // light clothes
    } else {
      return Icons.checkroom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final score = _fitnessScore;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.12 : 0.22),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Collapse Header
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isExpanded = !_isExpanded);
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.18),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TranslationService.get('bioweather'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isExpanded 
                              ? (TranslationService.get('save') == 'सेभ' ? 'स्वास्थ्य र पहिरन विवरण' : 'Health & wardrobe insights')
                              : (TranslationService.get('save') == 'सेभ' 
                                  ? 'तपाईंको स्वास्थ्य र व्यायाम स्कोर हेर्नुहोस्' 
                                  : 'Tap to view your health & outdoor fitness score'),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible Section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),

                    // SECTION 1: SMART WARDROBE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getWardrobeIcon(),
                            color: Colors.cyanAccent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TranslationService.get('wardrobe'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _localizedWardrobeAdvice,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // SECTION 2: HEALTH IMPACTS GRID
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = Responsive.isCompact(context);
                        if (compact) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  _buildHealthRiskTile(
                                    Icons.healing,
                                    TranslationService.get('jointPain'),
                                    _jointPainRisk,
                                  ),
                                  _buildHealthRiskTile(
                                    Icons.psychology,
                                    TranslationService.get('migraine'),
                                    _migraineRisk,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildHealthRiskTile(
                                    Icons.masks,
                                    TranslationService.get('allergy'),
                                    _allergyRisk,
                                  ),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            _buildHealthRiskTile(
                              Icons.healing,
                              TranslationService.get('jointPain'),
                              _jointPainRisk,
                            ),
                            _buildHealthRiskTile(
                              Icons.psychology,
                              TranslationService.get('migraine'),
                              _migraineRisk,
                            ),
                            _buildHealthRiskTile(
                              Icons.masks,
                              TranslationService.get('allergy'),
                              _allergyRisk,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3: FITNESS INDEX SCORE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              TranslationService.get('fitness'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: (score >= 80 ? Colors.green : (score >= 50 ? Colors.yellow : Colors.red)).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: score >= 80 ? Colors.green : (score >= 50 ? Colors.yellow : Colors.red),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$score%',
                                style: TextStyle(
                                  color: score >= 80 ? Colors.greenAccent : (score >= 50 ? Colors.yellowAccent : Colors.redAccent),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Linear glowing fitness bar
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: score / 100,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purpleAccent.withOpacity(0.8),
                                      (score >= 80 ? Colors.greenAccent : (score >= 50 ? Colors.yellowAccent : Colors.redAccent)),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (score >= 80 ? Colors.greenAccent : (score >= 50 ? Colors.yellowAccent : Colors.redAccent)).withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.directions_run,
                              color: Colors.white54,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _fitnessAdvice,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRiskTile(IconData icon, String label, String riskKey) {
    final color = _getRiskColor(riskKey);
    final String riskText = TranslationService.get(riskKey);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                riskText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
