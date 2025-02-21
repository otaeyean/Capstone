import 'package:flutter/material.dart';

class StockChartControls extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;

  const StockChartControls({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ["D", "W", "M"].map((period) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () => onPeriodSelected(period),
            child: Text(period),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPeriod == period ? Colors.blue : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }
}
