import 'package:checklist/app/entities/shopping_item_entity.dart';
import 'package:checklist/app/services/cbl_constants.dart';
import 'package:checklist/app/services/local_database_service.dart';

class ChecklistRepository {
  final LocalDatabaseService localDatabaseService;

  ChecklistRepository({
    required this.localDatabaseService,
  });

  Future<List<ShoppingItemEntity>> fetchAll() async {
    final result = await localDatabaseService.fetch(
      collectionName: CblConstants.collection,
    );
    final data = result.map(ShoppingItemEntity.fromMap).toList();
    return data;
  }

  Future<void> addItem(ShoppingItemEntity item) async {
    await localDatabaseService.add(
      data: item.toMap(),
      collectionName: CblConstants.collection,
    );
  }

  Future<void> updateItem({
    required String id,
    String? title,
    bool? isCompleted,
  }) async {
    await localDatabaseService.updateItem(
      id: id,
      collectionName: CblConstants.collection,
      data: {
        if (title != null) 'title': title,
        if (isCompleted != null) 'isCompleted': isCompleted,
      },
    );
  }

  Future<void> deleteItem(String id) async {
    await localDatabaseService.deleteItem(
      id: id,
      collectionName: CblConstants.collection,
    );
  }
}
