import 'package:flutter/material.dart';
import 'package:medicationmanagement/data/database/database_helper.dart';

import '../data/model/medicament.dart';
import '../notification/notification_service.dart';
import '../shared/frequency_dialog.dart';
import '../shared/time_picker_modal.dart';

class AddMedicamentPage extends StatefulWidget {
  const AddMedicamentPage({super.key});

  @override
  State<AddMedicamentPage> createState() => _AddMedicamentPageState();
}

class _AddMedicamentPageState extends State<AddMedicamentPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  String? selectedFrequency;
  List<String> selectedTimes = [];

  final List<String> frequencyOptions = [
    '1 vez ao dia',
    '2 vezes ao dia',
    '3 vezes ao dia'
  ];

  final notificationService = NotificationService();

  void scheduleMedicationNotifications(Medicament medicament) {
    for (int i = 0; i < medicament.times.length; i++) {
      String time = medicament.times[i];

      DateTime now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(time.split(':')[0]),
        int.parse(time.split(':')[1]),
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      int notificationId = int.parse('${medicament.id}$i');

      notificationService.scheduleNotification(
        id: notificationId,
        title: 'Hora de tomar o medicamento',
        body: '${medicament.name} - Dose: ${medicament.dosage}',
        scheduledTime: scheduledTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Adicionar Medicamento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nome do Medicamento",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Ex.: Paracetamol",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Dose (Comprimidos, gotas, cápsulas)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    hintText: "Ex.: 1 Comprimido",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Frequência",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    final frequency = await showDialog(
                      context: context,
                      builder: (context) => FrequencyDialog(
                        options: frequencyOptions,
                      ),
                    );
                    if (frequency != null) {
                      setState(() {
                        selectedFrequency = frequency;

                        int times = frequencyOptions.indexOf(frequency) + 1;
                        selectedTimes = List.generate(times, (index) => '');
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      selectedFrequency ?? "Selecione a frequência",
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedFrequency == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedTimes.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Horários",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: selectedTimes.asMap().entries.map((entry) {
                          int index = entry.key;
                          String time = entry.value;

                          return GestureDetector(
                            onTap: () async {
                              final selectedTime =
                                  await showModalBottomSheet<DateTime>(
                                context: context,
                                builder: (context) => const TimePickerModal(),
                              );

                              if (selectedTime != null) {
                                setState(() {
                                  selectedTimes[index] =
                                      "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                time.isEmpty ? "Horário ${index + 1}" : time,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      time.isEmpty ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameController.text;

                  if (name.isEmpty ||
                      selectedFrequency == null ||
                      selectedTimes.contains('') ||
                      dosageController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Por favor, preencha todos os campos."),
                      ),
                    );
                  } else {
                    final medicament = Medicament(
                      name: name,
                      dosage: dosageController.text,
                      frequency: selectedFrequency!,
                      times: selectedTimes,
                    );
                    final id = await DatabaseHelper.instance
                        .insertMedicament(medicament);
                    medicament.id = id;
                    scheduleMedicationNotifications(medicament);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Medicamento Adicionado"),
                        content: Text(
                          "Nome: $name\n"
                          "Dose: ${dosageController.text}\n"
                          "Frequência: $selectedFrequency\n"
                          "Horários: ${selectedTimes.join(', ')}",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
