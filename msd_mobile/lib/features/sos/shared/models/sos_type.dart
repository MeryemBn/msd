import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

enum SosType {
  doctor,
  teleconsult,
  nurse,
  ambulance;

  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case SosType.doctor: return l10n.doctor;
      case SosType.teleconsult: return l10n.teleconsultation;
      case SosType.nurse: return l10n.nurse;
      case SosType.ambulance: return l10n.ambulance;
    }
  }

  String get apiKey {
    switch (this) {
      case SosType.doctor: return 'DOCTOR';
      case SosType.teleconsult: return 'TELECONSULTATION';
      case SosType.nurse: return 'NURSE';
      case SosType.ambulance: return 'AMBULANCE';
    }
  }

  IconData get icon {
    switch (this) {
      case SosType.doctor: return Icons.medical_services_outlined;
      case SosType.teleconsult: return Icons.videocam_outlined;
      case SosType.nurse: return Icons.colorize_outlined;
      case SosType.ambulance: return Icons.local_shipping_outlined;
    }
  }

  Color get iconColor {
    switch (this) {
      case SosType.doctor: return const Color(0xFF5A5A5A);
      case SosType.teleconsult: return const Color(0xFF4A90D9);
      case SosType.nurse: return const Color(0xFFE8A048);
      case SosType.ambulance: return const Color(0xFFFF5252);
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case SosType.doctor: return const Color(0xFFF5F5F5);
      case SosType.teleconsult: return const Color(0xFFE3F2FD);
      case SosType.nurse: return const Color(0xFFFDF5E6);
      case SosType.ambulance: return const Color(0xFFFFEBEE);
    }
  }
}
