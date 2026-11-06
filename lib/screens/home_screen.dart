import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../ai/model_catalog.dart';
import '../ai/model_manager.dart';
import '../data/expedition_repository.dart';
import '../domain/field_entry.dart';
import '../domain/mission.dart';
import '../theme/expedition_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = ExpeditionRepository();
  final _modelManager = ModelManager();
  int _tabIndex = 0;
  List<Mission> _missions = [];
  List<FieldEntry> _allEntries = [];
  String _selectedMissionId = 'northern-thailand';
  String _modelStatus = 'Model not checked';
  String _downloadStatus = 'Choose a model to download';
  double _downloadProgress = 0;
  bool _downloading = false;
  ModelChoice _selectedModel = ModelCatalog.choices.first;

  Mission? get _selectedMission {
    for (final mission in _missions) {
      if (mission.id == _selectedMissionId) return mission;
    }
    return _missions.isEmpty ? null : _missions.first;
  }

  List<FieldEntry> get _missionEntries =>
      _allEntries.where((entry) => entry.missionId == _selectedMissionId).toList();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final results = await Future.wait([
        _repository.missions(),
        _repository.all(),
      ]);
      if (!mounted) return;
      setState(() {
        _missions = results[0] as List<Mission>;
        _allEntries = results[1] as List<FieldEntry>;
        if (_missions.isNotEmpty &&
            !_missions.any((mission) => mission.id == _selectedMissionId)) {
          _selectedMissionId = _missions.first.id;
        }
      });
    } catch (error) {
      if (mounted) _showMessage('Could not load the local archive: $error');
    }
  }

  Future<void> _createNote() async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final mission = _selectedMission;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New field record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Record title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyController,
                minLines: 4,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Observation / story',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mission: ${mission?.title ?? 'Unassigned'}',
                  style: const TextStyle(color: ExpeditionTheme.mutedInk),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save offline'),
          ),
        ],
      ),
    );

    if (saved == true && bodyController.text.trim().isNotEmpty) {
      await _repository.add(FieldEntry(
        id: '',
        title: titleController.text.trim().isEmpty
            ? 'Untitled field note'
            : titleController.text.trim(),
        body: bodyController.text.trim(),
        createdAt: DateTime.now(),
        missionId: _selectedMissionId,
      ));
      await _refresh();
      if (mounted) _showMessage('Field record saved on this device.');
    }

    titleController.dispose();
    bodyController.dispose();
  }

  Future<void> _createMission() async {
    final title = TextEditingController();
    final region = TextEditingController();
    final description = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create expedition'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Mission name')),
              const SizedBox(height: 10),
              TextField(controller: region, decoration: const InputDecoration(labelText: 'Region / country')),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Purpose and story'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Create')),
        ],
      ),
    );

    if (created == true && title.text.trim().isNotEmpty && region.text.trim().isNotEmpty) {
      final mission = Mission(
        id: 'mission-${DateTime.now().microsecondsSinceEpoch}',
        title: title.text.trim(),
        region: region.text.trim(),
        description: description.text.trim().isEmpty
            ? 'A new documentary expedition.'
            : description.text.trim(),
        status: 'Planned mission',
        accentValue: ExpeditionTheme.vermilion.value,
      );
      await _repository.addMission(mission);
      await _refresh();
      if (mounted) {
        setState(() => _selectedMissionId = mission.id);
        _showMessage('Expedition created.');
      }
    }

    title.dispose();
    region.dispose();
    description.dispose();
  }

  Future<void> _downloadSelectedModel() async {
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
      _downloadStatus = 'Downloading ${_selectedModel.name}…';
    });
    try {
      final file = await _modelManager.download(
        _selectedModel,
        onProgress: (received, total) {
          if (mounted && total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      if (mounted) {
        setState(() {
          _downloadStatus = 'Stored locally: ${file.split('/').last}';
          _modelStatus = _selectedModel.name;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _downloadStatus = 'Download failed: $error');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCaptureNotice(String kind) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$kind workflow'),
        content: Text(
          'This dashboard action is a planned capture entry point. '
          'The current build can save written field notes offline. '
          'Camera and audio capture need their own permission, file-storage '
          'and consent workflows before being treated as implemented.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _buildJournal(),
      _buildArchive(),
      _buildAiLab(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EXPEDITION AURÉLIO',
              style: TextStyle(fontSize: 11, letterSpacing: 1.7, fontWeight: FontWeight.w800),
            ),
            Text(
              _tabIndex == 0 ? 'FIELD COMMAND' : _tabTitle(_tabIndex),
              style: const TextStyle(fontSize: 10, color: ExpeditionTheme.mutedInk, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh local archive',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(child: pages[_tabIndex]),
      floatingActionButton: _tabIndex == 0 || _tabIndex == 1
          ? FloatingActionButton.extended(
              onPressed: _createNote,
              backgroundColor: ExpeditionTheme.vermilion,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit_note),
              label: const Text('Field note'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Archive'),
          NavigationDestination(icon: Icon(Icons.memory_outlined), selectedIcon: Icon(Icons.memory), label: 'AI Lab'),
        ],
      ),
    );
  }

  String _tabTitle(int index) => const ['FIELD COMMAND', 'FIELD JOURNAL', 'LIVING MEMORY', 'AI LAB'][index];

  Widget _buildDashboard() {
    final mission = _selectedMission;
    final entries = _missionEntries;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
        children: [
          _MissionHero(
            mission: mission,
            missions: _missions,
            selectedMissionId: _selectedMissionId,
            onMissionChanged: (id) => setState(() => _selectedMissionId = id),
            onCreateMission: _createMission,
          ),
          const SizedBox(height: 18),
          const _SectionHeading(title: 'FIELD OPERATIONS', eyebrow: 'CAPTURE AND DOCUMENT'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.48,
            children: [
              _ActionCard(
                icon: Icons.edit_note_rounded,
                title: 'Field note',
                detail: 'Write an observation',
                onTap: _createNote,
              ),
              _ActionCard(
                icon: Icons.mic_none_rounded,
                title: 'Interview',
                detail: 'Audio capture workflow',
                onTap: () => _showCaptureNotice('Interview'),
              ),
              _ActionCard(
                icon: Icons.photo_camera_outlined,
                title: 'Media capture',
                detail: 'Photo and video',
                onTap: () => _showCaptureNotice('Media capture'),
              ),
              _ActionCard(
                icon: Icons.travel_explore_rounded,
                title: 'Research',
                detail: 'Questions and sources',
                onTap: () => setState(() => _tabIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: 'MISSION INTELLIGENCE',
            eyebrow: 'LOCAL ARCHIVE OVERVIEW',
            trailing: TextButton(
              onPressed: () => setState(() => _tabIndex = 2),
              child: const Text('Open archive'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatCard(value: '${entries.length}', label: 'FIELD NOTES', icon: Icons.notes_outlined)),
              const SizedBox(width: 9),
              Expanded(child: _StatCard(value: '${_missions.length}', label: 'MISSIONS', icon: Icons.flag_outlined)),
              const SizedBox(width: 9),
              Expanded(child: _StatCard(value: _modelStatus == 'Model not checked' ? '—' : 'OK', label: 'LOCAL AI', icon: Icons.memory)),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeading(
            title: 'RECENT DISCOVERIES',
            eyebrow: mission?.region.toUpperCase() ?? 'SELECT A MISSION',
            trailing: TextButton(
              onPressed: () => setState(() => _tabIndex = 1),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const _EmptyCard(
              icon: Icons.auto_stories_outlined,
              title: 'The field journal is waiting.',
              detail: 'Create your first observation. It will be saved locally on this device.',
            )
          else
            ...entries.take(4).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _EntryTile(entry: entry),
            )),
          const SizedBox(height: 16),
          _AiStatusCard(
            status: _modelStatus,
            onTap: () => setState(() => _tabIndex = 3),
          ),
          const SizedBox(height: 16),
          const _PrivacyNote(),
        ],
      ),
    );
  }

  Widget _buildJournal() {
    final entries = _missionEntries;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
      children: [
        _MissionSelector(
          missions: _missions,
          selectedMissionId: _selectedMissionId,
          onChanged: (id) => setState(() => _selectedMissionId = id),
        ),
        const SizedBox(height: 18),
        const _SectionHeading(title: 'FIELD JOURNAL', eyebrow: 'ORIGINAL OBSERVATIONS'),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          const _EmptyCard(
            icon: Icons.menu_book_outlined,
            title: 'No notes in this mission yet.',
            detail: 'Use Field note to record the first observation.',
          )
        else
          ...entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EntryTile(entry: entry, expanded: true),
          )),
      ],
    );
  }

  Widget _buildArchive() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        const _SectionHeading(title: 'LIVING MEMORY', eyebrow: 'ALL EXPEDITIONS'),
        const SizedBox(height: 8),
        const Text(
          'A shared archive across missions. Original records stay distinct from AI-generated summaries and edited media.',
          style: TextStyle(color: ExpeditionTheme.mutedInk, height: 1.45),
        ),
        const SizedBox(height: 18),
        ..._missions.map((mission) {
          final count = _allEntries.where((entry) => entry.missionId == mission.id).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: mission.accentColor.withOpacity(0.14),
                  foregroundColor: mission.accentColor,
                  child: const Icon(Icons.explore_outlined),
                ),
                title: Text(mission.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${mission.region} · $count field notes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() {
                    _selectedMissionId = mission.id;
                    _tabIndex = 1;
                  });
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _createMission,
          icon: const Icon(Icons.add),
          label: const Text('Create expedition'),
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'ALL FIELD RECORDS', eyebrow: 'SOURCE MATERIAL'),
        const SizedBox(height: 10),
        if (_allEntries.isEmpty)
          const _EmptyCard(
            icon: Icons.archive_outlined,
            title: 'Archive is empty.',
            detail: 'Saved field notes will appear here across all missions.',
          )
        else
          ..._allEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: _EntryTile(entry: entry, showMission: true),
          )),
      ],
    );
  }

  Widget _buildAiLab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ExpeditionTheme.charcoal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.memory, color: Color(0xFFE5B9A7), size: 30),
              SizedBox(height: 14),
              Text('LOCAL INTELLIGENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              SizedBox(height: 7),
              Text(
                'Download a supported model once, then use compatible local inference without a network connection.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'MODEL LIBRARY', eyebrow: 'ON-DEVICE RUNTIME'),
        const SizedBox(height: 10),
        Text(_downloadStatus, style: const TextStyle(color: ExpeditionTheme.mutedInk)),
        if (_downloading) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(value: _downloadProgress == 0 ? null : _downloadProgress),
          const SizedBox(height: 4),
          Text('${(_downloadProgress * 100).toStringAsFixed(0)}%', textAlign: TextAlign.right),
        ],
        const SizedBox(height: 12),
        ...ModelCatalog.choices.map((model) => Card(
          child: RadioListTile<ModelChoice>(
            value: model,
            groupValue: _selectedModel,
            onChanged: _downloading ? null : (value) {
              if (value != null) setState(() => _selectedModel = value);
            },
            title: Text(model.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(model.role),
            activeColor: ExpeditionTheme.vermilion,
          ),
        )),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _downloading ? null : _downloadSelectedModel,
          icon: const Icon(Icons.download_outlined),
          label: Text(_downloading ? 'Downloading model…' : 'Download ${_selectedModel.name}'),
          style: FilledButton.styleFrom(
            backgroundColor: ExpeditionTheme.vermilion,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 16),
        const _PrivacyNote(),
        const SizedBox(height: 14),
        const Text(
          'Note: model download is separate from model loading and chat inference. The local inference screen must be connected and device-tested before this area can be described as a complete AI assistant.',
          style: TextStyle(fontSize: 12, color: ExpeditionTheme.mutedInk, height: 1.4),
        ),
      ],
    );
  }
}

class _MissionHero extends StatelessWidget {
  const _MissionHero({
    required this.mission,
    required this.missions,
    required this.selectedMissionId,
    required this.onMissionChanged,
    required this.onCreateMission,
  });

  final Mission? mission;
  final List<Mission> missions;
  final String selectedMissionId;
  final ValueChanged<String> onMissionChanged;
  final VoidCallback onCreateMission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ExpeditionTheme.charcoal,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6A5144)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Color(0xFFE7B9A4), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'THE WORLD IS THE ARCHIVE',
                  style: TextStyle(color: Color(0xFFE7B9A4), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF607D65)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text('OFFLINE FIRST', style: TextStyle(color: Color(0xFFB9D0B8), fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            mission?.title ?? 'Create your first expedition',
            style: const TextStyle(color: Color(0xFFFFF7E9), fontSize: 27, height: 1.05, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            mission?.region ?? 'Your documentary workspace',
            style: const TextStyle(color: Color(0xFFE2C8B5), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            mission?.description ?? 'Create a mission to organize field notes and discoveries.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: mission?.id,
                  isExpanded: true,
                  dropdownColor: ExpeditionTheme.paper,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF37332D),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFF65584B)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  iconEnabledColor: Colors.white,
                  items: missions.map((item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(item.title, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (id) {
                    if (id != null) onMissionChanged(id);
                  },
                ),
              ),
              const SizedBox(width: 9),
              IconButton.filled(
                tooltip: 'Create expedition',
                onPressed: onCreateMission,
                style: IconButton.styleFrom(
                  backgroundColor: ExpeditionTheme.vermilion,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(mission?.status.toUpperCase() ?? 'READY TO BEGIN', style: const TextStyle(color: Color(0xFFD6B6A0), fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MissionSelector extends StatelessWidget {
  const _MissionSelector({required this.missions, required this.selectedMissionId, required this.onChanged});
  final List<Mission> missions;
  final String selectedMissionId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: missions.any((mission) => mission.id == selectedMissionId) ? selectedMissionId : null,
    decoration: const InputDecoration(labelText: 'Current expedition', prefixIcon: Icon(Icons.flag_outlined)),
    items: missions.map((mission) => DropdownMenuItem(value: mission.id, child: Text('${mission.title} · ${mission.region}'))).toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.eyebrow, this.trailing});
  final String title;
  final String eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eyebrow, style: const TextStyle(color: ExpeditionTheme.mutedInk, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(title, style: const TextStyle(color: ExpeditionTheme.ink, fontSize: 15, letterSpacing: 0.6, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      if (trailing != null) trailing!,
    ],
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.detail, required this.onTap});
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: ExpeditionTheme.paper,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: ExpeditionTheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: ExpeditionTheme.vermilion, size: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: ExpeditionTheme.ink)),
                const SizedBox(height: 2),
                Text(detail, style: const TextStyle(fontSize: 10, color: ExpeditionTheme.mutedInk)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: ExpeditionTheme.vermilion),
          const SizedBox(height: 9),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: ExpeditionTheme.ink)),
          Text(label, style: const TextStyle(fontSize: 8, letterSpacing: 0.7, color: ExpeditionTheme.mutedInk, fontWeight: FontWeight.w800)),
        ],
      ),
    ),
  );
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, this.expanded = false, this.showMission = false});
  final FieldEntry entry;
  final bool expanded;
  final bool showMission;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFF0E1D5),
        foregroundColor: ExpeditionTheme.vermilion,
        child: Icon(Icons.article_outlined),
      ),
      title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w800, color: ExpeditionTheme.ink)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(entry.body, maxLines: expanded ? 5 : 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Text(
            '${DateFormat('d MMM yyyy · HH:mm').format(entry.createdAt)}${showMission ? ' · ${entry.missionId}' : ''}',
            style: const TextStyle(fontSize: 10, color: ExpeditionTheme.mutedInk),
          ),
        ],
      ),
      isThreeLine: expanded,
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: ExpeditionTheme.vermilion, size: 30),
          const SizedBox(height: 9),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(detail, textAlign: TextAlign.center, style: const TextStyle(color: ExpeditionTheme.mutedInk, height: 1.4, fontSize: 12)),
        ],
      ),
    ),
  );
}

class _AiStatusCard extends StatelessWidget {
  const _AiStatusCard({required this.status, required this.onTap});
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFFF0E1D5), borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.memory, color: ExpeditionTheme.vermilion),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI LABORATORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(status, style: const TextStyle(color: ExpeditionTheme.mutedInk, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    ),
  );
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFE8E2D3),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: ExpeditionTheme.line),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.shield_outlined, size: 18, color: ExpeditionTheme.olive),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'OFFLINE FIRST · Field notes are stored locally. Cloud sync and external sharing should remain explicit, optional actions.',
            style: TextStyle(color: ExpeditionTheme.mutedInk, fontSize: 10, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
