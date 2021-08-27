import 'package:anonymous_chat/models/tag.dart';

abstract class ISearchService {
  Future<List<Map<String, dynamic>>> getTagSuggestions({required String label});

  Future<void> addSearchableTag({required Tag tag});
}
