import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _accessibilityBoxName = 'accessibility_box';

class AccessibilityState {
  final double textScaleFactor;
  final bool isHighContrast;
  final bool reduceMotion;
  final bool hapticsEnabled;

  const AccessibilityState({
    this.textScaleFactor = 1.0,
    this.isHighContrast = false,
    this.reduceMotion = false,
    this.hapticsEnabled = true,
  });

  AccessibilityState copyWith({
    double? textScaleFactor,
    bool? isHighContrast,
    bool? reduceMotion,
    bool? hapticsEnabled,
  }) {
    return AccessibilityState(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      isHighContrast: isHighContrast ?? this.isHighContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

class AccessibilityNotifier extends Notifier<AccessibilityState> {
  @override
  AccessibilityState build() {
    _loadAccessibilitySettings();
    return const AccessibilityState();
  }

  Future<void> _loadAccessibilitySettings() async {
    final box = await Hive.openBox(_accessibilityBoxName);
    final textScale = (box.get('textScaleFactor', defaultValue: 1.0) as num).toDouble();
    final highContrast = box.get('isHighContrast', defaultValue: false) as bool;
    final reduceMotion = box.get('reduceMotion', defaultValue: false) as bool;
    final haptics = box.get('hapticsEnabled', defaultValue: true) as bool;

    state = AccessibilityState(
      textScaleFactor: textScale,
      isHighContrast: highContrast,
      reduceMotion: reduceMotion,
      hapticsEnabled: haptics,
    );
  }

  Future<void> setTextScaleFactor(double factor) async {
    state = state.copyWith(textScaleFactor: factor);
    final box = await Hive.openBox(_accessibilityBoxName);
    await box.put('textScaleFactor', factor);
  }

  Future<void> setHighContrast(bool value) async {
    state = state.copyWith(isHighContrast: value);
    final box = await Hive.openBox(_accessibilityBoxName);
    await box.put('isHighContrast', value);
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    final box = await Hive.openBox(_accessibilityBoxName);
    await box.put('reduceMotion', value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    state = state.copyWith(hapticsEnabled: value);
    final box = await Hive.openBox(_accessibilityBoxName);
    await box.put('hapticsEnabled', value);
  }
}

final accessibilityNotifierProvider =
    NotifierProvider<AccessibilityNotifier, AccessibilityState>(
  AccessibilityNotifier.new,
);
