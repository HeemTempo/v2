import 'dart:convert';
import 'package:kinondoni_openspace_app/core/storage/local_db.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';

import 'package:sqflite/sqflite.dart';

class NotificationLocalDataSource {
  Future<void> saveNotification(ReportNotification notification) async {
    final db = await LocalDb.getDb();
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ReportNotification>> getNotifications() async {
    final db = await LocalDb.getDb();
    final maps = await db.query('notifications', orderBy: 'createdAt DESC');
    return maps.map((map) => ReportNotification.fromMap(map)).toList();
  }

  Future<void> updateNotification(ReportNotification notification) async {
    final db = await LocalDb.getDb();
    await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<void> deleteNotification(int id) async {
    final db = await LocalDb.getDb();
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> queueForSync(String action, String entity, Map<String, dynamic> data) async {
    final db = await LocalDb.getDb();
    await db.insert(
      'sync_queue',
      {
        'action': action,
        'entity': entity,
        'data': jsonEncode(data),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getQueuedActions() async {
    final db = await LocalDb.getDb();
    return await db.query('sync_queue', orderBy: 'createdAt ASC');
  }

  Future<void> clearQueuedAction(int id) async {
    final db = await LocalDb.getDb();
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllNotifications() async {
    final db = await LocalDb.getDb();
    await db.delete('notifications');
  }
}
