import 'dart:convert';

import 'package:openspace_mobile_app/core/storage/local_db.dart';
import 'package:openspace_mobile_app/model/Report.dart';
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
        'file': report.file, // local file path or URL
        'createdAt': report.createdAt.toIso8601String(),
        'latitude': report.latitude,
        'longitude': report.longitude,
        'spaceName': report.spaceName,
        'userData': report.user?.toJsonString(),
        'status': report.status ?? 'pending',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Report>> getPendingReports() async {
    final db = await LocalDb.getDb();
    final maps = await db.query('reports', where: 'status = ?', whereArgs: ['pending']);
    return maps.map((e) => Report.fromJson({
      'id': e['id'],
      'reportId': e['reportId'],
      'description': e['description'],
      'email': e['email'],
      'file': e['file'],
      'createdAt': e['createdAt'],
      'latitude': e['latitude'],
      'longitude': e['longitude'],
      'spaceName': e['spaceName'],
      'user': e['userData'] != null ? jsonDecode(e['userData'] as String) : null,
      'status': e['status'],
    })).toList();
  }

  Future<void> updateReportStatus(String id, String status) async {
    final db = await LocalDb.getDb();
    await db.update('reports', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Report>> getAllReports() async {
    final db = await LocalDb.getDb();
    final maps = await db.query('reports');
    return maps.map((e) => Report.fromJson({
      'id': e['id'],
      'reportId': e['reportId'],
      'description': e['description'],
      'email': e['email'],
      'file': e['file'],
      'createdAt': e['createdAt'],
      'latitude': e['latitude'],
      'longitude': e['longitude'],
      'spaceName': e['spaceName'],
      'user': e['userData'] != null ? jsonDecode(e['userData'] as String) : null,
      'status': e['status'],
    })).toList();
  }
}
