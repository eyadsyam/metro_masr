import 'package:floor/floor.dart';

@entity
class LineEntity {
  @primaryKey
  final int id;

  final String nameAr;
  final String nameEn;
  final String colorHex;

  LineEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.colorHex,
  });
}
