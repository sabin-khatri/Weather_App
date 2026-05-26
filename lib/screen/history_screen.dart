import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mmamc/service/history_service.dart';
import 'package:mmamc/service/translation_service.dart';
import 'package:mmamc/provider/language_provider.dart';

class HistoryScreen extends StatefulWidget {
  final Function(String) onCitySelected;

  const HistoryScreen({super.key, required this.onCitySelected});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final h = await HistoryService.getHistory();
    setState(() => history = h);
  }

  Future<void> _clearAll() async {
    await HistoryService.clearHistory();
    setState(() => history = []);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // ← language change हुँदा rebuild

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B2A4A), Color(0xFF0F1C3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🕐 ${TranslationService.get('searchHistory')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: _clearAll,
                    child: Text(
                      TranslationService.get('clearAll'),
                      style:
                          const TextStyle(color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          ),
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.history,
                      size: 60,
                      color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    TranslationService.get('noHistory'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final city = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.12)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on,
                        color: Colors.lightBlueAccent),
                    title: Text(city,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white38, size: 20),
                      onPressed: () async {
                        await HistoryService.removeHistory(city);
                        _loadHistory();
                      },
                    ),
                    onTap: () {
                      widget.onCitySelected(city);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}