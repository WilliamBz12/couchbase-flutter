import 'package:cbl/cbl.dart';

class LocalDatabaseService {
  late final AsyncDatabase _database;

  Future<void> init() async {
    // Inicia ou cria um banco de dados
    _database = await Database.openAsync('database');
  }

  Future<MutableDocument> add({
    required Map<String, dynamic> data,
    required String collectionName,
  }) async {
    final collection = await _database.createCollection(collectionName);
    final doc = MutableDocument(data);
    await collection.saveDocument(doc);
    return doc;
  }

  Future<List<Map<String, dynamic>>> fetch({
    String? filter,
    required String collectionName,
  }) async {
    await _database.createCollection(collectionName);

    final query = await _database.createQuery('''
      SELECT * FROM $collectionName  ${filter != null ? 'WHERE $filter' : ''}
    ''');

    final result = await query.execute();
    final results = await result.allResults();
    return results.map((e) => e.toPlainMap()).toList();
  }
}
