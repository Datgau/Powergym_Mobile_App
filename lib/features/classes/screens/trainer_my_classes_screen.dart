import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import '../../packages/services/gym_service_api.dart';

class TrainerMyClassesScreen extends StatefulWidget {
  const TrainerMyClassesScreen({super.key});

  @override
  State<TrainerMyClassesScreen> createState() =>
      _TrainerMyClassesScreenState();
}

class _TrainerMyClassesScreenState extends State<TrainerMyClassesScreen> {
  Future<List<_ServiceClass>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_ServiceClass>> _load() async {
    final regRes = await Api.private.get('/service-registrations/my-clients');
    final rawList = (regRes.data as Map<String, dynamic>)['data'];
    final registrations = rawList is List
        ? rawList.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    // Group by serviceId, collect students
    final Map<int, List<_Student>> studentsByService = {};
    final Map<int, String> serviceNames = {};
    for (final reg in registrations) {
      final sid = (reg['serviceId'] as num?)?.toInt();
      if (sid == null) continue;
      serviceNames[sid] = reg['serviceName'] as String? ?? 'Service';
      final user = reg['user'] as Map<String, dynamic>?;
      studentsByService.putIfAbsent(sid, () => []).add(_Student(
        name: reg['userName'] as String?
            ?? user?['fullName'] as String?
            ?? 'Student',
        email: reg['userEmail'] as String?
            ?? user?['email'] as String?
            ?? '',
        phone: user?['phoneNumber'] as String?,
        avatar: reg['userAvatar'] as String?
            ?? user?['avatar'] as String?,
      ));
    }

    if (studentsByService.isEmpty) return [];

    // Fetch full service details for images + duration
    final allServices = await GymServiceApi().getActiveServices();
    final serviceMap = {for (final s in allServices) s.id: s};

    return studentsByService.entries.map((e) {
      final sid = e.key;
      final students = e.value;
      final svc = serviceMap[sid];
      return _ServiceClass(
        serviceId: sid,
        serviceName: svc?.name ?? serviceNames[sid] ?? 'Service',
        images: svc?.images ?? [],
        duration: svc?.duration,
        students: students,
      );
    }).toList()
      ..sort((a, b) => b.students.length.compareTo(a.students.length));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: FutureBuilder<List<_ServiceClass>>(
        future: _future,
        builder: (context, snap) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 130,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: GradientContainer(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('My Classes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                              snap.connectionState == ConnectionState.done
                                  ? '${snap.data?.length ?? 0} class${(snap.data?.length ?? 0) != 1 ? 'es' : ''}'
                                  : 'Loading...',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white70),
                    onPressed: () => setState(() => _future = _load()),
                  ),
                ],
              ),

              if (snap.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
              else if (snap.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.error, size: 40),
                        const SizedBox(height: 8),
                        const Text('Could not load classes'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              setState(() => _future = _load()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if ((snap.data ?? []).isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🏋️', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 16),
                        Text('No classes assigned yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 8),
                        Text(
                          'Classes you are assigned to will appear here',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _ClassCard(cls: snap.data![i]),
                      childCount: snap.data!.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Models ─────────────────────────────────────────────────────────

class _Student {
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  const _Student(
      {required this.name,
      required this.email,
      this.phone,
      this.avatar});
}

class _ServiceClass {
  final int serviceId;
  final String serviceName;
  final List<String> images;
  final int? duration;
  final List<_Student> students;
  const _ServiceClass({
    required this.serviceId,
    required this.serviceName,
    required this.images,
    this.duration,
    required this.students,
  });
  int get studentCount => students.length;
}

// ── Class card ─────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  final _ServiceClass cls;
  const _ClassCard({required this.cls});

  @override
  Widget build(BuildContext context) {
    final hasImage = cls.images.isNotEmpty;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _StudentsSheet(cls: cls),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: hasImage
                  ? Image.network(
                      cls.images.first,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImgPlaceholder(),
                    )
                  : const _ImgPlaceholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cls.serviceName,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (cls.duration != null)
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: '${cls.duration} min',
                        color: const Color(0xFF8B5CF6),
                      ),
                    const SizedBox(height: 4),
                    _Chip(
                      icon: Icons.people_outline,
                      label:
                          '${cls.studentCount} student${cls.studentCount != 1 ? 's' : ''}',
                      color: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Students bottom sheet ──────────────────────────────────────────

class _StudentsSheet extends StatelessWidget {
  final _ServiceClass cls;
  const _StudentsSheet({required this.cls});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cls.serviceName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        Text(
                            '${cls.studentCount} student${cls.studentCount != 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: cls.students.isEmpty
                  ? const Center(
                      child: Text('No students',
                          style:
                              TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: cls.students.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _StudentTile(student: cls.students[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student tile ───────────────────────────────────────────────────

class _StudentTile extends StatelessWidget {
  final _Student student;
  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: student.avatar != null && student.avatar!.isNotEmpty
                ? Image.network(
                    student.avatar!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _InitialAvatar(name: student.name),
                  )
                : _InitialAvatar(name: student.name),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.email_outlined,
                      size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(student.email,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (student.phone != null &&
                    student.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    const Icon(Icons.phone_outlined,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(student.phone!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────

class _InitialAvatar extends StatelessWidget {
  final String name;
  const _InitialAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: AppTheme.primaryBlue.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue),
        ),
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  const _ImgPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.6),
            AppTheme.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center_rounded,
            color: Colors.white54, size: 32),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Flexible(
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
