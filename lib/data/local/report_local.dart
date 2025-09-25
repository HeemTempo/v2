// import 'dart:convert';
// import 'package:openspace_mobile_app/model/Report.dart';
// import 'package:sqflite/sqflite.dart';
// import '../../core/storage/local_db.dart';

// class ReportLocal {
//   Future<void> saveReports(List<Report> reports) async {
//     final db = await LocalDb.getDb();
//     final batch = db.batch();
//     for (var r in reports) {
//       batch.insert('reports', {
//         'id': r.id,
//         'reportId': r.reportId,
//         'description': r.description,
//         'email': r.email,
//         'file': r.file,
//         'createdAt': r.createdAt.toIso8601String(),
//         'latitude': r.latitude,
//         'longitude': r.longitude,
//         'spaceName': r.spaceName,
//         'userData': jsonEncode(r.user?.toJson()),
//         'status': r.status,
//       }, conflictAlgorithm: ConflictAlgorithm.replace);
//     }
//     await batch.commit(noResult: true);
//   }

//   Future<List<Report>> getReports() async {
//     final db = await LocalDb.getDb();
//     final maps = await db.query('reports');
//     return maps.map((e) {
//       final userMap = e['userData'] != null ? jsonDecode(e['userData'] as String) : null;
//       return Report(
//         id: e['id'] as String,
//         reportId: e['reportId'] as String,
//         description: e['description'] as String,
//         email: e['email'] as String?,
//         file: e['file'] as String?,
//         createdAt: DateTime.parse(e['createdAt'] as String),
//         latitude: e['latitude'] != null ? e['latitude'] as double : null,
//         longitude: e['longitude'] != null ? e['longitude'] as double : null,
//         spaceName: e['spaceName'] as String?,
//         user: userMap != null ? User.fromJson(userMap) : null,
//         status: e['status'] as String?,
//       );
//     }).toList();
//   }
// }
