// core/theme — AppScope: an InheritedNotifier exposing AppState through context
// so every widget that reads the palette establishes a dependency and rebuilds
// instantly on theme / accent / data changes.
import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'app_palette.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}

/// Current palette WITH a rebuild dependency on theme/accent changes.
AppPalette pal(BuildContext context) => AppScope.of(context).palette;
