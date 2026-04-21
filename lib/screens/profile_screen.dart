import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL')),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    border: Border.all(color: AppColors.secondary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.secondary, fontSize: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? '-',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 8),

                _InfoRow(
                  label: 'ID Pengguna',
                  value: user?.id.toString() ?? '-',
                ),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Nama Lengkap',
                  value: user?.fullName ?? '-',
                ),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Email',
                  value: user?.email ?? '-',
                ),
                const Divider(color: AppColors.cardBorder),

                const Spacer(),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (_) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('KELUAR'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
