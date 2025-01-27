class Medicament {
  int? id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  bool isChecked;

  Medicament({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.isChecked = false
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times.join(','),
      'isChecked': isChecked ? 1 : 0
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      times: (map['times'] as String).split(','),
      isChecked: map['isChecked'] == 1
    );
  }
}
