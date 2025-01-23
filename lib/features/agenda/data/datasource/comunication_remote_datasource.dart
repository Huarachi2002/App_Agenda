import 'package:app_task/features/agenda/data/models/comunication_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class CommunicationRemoteDataSource {
  Future<CommunicationModel> createCommunication(CommunicationModel communication);

  Future<List<CommunicationModel>> getCommunications({Map<String, dynamic>? filters});
}

class CommunicationRemoteDataSourceImpl implements CommunicationRemoteDataSource {
  final http.Client client;

  CommunicationRemoteDataSourceImpl(this.client);

  @override
  Future<CommunicationModel> createCommunication(CommunicationModel communication) async {
    // Ejemplo de llamada POST al backend
    final url = Uri.parse('https://tu-backend.com/api/communications');
    final response = await client.post(
      url,
      body: jsonEncode(communication.toMap()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CommunicationModel.fromMap(data);
    } else {
      throw Exception('Error al crear el comunicado');
    }
  }

  @override
  Future<List<CommunicationModel>> getCommunications({Map<String, dynamic>? filters}) async {
    // Ejemplo de llamado GET con posibles parámetros de filtro
    final queryParams = <String, String>{};
    if (filters != null) {
      // E.g. si filters['course'] != null => queryParams['course'] = filters['course']
      filters.forEach((key, value) {
        queryParams[key] = value.toString();
      });
    }

    final uri = Uri.https('tu-backend.com', '/api/communications', queryParams);

    final response = await client.get(uri);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => CommunicationModel.fromMap(json)).toList();
    } else {
      throw Exception('Error al obtener comunicados');
    }
  }
}
