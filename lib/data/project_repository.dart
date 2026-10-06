import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Measurement Projects  Section 5.4
class Project {
  final String id;
  final String name;
  final String notes;
  final List<String> tags;
  final List<String> photoPaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    this.notes = '',
    this.tags = const [],
    this.photoPaths = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Project copyWith({
    String? name,
    String? notes,
    List<String>? tags,
    List<String>? photoPaths,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'notes': notes,
        'tags': tags,
        'photoPaths': photoPaths,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Project.fromJson(Map<String, dynamic> j) => Project(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        tags:
            (j['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                [],
        photoPaths: (j['photoPaths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class ProjectRepository {
  static const _key = 'projects_v1';
  final List<Project> _cache = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _cache.clear();
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List<dynamic>;
    for (final item in list) {
      try {
        _cache.add(Project.fromJson(Map<String, dynamic>.from(item as Map)));
      } catch (_) {}
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_cache.map((p) => p.toJson()).toList()),
    );
  }

  List<Project> get all => List.unmodifiable(_cache);

  Project? getById(String id) {
    try {
      return _cache.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Project p) async {
    final idx = _cache.indexWhere((e) => e.id == p.id);
    if (idx >= 0) {
      _cache[idx] = p;
    } else {
      _cache.insert(0, p);
    }
    await _persist();
  }

  Future<void> delete(String id) async {
    _cache.removeWhere((p) => p.id == id);
    await _persist();
  }

  Future<Project> create(String name) async {
    final p = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await save(p);
    return p;
  }
}
