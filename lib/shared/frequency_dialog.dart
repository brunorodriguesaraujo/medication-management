import 'package:flutter/material.dart';

class FrequencyDialog extends StatelessWidget {
  final List<String> options;

  const FrequencyDialog({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Selecione a Frequência"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(options[index]),
              onTap: () {
                Navigator.pop(context, options[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
