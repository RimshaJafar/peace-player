class SearchInput {
  final String query;
  final int? maxResults;
  final List<String> filters;

  SearchInput({
    required String query,
    this.maxResults,
    required this.filters,
  }) : query = query.trim() {
    if (this.query.isEmpty) {
      throw ArgumentError.value(query, 'query', 'must not be empty');
    }
  }
}
