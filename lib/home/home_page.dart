import 'package:flutter/material.dart';
import 'package:medicationmanagement/medicament/add_medicament_page.dart';
import 'package:medicationmanagement/shared/empty_page.dart';

import '../data/database/database_helper.dart';
import '../data/model/medicament.dart';
import '../notification/notification_service.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Medicament> medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final dbHelper = DatabaseHelper.instance;
    final meds = await dbHelper.getAllMedications();
    setState(() {
      medications.clear();
      medications.addAll(meds);
    });
  }

  Future<void> _deleteMedicament(Medicament medicament) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteMedicament(medicament.id!);
    _loadMedications();
  }

  void _showDeleteDialog(Medicament medicament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Medicamento"),
        content:
            const Text("Você tem certeza que deseja excluir esse medicamento?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              _deleteMedicament(medicament);
              cancelMedicationNotifications(medicament);
              Navigator.of(context).pop();
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  void _navigateToAddMedicament() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicamentPage()),
    );
    _loadMedications();
  }

  void cancelMedicationNotifications(Medicament medicament) {
    final notificationService = NotificationService();
    for (int i = 0; i < medicament.times.length; i++) {
      int notificationId = int.parse('${medicament.id}$i');
      notificationService.cancelNotification(notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: medications.isEmpty
          ? const EmptyPage()
          : Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final med = medications[index];
                  return GestureDetector(
                    onLongPress: () => _showDeleteDialog(med),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: CheckboxListTile(
                        value: med.isChecked,
                        onChanged: (value) {
                          setState(() {
                            med.isChecked = value!;
                          });
                          DatabaseHelper.instance.updateMedicamentCheckStatus(
                              med.id!, med.isChecked);
                        },
                        title: Text(
                          med.name,
                          style: TextStyle(
                            decoration: med.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          "Dose: ${med.dosage}\nFrequência: ${med.frequency}\nHorários: ${med.times.join(', ')}",
                          style: TextStyle(
                            decoration: med.isChecked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddMedicament(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
