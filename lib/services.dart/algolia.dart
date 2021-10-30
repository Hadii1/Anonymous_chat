import 'package:algolia/algolia.dart';
import 'package:anonymous_chat/interfaces/search_service_interface.dart';
import 'package:anonymous_chat/models/tag.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class AlgoliaSearch implements ISearchService {
  static final AlgoliaSearch _instance = AlgoliaSearch._internal();

  factory AlgoliaSearch() => _instance;

  AlgoliaSearch._internal();

  static late final Algolia _algolia;

  static Future<void> init() async {
    // String id = dotenv.env['ALGOLIA_APP_ID']!;
    // String apiKey = dotenv.env['ALGOLIA_API_KEY']!;

    _algolia = Algolia.init(
      applicationId: 'FCSC4ICBGI',
      apiKey: 'f067bed810fd56bd28212ae4ffb4846d',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTagSuggestions(
      {required String label}) async {
    AlgoliaQuerySnapshot a =
        await _algolia.index('Tags').query(label).getObjects();

    return a.hits.map((AlgoliaObjectSnapshot e) => e.data).toList();
  }

  @override
  Future<void> addSearchableTag({required Tag tag}) async =>
      await _algolia.instance.index('Tags').addObject(
        {
          'label': tag.label,
          'id': tag.id,
        },
      );
}
