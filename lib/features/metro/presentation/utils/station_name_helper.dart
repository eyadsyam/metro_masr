import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/station.dart';

class StationNameHelper {
  static String getStationName(BuildContext context, Station station) {
    final locale = context.locale;
    return locale.languageCode == 'ar' ? station.nameAr : station.nameEn;
  }

  static String getStationDisplayName(Station station, String languageCode) {
    return languageCode == 'ar' ? station.nameAr : station.nameEn;
  }
}
