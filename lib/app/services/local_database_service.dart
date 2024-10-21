import 'dart:developer';

import 'package:cbl/cbl.dart';
import 'package:checklist/app/services/cbl_constants.dart';

const String databaseUrl =
    'wss://a2qoqndw59kr6hsm.apps.cloud.couchbase.com:4984/checklist-app-endpoint';

class LocalDatabaseService {
  Database? _database;

  Future<void> init() async {
    // Inicia ou cria um banco de dados
    _database ??= await Database.openAsync('checklist_db');
  }

  Future<void> startReplication({
    required String collectionName,
    required Function() onUpdated,
  }) async {
    log('Start sync');

    await init();

    final collection = await _database!.createCollection(
      collectionName,
      CblConstants.scope,
    );

    final config = ReplicatorConfiguration(
      target: UrlEndpoint(Uri.parse(CblConstants.publicConnectionUrl)),
      enableAutoPurge: true, // Remove documentos obsoletos localmente
      replicatorType: ReplicatorType.pushAndPull, // Bidirecional
      continuous: true, // Replicação contínua
      authenticator: BasicAuthenticator(
        username: CblConstants.userName,
        password: CblConstants.password,
      ),
    )..addCollection(
        collection,
        CollectionConfiguration(
          channels: [CblConstants.channel], // Usa canal "checklist"
        ),
      );

    final replicator = await Replicator.createAsync(config);

    replicator.addChangeListener((change) {
      if (change.status.error != null) {
        log('Erro de sincronização: ${change.status.error}');
      } else {
        log('Status da replicação: ${change.status.activity}');
        if (change.status.activity == ReplicatorActivityLevel.idle) {
          onUpdated();
        }
      }
    });

    await replicator.start();
  }

  Future<MutableDocument> add({
    required Map<String, dynamic> data,
    required String collectionName,
  }) async {
    await init();

    final collection = await _database!.createCollection(
      collectionName,
      CblConstants.scope,
    );
    final doc = MutableDocument(data);
    await collection.saveDocument(doc);
    return doc;
  }

  Future<List<Map<String, dynamic>>> fetch({
    String? filter,
    required String collectionName,
  }) async {
    await init();

    final collection = await _database?.createCollection(
      collectionName,
      CblConstants.scope,
    );

    if (collection == null) {
      throw Exception('Coleção $collectionName não encontrada.');
    }

    final query = await _database!.createQuery('''
      SELECT META().id, * FROM app_scope.$collectionName  ${filter != null ? 'WHERE $filter' : ''}
    ''');

    final result = await query.execute();
    final results = await result.allResults();
    return results
        .map((e) => {
              'id': e.string('id'),
              ...(e.toPlainMap()['checklist_items'] as Map<String, dynamic>)
            })
        .toList();
  }

  Future<void> updateItem({
    required String id,
    required String collectionName,
    required Map<String, dynamic> data,
  }) async {
    final collection = await _database!.createCollection(
      collectionName,
      CblConstants.scope,
    );
    final doc = await collection.document(id);

    if (doc != null) {
      final updatedDoc = doc.toMutable();
      data.forEach((key, value) {
        updatedDoc.setValue(
          value,
          key: key,
        );
      });
      await collection.saveDocument(updatedDoc);
    }
  }

  Future<void> deleteItem({
    required String id,
    required String collectionName,
  }) async {
    final collection =
        await _database!.createCollection(collectionName, CblConstants.scope);
    final doc = await collection.document(id);
    if (doc != null) {
      await collection.deleteDocument(doc);
    }
  }
}
