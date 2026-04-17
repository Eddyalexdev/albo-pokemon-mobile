import '../services/pokemon_api_service.dart';
import '../../shared/models/pokemon.dart';

/// Repository for Pokemon data with caching.
class PokemonRepository {
  final PokemonApiService _apiService;
  List<PokemonSummary>? _cachedList;

  PokemonRepository({required PokemonApiService apiService})
      : _apiService = apiService;

  /// Fetch all Pokemon, with in-memory cache.
  Future<List<PokemonSummary>> getPokemonList({bool forceRefresh = false}) async {
    if (_cachedList != null && !forceRefresh) {
      return _cachedList!;
    }

    _cachedList = await _apiService.fetchPokemonList();
    return _cachedList!;
  }

  /// Fetch Pokemon detail by ID.
  Future<PokemonDetail?> getPokemonDetail(String id) async {
    return _apiService.fetchPokemonDetail(id);
  }

  /// Fetch a random team of Pokemon.
  Future<List<PokemonDetail>> getRandomTeam(int count) async {
    return _apiService.fetchRandomTeam(count);
  }

  /// Get a random selection of Pokemon summaries.
  Future<List<PokemonSummary>> getRandomSelection(int count) async {
    final list = await getPokemonList();
    if (list.isEmpty) return [];

    final shuffled = List<PokemonSummary>.from(list)..shuffle();
    return shuffled.take(count).toList();
  }

  /// Clear the cache.
  void clearCache() {
    _cachedList = null;
  }
}
