import 'package:app_task/shared/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/teacher_record_notifier.dart';

class GrabarClasePage extends ConsumerWidget {
  const GrabarClasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(teacherRecordNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Grabar Clase')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estado actual
            Text('Estado: ${recordState.state}'),
            const SizedBox(height: 16),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Iniciar / Reanudar
                IconButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[300])),
                  color: Colors.green,
                  onPressed: recordState.state == RecordingState.recording
                      ? null
                      : () => ref.read(teacherRecordNotifierProvider.notifier).startRecording(),
                  icon: const Icon(Icons.play_arrow),  
                  // child: const Text('Iniciar'),
                ),
                // Pausar
                IconButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[300])),
                  color: Colors.redAccent,
                  onPressed: recordState.state == RecordingState.recording
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).pauseRecording()
                      : null,
                  // child: const Text('Pausar'),
                  icon: const Icon(Icons.pause),
                ),
                // Reanudar
                IconButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[300])),
                  color: Colors.lightBlue,
                  onPressed: recordState.state == RecordingState.paused
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).resumeRecording()
                      : null,
                  // child: const Text('Reanudar'),
                  icon: const Icon(Icons.play_arrow_outlined),
                ),
                // Detener
                IconButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[300])),
                  color: Colors.black,
                  onPressed: (recordState.state == RecordingState.recording ||
                          recordState.state == RecordingState.paused)
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).stopRecording()
                      : null,
                  // child: const Text('Detener'),
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botón para enviar audio
            ElevatedButton(
              onPressed: recordState.state == RecordingState.stopped
                  ? () => ref.read(teacherRecordNotifierProvider.notifier).sendAudioAndGetSummary()
                  : null,
              child: recordState.state == RecordingState.sending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Convertir a Texto'),
            ),

            const SizedBox(height: 16),

             // Mostrar el texto convertido
            if (recordState.state == RecordingState.done && recordState.summary != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Texto de la clase grabada: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recordState.summary!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Mostrar error, si ocurre
            if (recordState.state == RecordingState.error && recordState.errorMessage != null)
              Text(
                'Error: ${recordState.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
