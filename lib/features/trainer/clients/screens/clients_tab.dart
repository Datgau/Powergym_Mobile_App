import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../models/client_model.dart';
import '../providers/clients_provider.dart';

class ClientsTab extends StatefulWidget {
  const ClientsTab({super.key});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientsProvider>().load('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClientsProvider>();

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────
        GradientContainer(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Học viên', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: provider.setSearch,
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm học viên...',
                        hintStyle: TextStyle(color: const Color.fromARGB(255, 2, 2, 2).withOpacity(0.6)),
                        prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.status == ClientsStatus.error
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                        const SizedBox(height: 8),
                        Text(provider.error, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ClientsProvider>().load('');
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ))
                  : provider.clients.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('👥', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 12),
                              Text('Chưa có học viên nào', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.clients.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ClientCard(client: provider.clients[i]),
                        ),
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  const _ClientCard({required this.client});

  Widget _avatarFallback(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(gradient: AppTheme.brandGradient, shape: BoxShape.circle),
              child: client.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        client.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarFallback(client.fullName),
                      ),
                    )
                  : _avatarFallback(client.fullName),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.fitness_center, size: 12, color: AppTheme.primaryBlue),
                    const SizedBox(width: 4),
                    Flexible(child: Text(client.serviceName,
                        style: const TextStyle(fontSize: 14, color: AppTheme.primaryBlue, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis)),
                  ]),
                  Text(client.fullName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                   Text(client.email,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: client.isActive ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                client.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: client.isActive ? AppTheme.success : AppTheme.error),
              ),
            ),
          ],
        ),
      );
}
