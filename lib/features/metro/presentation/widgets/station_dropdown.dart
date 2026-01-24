import 'package:flutter/material.dart';
import '../../domain/entities/station.dart';

class StationDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Station> stations;
  final Station? selectedStation;
  final ValueChanged<Station?> onChanged;

  const StationDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.stations,
    required this.selectedStation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<Station>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border:
              InputBorder.none, // Remove default border as container handles it
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        value: selectedStation,
        items: stations.map((station) {
          return DropdownMenuItem<Station>(
            value: station,
            child: Text(
              station.nameEn,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}
