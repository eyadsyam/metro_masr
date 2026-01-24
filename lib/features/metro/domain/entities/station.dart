// Domain Entity: Station
import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Station extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? landmarkAr;
  final String? landmarkEn;
  final int lineId;
  final bool isInterchange;
  final double latitude;
  final double longitude;

  const Station({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.landmarkAr,
    this.landmarkEn,
    required this.lineId,
    required this.isInterchange,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    landmarkAr,
    landmarkEn,
    lineId,
    isInterchange,
    latitude,
    longitude,
  ];
}

extension StationLocalized on Station {
  String getName(BuildContext context) {
    try {
      bool isAr = context.locale.languageCode == 'ar';
      return isAr ? nameAr : nameEn;
    } catch (e) {
      return nameEn;
    }
  }

  String? getLandmark(BuildContext context) {
    try {
      bool isAr = context.locale.languageCode == 'ar';
      return isAr ? landmarkAr : landmarkEn;
    } catch (e) {
      return landmarkEn;
    }
  }
}
