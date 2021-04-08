import 'package:algolia/algolia.dart';
import 'package:anonymous_chat/interfaces/iSearch_service.dart';
import 'package:anonymous_chat/models/tag.dart';

class AlgoliaSearch implements IAlgoliaSearch {
  static final AlgoliaSearch _instance = AlgoliaSearch._internal();

  factory AlgoliaSearch() => _instance;

  AlgoliaSearch._internal();

  static late Algolia algolia;

  static Future<void> init() async {
    algolia = Algolia.init(
      applicationId: 'FCSC4ICBGI',
      apiKey: 'f067bed810fd56bd28212ae4ffb4846d',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTagSuggestions(
      {required String label}) async {
    AlgoliaQuerySnapshot a =
        await algolia.index('TAGS').query(label).getObjects();

    return a.hits.map((AlgoliaObjectSnapshot e) => e.data).toList();
  }

  @override
  Future<void> addSearchableTag({required Tag tag}) async =>
      await algolia.instance.index('TAGS').addObject({
        'label': tag.label,
        'id': tag.id,
      });
}
