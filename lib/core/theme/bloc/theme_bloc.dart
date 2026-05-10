import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/core/theme/app_theme.dart';
part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc._(this._prefs, ThemeState initial) : super(initial) {
    on<ToggleBrightnessEvent>(_onToggleBrightness);
  }

  static Future<ThemeBloc> create() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIsDark = prefs.getBool('theme_isDark') ?? false;

    final brightness = savedIsDark ? Brightness.dark : Brightness.light;
    final theme = buildTheme(brightness: brightness);

    return ThemeBloc._(
      prefs,
      ThemeState(themeData: theme, brightness: brightness),
    );
  }

  void _onToggleBrightness(
    ToggleBrightnessEvent event,
    Emitter<ThemeState> emit,
  ) {
    final newBrightness =
        state.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;
    _prefs.setBool('theme_isDark', newBrightness == Brightness.dark);
    final newTheme = buildTheme(brightness: newBrightness);
    print('Brightness toggled to $newBrightness');
    emit(state.copyWith(themeData: newTheme, brightness: newBrightness));
  }
}
