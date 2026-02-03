import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';
import 'screens/chat_screen.dart';
import 'services/research_service.dart';

void main() {
  runApp(const IntelliResearchApp());
}

class IntelliResearchApp extends StatelessWidget {
  const IntelliResearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResearchService(),
      child: MaterialApp(
        title: 'IntelliResearch AI',
        debugShowCheckedModeBanner: false,

        // ------------------------------------------------------------
        // COPILOT BLUE THEME
        // ------------------------------------------------------------
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // ------------------------------------------------------------
        // HOME SCREEN
        // ------------------------------------------------------------
        home: const ChatScreen(),
      ),
    );
  }
}
