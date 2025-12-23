import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/presentation/features/invitations/viewmodel/doctor_invitations_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/doctor_invitation_card.dart';

class DoctorInvitationsPage extends StatelessWidget {
  const DoctorInvitationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DoctorInvitationsCubit>()..load(),
      child: const _DoctorInvitationsView(),
    );
  }
}

class _DoctorInvitationsView extends StatelessWidget {
  const _DoctorInvitationsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorInvitationsCubit, DoctorInvitationsState>(
      listenWhen: (prev, curr) =>
          prev.feedbackMessage != curr.feedbackMessage &&
          curr.feedbackMessage != null,
      listener: (context, state) {
        final message = state.feedbackMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.startsWith('doctor_invitations.')
                  ? message.tr()
                  : message,
            ),
          ),
        );
        context.read<DoctorInvitationsCubit>().clearFeedback();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('doctor_invitations.title'.tr()),
        ),
        body: BlocBuilder<DoctorInvitationsCubit, DoctorInvitationsState>(
          builder: (context, state) {
            if (state.status == DoctorInvitationsStatus.loading &&
                state.invitations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == DoctorInvitationsStatus.failure &&
                state.invitations.isEmpty) {
              return _InvitationsErrorView(
                message: state.errorMessage ??
                    'doctor_invitations.error_generic'.tr(),
                onRetry: () => context.read<DoctorInvitationsCubit>().load(),
              );
            }

            if (state.invitations.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<DoctorInvitationsCubit>().load(refresh: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Text('doctor_invitations.empty'.tr()),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<DoctorInvitationsCubit>().load(refresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.invitations.length,
                itemBuilder: (context, index) {
                  final invitation = state.invitations[index];
                  final decision = state
                      .respondingDecisions[invitation.id];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DoctorInvitationCard(
                      hospitalName: invitation.hospitalName,
                      status: invitation.status,
                      invitedBy: invitation.invitedByName,
                      imageUrl: invitation.hospitalImageUrl,
                      onAccept: () => context
                          .read<DoctorInvitationsCubit>()
                          .respond(invitation: invitation, decision: 'accepted'),
                      onDecline: () => context
                          .read<DoctorInvitationsCubit>()
                          .respond(invitation: invitation, decision: 'declined'),
                      isAccepting: decision == 'accepted',
                      isDeclining: decision == 'declined',
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InvitationsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _InvitationsErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('doctor_invitations.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
