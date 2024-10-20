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
    await Future.delayed(const Duration(milliseconds: 100));
    return List<ShoppingItemEntity>.from(_items);
  }

  Future<void> addItem(ShoppingItemEntity item) async {
    await localDatabaseService.add(
      data: item.toMap(),
      collectionName: collectionName,
    );
  }

  Future<ShoppingItemEntity> updateItem({
    required int id,
    String? title,
    bool? isCompleted,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        title: title,
        isCompleted: isCompleted,
      );

      return _items[index];
    } else {
      throw Exception();
    }
  }

  Future<void> deleteItem(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items.removeWhere((item) => item.id == id);
  }
}
