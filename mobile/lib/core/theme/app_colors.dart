import 'package:flutter/painting.dart';

abstract final class AppColors {
  // MARK: - Accent
  static const accent100 = Color(0xFFEEF6FF);
  static const accent200 = Color(0xFFD6EBFF);
  static const accent300 = Color(0xFFB5D9FD);
  static const accent400 = Color(0xFF94BCE3);
  static const accent500 = Color(0xFF749DC4);
  static const accent = Color(0xFF5980A6);
  static const accent600 = Color(0xFF597EA3);
  static const accent700 = Color(0xFF416180);
  static const accent800 = Color(0xFF2C455D);
  static const accent900 = Color(0xFF1D2D3D);

  // MARK: - Neutral
  static const neutral100 = Color(0xFFF5F5F8);
  static const neutral200 = Color(0xFFE7E7EA);
  static const neutral300 = Color(0xFFD4D4D7);
  static const neutral400 = Color(0xFFB7B7BA);
  static const neutral500 = Color(0xFF98989B);
  static const neutral600 = Color(0xFF7A7A7D);
  static const neutral700 = Color(0xFF5D5D60);
  static const neutral800 = Color(0xFF424244);
  static const neutral900 = Color(0xFF2B2B2D);

  // MARK: - Surfaces
  static const bg = Color(0xFFF2F2F3);
  static const surface = Color(0xFFE9E9EA);
  static const paper = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1D1F20);
  static const divider = neutral300;

  // MARK: - Result field
  static const fieldValid = accent;
  static const fieldRepeat = accent900;
  static const fieldRefused = neutral900;
  static const fieldCampaign = neutral900;

  // MARK: - Camera
  static const cameraLive = Color(0xFF15181A);
  static const cameraLowLight = Color(0xFF0B0D0E);
}