class FieldEntry {
  const FieldEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.missionId = 'northern-thailand',
    this.latitude,
    this.longitude,
    this.consentStatus = 'not_recorded',
    this.mediaPath,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String missionId;
  final double? latitude;
  final double? longitude;
  final String consentStatus;
  final String? mediaPath;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'created_at': createdAt.toIso8601String(),
        'mission_id': missionId,
        'latitude': latitude,
        'longitude': longitude,
        'consent_status': consentStatus,
        'media_path': mediaPath,
      };

  factory FieldEntry.fromMap(Map<String, Object?> map) => FieldEntry(
        id: map['id']! as String,
        title: map['title']! as String,
        body: map['body']! as String,
        createdAt: DateTime.parse(map['created_at']! as String),
        missionId: map['mission_id'] as String? ?? 'northern-thailand',
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        consentStatus: map['consent_status'] as String? ?? 'not_recorded',
        mediaPath: map['media_path'] as String?,
      );
}
