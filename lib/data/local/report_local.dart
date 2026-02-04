import 'dart:convert';

import 'package:kinondoni_openspace_app/core/storage/local_db.dart';
import 'package:kinondoni_openspace_app/model/Report.dart';
import 'package:sqflite/sqflite.dart';

class ReportLocal {
  Future<void> saveReport(Report report) async {
    final db = await LocalDb.getDb();

    await db.insert(
      'reports',
      {
        'id': report.id,
        'reportId': report.reportId,
        'description': report.description,
        'email': report.email,
        'phone': report.phone,
        'file': report.file, // local file path or URL
        'createdAt': report.createdAt.toIso8601String(),
        'latitude': report.latitude,
        'longitude': report.longitude,
        'spaceName': report.spaceName,
        'district': report.district,
        'street': report.street,
        'userId': report.userId,
        'userData': report.user?.toJsonString(),
        'status': report.status ?? 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Report>> getPendingReports() async {
    final db = await LocalDb.getDb();
    final maps = await db.query(
      'reports', 
      where: 'status = ?', 
      whereArgs: ['pending'],
      orderBy: 'createdAt DESC', // Ensure newest pending reports are first
    );
    return maps.map((e) => Report.fromJson({
      'id': e['id'],
      'reportId': e['reportId'],
      'description': e['description'],
      'email': e['email'],
      'phone': e['phone'],
      'file': e['file'],
      'createdAt': e['createdAt'],
      'latitude': e['latitude'],
      'longitude': e['longitude'],
      'spaceName': e['spaceName'],
      'district': e['district'],
      'street': e['street'],
      'userId': e['userId'],
      'user': e['userData'] != null ? jsonDecode(e['userData'] as String) : null,
      'status': e['status'],
    })).toList();
  }

  Future<void> updateReportStatus(String id, String status) async {
    final db = await LocalDb.getDb();
    await db.update('reports', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeReport(String id) async {
    final db = await LocalDb.getDb();
    await db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Report>> getAllReports({int? limit}) async {
    final db = await LocalDb.getDb();
    final maps = await db.query(
      'reports',
      where: 'status != ?',
      whereArgs: ['pending'],
      orderBy: 'createdAt DESC',
      limit: limit ?? 50,
    );
    return maps.map((e) => Report.fromJson({
      'id': e['id'],
      'reportId': e['reportId'],
      'description': e['description'],
      'email': e['email'],
      'phone': e['phone'],
      'file': e['file'],
      'createdAt': e['createdAt'],
      'latitude': e['latitude'],
      'longitude': e['longitude'],
      'spaceName': e['spaceName'],
      'district': e['district'],
      'street': e['street'],
      'userId': e['userId'],
      'user': e['userData'] != null ? jsonDecode(e['userData'] as String) : null,
      'status': e['status'],
    })).toList();
  }
}
