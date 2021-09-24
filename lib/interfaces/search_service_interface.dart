import 'package:anonymous_chat/models/tag.dart';
import 'package:anonymous_chat/services.dart/algolia.dart';

abstract class ISearchService {
  static ISearchService get searchService => AlgoliaSearch();

  Future<List<Map<String, dynamic>>> getTagSuggestions({required String label});

  Future<void> addSearchableTag({required Tag tag});
}
