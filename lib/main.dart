// =============================================================================
//  HAIR AGAIN — Premium Hair Transplant & Care Clinic ERP (Karachi)
//
//  App entry point only. Everything else lives in a feature-first structure:
//
//    lib/
//    ├── main.dart                      ← you are here (just runApp)
//    ├── core/
//    │   ├── core.dart                  ← barrel (state, theme, utils, widgets)
//    │   ├── state/app_state.dart       ← global store + NAVIGATION CONTROLLER
//    │   ├── theme/app_palette.dart     ← Obsidian & Gold / Clinical palette
//    │   ├── theme/app_scope.dart       ← InheritedNotifier (instant theme flip)
//    │   ├── utils/{formatters,dialogs}.dart
//    │   └── widgets/{common,charts,shell,app_root}.dart
//    └── modules/
//        ├── dashboard/views/dashboard_screen.dart
//        ├── crm/{models,views}/...
//        ├── pos_inventory/{models,views}/...
//        ├── appointments/{models,views}/...
//        ├── reports/views/reports_screen.dart
//        └── settings/views/settings_screen.dart
//
//  Run:  flutter pub get  →  flutter run -d windows  (or -d macos / -d chrome)
// =============================================================================
import 'package:flutter/material.dart';

import 'core/utils/storage_service.dart';
import 'core/widgets/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const HairAgainApp());
}
