import 'package:flutter/material.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';

class TimePickerModal extends StatelessWidget {
  const TimePickerModal({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime selectedTime = DateTime.now();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Selecione o horário",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TimePickerSpinner(
              is24HourMode: true,
              normalTextStyle:
                  const TextStyle(fontSize: 18, color: Colors.grey),
              highlightedTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              spacing: 50,
              itemHeight: 60,
              locale: const Locale('pt', 'BR'),
              isForce2Digits: true,
              onTimeChange: (time) {
                selectedTime = time;
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, selectedTime);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }
}
