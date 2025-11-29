import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/invitation_card.dart';

class InvitationsTab extends StatelessWidget {
  final List<HospitalInvitation> invitations;
  final HospitalDetailStatus status;
  final VoidCallback onReload;

  const InvitationsTab({
    super.key,
    required this.invitations,
    required this.status,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    if (status == HospitalDetailStatus.loading && invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('hospitals.detail.invitations_empty'.tr()),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onReload,
              child: Text('hospitals.actions.retry'.tr()),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        final inv = invitations[index];
        final doctorName = inv.inviteeDoctor?.displayName.isNotEmpty == true
            ? inv.inviteeDoctor!.displayName
            : inv.inviteeDoctor?.userId ?? '—';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InvitationCard(
            doctorName: doctorName,
            status: inv.status,
            invitedBy: inv.invitedByName,
          ),
        );
      },
    );
  }
}
