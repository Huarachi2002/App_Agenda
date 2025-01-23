import 'package:app_task/features/agenda/domain/entities/comunication_entity.dart';
import 'package:app_task/features/agenda/domain/repository/comunication_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunicationNotifier extends StateNotifier<AsyncValue<CommunicationEntity?>> {
  final CommunicationRepository repository;

  CreateCommunicationNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createCommunication({
    required String title,
    required String content,
    required List<String> recipients,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newComm = await repository.createCommunication(
        title: title,
        content: content,
        createdAt: DateTime.now(),
        recipients: recipients,
      );
      state = AsyncValue.data(newComm);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createCommunicationProvider =
    StateNotifierProvider<CreateCommunicationNotifier, AsyncValue<CommunicationEntity?>>((ref) {
  final repo = ref.watch(communicationRepositoryProvider);
  return CreateCommunicationNotifier(repo);
});

// Provider que expone el repositorio
final communicationRepositoryProvider = Provider<CommunicationRepository>((ref) {
  throw UnimplementedError();
});
