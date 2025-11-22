import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentSuccessPage extends StatelessWidget {
  const AppointmentSuccessPage({
    super.key,
    required this.message,
    required this.onGoToAppointments,
  });

  final String message;
  final VoidCallback onGoToAppointments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/appointment/create_appointment.png',
                height: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              Text(
                'appointments.success.title'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F3958),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message.isNotEmpty
                    ? message
                    : 'appointments.success.subtitle'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E738E),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onGoToAppointments,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: const Color(0xFF2878F0),
                ),
                child: Text('appointments.success.go_to'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
