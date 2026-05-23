import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/screen_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLanguageScreen extends StatefulWidget {
  @override
  _SelectLanguageScreenState createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final List<LanguageOption> _languages = [
    LanguageOption('Nederlands', '🇳🇱'),
    LanguageOption('English', '🇬🇧'),
    LanguageOption('French', '🇫🇷'),
    LanguageOption('German', '🇩🇪'),
  ];

  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('preferred_language') ?? 'Nederlands';
    });
  }

  Future<void> _saveSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language', language);
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    _saveSelectedLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      appBar: canPop
          ? AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding * 2),
              Text(
                "Select your preferred language",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                'You will use the same language throughout the app.',
              ),
              const SizedBox(height: defaultPadding * 2),
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = lang.name == _selectedLanguage;

                    return GestureDetector(
                      onTap: () => _selectLanguage(lang.name),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: defaultPadding / 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryMaterialColor.shade800
                              : cardBackgroundColor,
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                          border: Border.all(
                            color:
                                isSelected ? primaryColor : cardBackgroundColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang.flag, style: TextStyle(fontSize: 20)),
                            SizedBox(width: defaultPadding),
                            Expanded(
                              child: Text(
                                lang.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                height: 24,
                                width: 24,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(LucideIcons.check, size: 16, color: backgroundColor),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!canPop)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, logInScreenRoute);
                  },
                  child: const Text("Continue"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String name;
  final String flag;

  LanguageOption(this.name, this.flag);
}
