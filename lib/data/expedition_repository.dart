import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../domain/field_entry.dart';
import '../domain/mission.dart';

class ExpeditionRepository {
  static Database? _database;
  static const _uuid = Uuid();

  Future<Database> get database async {
    // Reuse one database connection for the app process.
    if (_database != null) return _database!;

    final dir = await getApplicationDocumentsDirectory();
    _database = await openDatabase(
      path.join(dir.path, 'expedition_archive.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE missions (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            region TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            accent_value INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE field_entries (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL,
            mission_id TEXT NOT NULL DEFAULT 'northern-thailand',
            latitude REAL,
            longitude REAL,
            consent_status TEXT NOT NULL,
            media_path TEXT
          )
        ''');

        await _seedMissions(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Preserve existing version-1 field notes while adding mission support.
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE missions (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              region TEXT NOT NULL,
              description TEXT NOT NULL,
              status TEXT NOT NULL,
              accent_value INTEGER NOT NULL
            )
          ''');
          await db.execute(
            "ALTER TABLE field_entries ADD COLUMN mission_id TEXT NOT NULL DEFAULT 'northern-thailand'",
          );
          await _seedMissions(db);
        }
      },
    );
    return _database!;
  }

  Future<void> _seedMissions(DatabaseExecutor db) async {
    // Seed a few editable starting missions; they are not claimed as real trips.
    final missions = <Mission>[
      const Mission(
        id: 'northern-thailand',
        title: 'Living Cultures',
        region: 'Northern Thailand',
        description: 'Document crafts, music, people and living traditions.',
        status: 'Active mission',
        accentValue: 0xFFB94735,
      ),
      const Mission(
        id: 'brazilian-cordel',
        title: 'Cordel Memory',
        region: 'Brazil',
        description: 'Explore xilogravura, oral histories and popular culture.',
        status: 'Planned mission',
        accentValue: 0xFF7C7950,
      ),
      const Mission(
        id: 'europe-energy',
        title: 'Energy Frontiers',
        region: 'Europe',
        description: 'Document renewable-energy work, people and places.',
        status: 'Planned mission',
        accentValue: 0xFF657B78,
      ),
    ];

    for (final mission in missions) {
      await db.insert(
        'missions',
        mission.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<List<Mission>> missions() async {
    final db = await database;
    final rows = await db.query('missions', orderBy: 'rowid ASC');
    return rows.map(Mission.fromMap).toList();
  }

  Future<void> addMission(Mission mission) async {
    final db = await database;
    await db.insert('missions', mission.toMap());
  }

  Future<void> add(FieldEntry entry) async {
    final db = await database;
    // Generate an immutable record ID before inserting the field note.
    final record = FieldEntry(
      id: _uuid.v4(),
      title: entry.title,
      body: entry.body,
      createdAt: entry.createdAt,
      missionId: entry.missionId,
      latitude: entry.latitude,
      longitude: entry.longitude,
      consentStatus: entry.consentStatus,
      mediaPath: entry.mediaPath,
    );
    await db.insert('field_entries', record.toMap());
  }

  Future<List<FieldEntry>> all() async {
    final db = await database;
    final rows = await db.query('field_entries', orderBy: 'created_at DESC');
    return rows.map(FieldEntry.fromMap).toList();
  }

  Future<List<FieldEntry>> entriesForMission(String missionId) async {
    final db = await database;
    final rows = await db.query(
      'field_entries',
      where: 'mission_id = ?',
      whereArgs: [missionId],
      orderBy: 'created_at DESC',
    );
    return rows.map(FieldEntry.fromMap).toList();
  }
}
