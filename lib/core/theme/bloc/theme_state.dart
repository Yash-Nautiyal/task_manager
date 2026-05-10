// theme_state.dart
part of 'theme_bloc.dart';

class ThemeState {
  final ThemeData themeData;
  final Brightness brightness;

  const ThemeState({required this.themeData, required this.brightness});

  ThemeState copyWith({ThemeData? themeData, Brightness? brightness}) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      brightness: brightness ?? this.brightness,
    );
  }
}
