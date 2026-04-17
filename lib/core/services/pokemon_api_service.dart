import 'package:dio/dio.dart';

import '../../shared/models/pokemon.dart';

/// Service for fetching Pokemon data from the API.
class PokemonApiService {
  final Dio _dio;
  final String baseUrl;

  PokemonApiService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// Fetch all Pokemon summaries from GET /list.
  Future<List<PokemonSummary>> fetchPokemonList() async {
    final response = await _dio.get('$baseUrl/list');
    final data = response.data;

    if (data is List) {
      return data
          .map((p) => PokemonSummary.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Fetch Pokemon detail from GET /list?id={id}.
  Future<PokemonDetail?> fetchPokemonDetail(String id) async {
    try {
      final response = await _dio.get(
        '$baseUrl/list',
        queryParameters: {'id': id},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return PokemonDetail.fromJson(data);
      }

      if (data is List && data.isNotEmpty) {
        return PokemonDetail.fromJson(data[0] as Map<String, dynamic>);
      }

      return null;
    } on DioException {
      return null;
    }
  }

  /// Fetch multiple random Pokemon for team selection.
  Future<List<PokemonDetail>> fetchRandomTeam(int count) async {
    final list = await fetchPokemonList();
    if (list.isEmpty) return [];

    final shuffled = List<PokemonSummary>.from(list)..shuffle();
    final selected = shuffled.take(count).toList();

    final details = <PokemonDetail>[];
    for (final summary in selected) {
      final detail = await fetchPokemonDetail(summary.id);
      if (detail != null) {
        details.add(detail);
      }
    }

    return details;
  }
}
