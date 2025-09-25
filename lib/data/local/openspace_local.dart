import 'dart:convert';
import 'package:openspace_mobile_app/model/openspace.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/local_db.dart';

class OpenSpaceLocal {
  Future<void> saveOpenSpaces(List<OpenSpaceMarker> spaces) async {
    final db = await LocalDb.getDb();
    final batch = db.batch();
    for (var s in spaces) {
      batch.insert('open_spaces', {
        'id': s.id,
        'name': s.name,
        'district': s.district,
        'latitude': s.latitude,
        'longitude': s.longitude,
        'isActive': s.isActive ? 1 : 0,
        'status': s.status,
        'amenities': jsonEncode(s.amenities),
        'images': jsonEncode(s.images),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<OpenSpaceMarker>> getOpenSpaces() async {
    final db = await LocalDb.getDb();
    final maps = await db.query('open_spaces');
    return maps.map((e) => OpenSpaceMarker(
      id: e['id'] as String,
      name: e['name'] as String,
      district: e['district'] as String,
      latitude: e['latitude'] as double,
      longitude: e['longitude'] as double,
      isActive: (e['isActive'] as int) == 1,
      status: e['status'] as String,
      amenities: e['amenities'] != null ? List<String>.from(jsonDecode(e['amenities'] as String)) : [],
      images: e['images'] != null ? List<String>.from(jsonDecode(e['images'] as String)) : [],
    )).toList();
  }
}
