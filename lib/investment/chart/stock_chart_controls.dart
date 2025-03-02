import 'package:flutter/material.dart';

class StockChartControls extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodSelected;
  final Function(bool) onZoom;

  const StockChartControls({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    required this.onZoom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> periods = ["1m", "D", "W", "M"];
    final Map<String, String> periodLabels = {
      "1m": "1분",
      "D": "일",
      "W": "주",
      "M": "월"
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ToggleButtons(
            isSelected: periods.map((period) => period == selectedPeriod).toList(),
            onPressed: (int index) {
              onPeriodSelected(periods[index]);
            },
            borderRadius: BorderRadius.circular(5),
            selectedColor: Colors.white,
            color: Colors.black,
            fillColor: Colors.blue,
            borderColor: Colors.grey,
            selectedBorderColor: Colors.blue,
            constraints: const BoxConstraints(minWidth: 60, minHeight: 35),
            children: periods.map((period) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  periodLabels[period] ?? period,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          SizedBox(width: 20),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: () => onZoom(false),
              ),
              IconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: () => onZoom(true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
