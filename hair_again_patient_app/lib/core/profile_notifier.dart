import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileNotifier extends ChangeNotifier {
  String _name     = 'Ahmad Ali';
  String _initials = 'AA';
  Uint8List? _avatarBytes;

  String      get name         => _name;
  String      get initials     => _initials;
  Uint8List?  get avatarBytes  => _avatarBytes;

  void setName(String name) {
    _name = name.trim().isEmpty ? _name : name.trim();
    _initials = _computeInitials(_name);
    notifyListeners();
  }

  void setAvatar(Uint8List? bytes) {
    _avatarBytes = bytes;
    notifyListeners();
  }

  static String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

final profileNotifier = ProfileNotifier();
