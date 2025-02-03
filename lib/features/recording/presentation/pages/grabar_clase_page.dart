import 'package:app_task/shared/widgets/app_drawer.dart';
import 'package:app_task/shared/widgets/background_gradient.dart';
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Estado: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Chip(
                      backgroundColor: _getChipColor(recordState.state),
                      label: Text(
                        recordState.state.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),


            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.mic,
                  label: "Grabar",
                  color: Colors.green,
                  onPressed: recordState.state == RecordingState.recording
                      ? null
                      : () => ref.read(teacherRecordNotifierProvider.notifier).startRecording(),
                ),
                _buildControlButton(
                  icon: Icons.pause,
                  label: "Pausar",
                  color: Colors.orange,
                  onPressed: recordState.state == RecordingState.recording
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).pauseRecording()
                      : null,
                ),
                _buildControlButton(
                  icon: Icons.play_arrow,
                  label: "Reanudar",
                  color: Colors.blue,
                  onPressed: recordState.state == RecordingState.paused
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).resumeRecording()
                      : null,
                ),
                _buildControlButton(
                  icon: Icons.stop,
                  label: "Detener",
                  color: Colors.red,
                  onPressed: (recordState.state == RecordingState.recording ||
                      recordState.state == RecordingState.paused)
                      ? () => ref.read(teacherRecordNotifierProvider.notifier).stopRecording()
                      : null,
                ),
              ],
            ),


            const SizedBox(height: 16),

            // Botón para enviar audio
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: recordState.state == RecordingState.stopped || recordState.state == RecordingState.done
                    ? const Color(0xff4c669f)
                    : Colors.grey, // Color gris cuando está deshabilitado
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: recordState.state == RecordingState.stopped || recordState.state == RecordingState.done
                  ? () => ref.read(teacherRecordNotifierProvider.notifier).sendAudioAndGetSummary()
                  : null,
              icon: const Icon(Icons.text_fields, color: Colors.white),
              label: recordState.state == RecordingState.sending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Obtener Resumen', style: TextStyle(color: Colors.white)),

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
                        'Resumen de la Clase:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Mostrar "Cargando..." mientras se genera el resumen
                      if (recordState.state == RecordingState.sending)
                        const Center(child: CircularProgressIndicator()),

                      // Mostrar el resumen si ya está generado
                      if (recordState.state == RecordingState.done && recordState.summary != null)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          color: Colors.white.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              recordState.summary!,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                      // Mostrar error si ocurre
                      if (recordState.state == RecordingState.error && recordState.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: ${recordState.errorMessage}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
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

  /// Función para construir botones de control
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: onPressed != null ? color : Colors.grey),
          onPressed: onPressed,
          iconSize: 32,
        ),
        Text(label, style: TextStyle(color: onPressed != null ? Colors.black : Colors.grey)),
      ],
    );
  }

  /// Devuelve un color diferente según el estado de grabación
  Color _getChipColor(RecordingState state) {
    switch (state) {
      case RecordingState.recording:
        return Colors.green;
      case RecordingState.paused:
        return Colors.orange;
      case RecordingState.stopped:
        return Colors.red;
      case RecordingState.sending:
        return Colors.blue;
      case RecordingState.done:
        return Colors.purple;
      case RecordingState.error:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
