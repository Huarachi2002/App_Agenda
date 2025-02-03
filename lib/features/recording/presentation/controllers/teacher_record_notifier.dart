import 'package:app_task/core/constants/api_endpoints.dart';
import 'package:app_task/services/speech_text_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../data/gemini_service.dart';
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
  final String? transcript; // Texto transcrito
  final String? summary; // Resumen generado por OpenAI
  final String? errorMessage; // Mensaje de error (si ocurre)

  const TeacherRecordState({
    required this.state,
    this.transcript,
    this.summary,
    this.errorMessage,
  });


  TeacherRecordState copyWith({
    RecordingState? state,
    String? transcript,
    String? summary,
    String? errorMessage,
  }) {
    return TeacherRecordState(
      state: state ?? this.state,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

}

class TeacherRecordNotifier extends StateNotifier<TeacherRecordState> {
  final Record _record = Record();
  final TeacherRecordRepository repository;
  final SpeechToTextService speechToTextService;
  final GeminiService  _openAIService = GeminiService ();

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

        state = state.copyWith(state: RecordingState.stopped);

        state = state.copyWith(state: RecordingState.converting);

        // Convertir el audio a texto
        final text = await speechToTextService.convertAudioToText(_audioPath!);
        if (text.isNotEmpty) {
          state = state.copyWith(state: RecordingState.done, transcript: text);
        } else {
          throw Exception("La transcripción está vacía.");
        }

        // await speechToTextService.sendTextToBackend(text);

      } else {
        throw Exception("No se generó el archivo de audio.");
      }
    } catch (e) {
      print('ERROR Convertir audio: ' + e.toString());
      state = state.copyWith(state: RecordingState.error, errorMessage: e.toString());
    }
  }

  // Enviar audio y obtener resumen
  Future<void> sendAudioAndGetSummary() async {
    if (state.transcript == null || state.transcript!.isEmpty) {
      state = state.copyWith(state: RecordingState.error, errorMessage: "No hay texto para resumir.");
      return;
    }

    state = state.copyWith(state: RecordingState.sending);

    try {
      print("========== Enviar audio y obtener resumen ============");
      final summary = await _openAIService.getSummary(state.transcript!);
      print("Summary: " + summary.toString());
      if (summary != null) {
        state = state.copyWith(state: RecordingState.done, summary: summary);
      } else {
        throw Exception("Error al obtener el resumen de OpenAI.");
      }
    } catch (e) {
      print("Error en OpenAI: $e");
      state = state.copyWith(state: RecordingState.error, errorMessage: e.toString());
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
