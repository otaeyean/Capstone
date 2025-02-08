import 'package:flutter/material.dart';

class SortDropdown extends StatefulWidget {
  @override
  _SortDropdownState createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  String selectedSort = "수익률 순";

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedSort,
      icon: Icon(Icons.arrow_drop_down),
      isExpanded: true,
      items: ["수익률 순", "보유 자산 순"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedSort = newValue!;
        });
      },
    );
  }
}
