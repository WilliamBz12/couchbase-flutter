import 'package:checklist/app/entities/shopping_item_entity.dart';
import 'package:checklist/app/services/local_database_service.dart';

class ChecklistRepository {
  final List<ShoppingItemEntity> _items = [];

  final LocalDatabaseService localDatabaseService;

  static const collectionName = 'checklist';

  ChecklistRepository({
    required this.localDatabaseService,
  });

  Future<List<ShoppingItemEntity>> fetchAll() async {
    final result = await localDatabaseService.fetch(
      collectionName: collectionName,
    );
    final data = result.map(ShoppingItemEntity.fromMap).toList();
    return data;
  }

  Future<void> addItem(ShoppingItemEntity item) async {
    await localDatabaseService.add(
      data: item.toMap(),
      collectionName: collectionName,
    );
  }

  Future<void> updateItem({
    required String id,
    String? title,
    bool? isCompleted,
  }) async {
    await localDatabaseService.updateItem(
      id: id,
      collectionName: collectionName,
      data: {
        if (title != null) 'title': title,
        if (isCompleted != null) 'isCompleted': isCompleted,
      },
    );
  }

  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((item) => item.id == id);
  }
}
