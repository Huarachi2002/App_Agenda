import 'package:app_task/core/constants/api_endpoints.dart';
import 'package:app_task/services/speech_text_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../domain/repositories/teacher_record_repository.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
  sending,
  done,
  error, 
  converting
}

// Estado que mantiene info del resumen final, si existe
class TeacherRecordState {
  final RecordingState state;
  final String? summary;
  final String? errorMessage; // Mensaje de error (si ocurre)

  const TeacherRecordState({
    required this.state,
    this.summary,
    this.errorMessage,
  });
}

class TeacherRecordNotifier extends StateNotifier<TeacherRecordState> {
  final Record _record = Record();
  final TeacherRecordRepository repository;
  final SpeechToTextService speechToTextService;

  String? _audioPath; // guardamos la ruta del audio tras stop

  TeacherRecordNotifier(this.repository, this.speechToTextService) : super(const TeacherRecordState(state: RecordingState.idle));

  // Iniciar grabación
  Future<void> startRecording() async {
    try {
      if (await _record.hasPermission()) {
        // Opciones de grabación, por ejemplo .m4a
        await _record.start(
          encoder: AudioEncoder.wav, // o WAV
          samplingRate: 16000, // 16000 Hz
          numChannels: 1,
          path: _audioPath
          // optional: path: "some/path" para definir la ruta custom
        );
        state = const TeacherRecordState(state: RecordingState.recording);
      }
    } catch (e) {
      state = const TeacherRecordState(state: RecordingState.error);
    }
  }

  // Pausar
  Future<void> pauseRecording() async {
    try {
      await _record.pause();
      state = const TeacherRecordState(state: RecordingState.paused);
    } catch (e) {
      state = const TeacherRecordState(state: RecordingState.error);
    }
  }

  // Reanudar
  Future<void> resumeRecording() async {
    try {
      await _record.resume();
      state = const TeacherRecordState(state: RecordingState.recording);
    } catch (e) {
      state = const TeacherRecordState(state: RecordingState.error);
    }
  }

  // Detener grabación
  Future<void> stopRecording() async {
    try {
      final path = await _record.stop();
      if (path != null) {
        _audioPath = path;
        state = const TeacherRecordState(state: RecordingState.converting);

        // Convertir el audio a texto
        final text = await speechToTextService.convertAudioToText(_audioPath!);
        state = TeacherRecordState(
          state: RecordingState.done,
          summary: text,
        );

        // await speechToTextService.sendTextToBackend(text);
        
      } else {
        throw Exception('Error al detener la grabación');
      }
    } catch (e) {
      print('ERROR Convertir audio: ' + e.toString());
      state = TeacherRecordState(
        state: RecordingState.error,
        errorMessage: e.toString(),  
      );
    }
  }

  // Enviar audio y obtener resumen
  Future<void> sendAudioAndGetSummary() async {
    if (_audioPath == null) {
      return;
    }
    state = const TeacherRecordState(state: RecordingState.sending);
    try {
      final summary = await repository.sendAudioAndGetSummary(_audioPath!);
      // Éxito
      state = TeacherRecordState(state: RecordingState.done, summary: summary);
    } catch (e) {
      state = const TeacherRecordState(state: RecordingState.error);
    }
  }

}

final teacherRecordRepositoryProvider = Provider<TeacherRecordRepository>((ref) {
    throw UnimplementedError();
});

final teacherRecordNotifierProvider =
    StateNotifierProvider<TeacherRecordNotifier, TeacherRecordState>((ref) {
  final repo = ref.watch(teacherRecordRepositoryProvider);
  return TeacherRecordNotifier(repo , SpeechToTextService(API_SPEECH_TO_TEXT));
});
