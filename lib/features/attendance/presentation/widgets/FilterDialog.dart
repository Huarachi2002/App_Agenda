import 'package:app_task/features/attendance/presentation/models/filter_result.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/formats.dart';

class FilterDialog extends StatefulWidget {
  final String? initialSubject;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const FilterDialog({
    Key? key,
    this.initialSubject,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? subject;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    subject = widget.initialSubject;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar Asistencia'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: subject,
              decoration: const InputDecoration(labelText: 'Materia'),
              items: const [
                DropdownMenuItem(child: Text('Matemáticas'), value: 'Matemáticas'),
                DropdownMenuItem(child: Text('Lengua'), value: 'Lengua'),
                DropdownMenuItem(child: Text('Historia'), value: 'Historia'),
              ],
              onChanged: (value) => setState(() => subject = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(startDate == null
                      ? 'Fecha inicio: ---'
                      : 'Fecha inicio: ${formatDate(startDate!)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => startDate = picked);
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(endDate == null
                      ? 'Fecha fin: ---'
                      : 'Fecha fin: ${formatDate(endDate!)}'),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => endDate = picked);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, FilterResult());
          },
          child: const Text('Limpiar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              FilterResult(subject: subject, startDate: startDate, endDate: endDate),
            );
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }

  
}
