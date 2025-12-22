import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/invitations/hospital_invitations_repository.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';
import 'package:nav_care_offers_app/presentation/features/hospitals/viewmodel/hospital_detail_cubit.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/cards/invitation_card.dart';

class InvitationsTab extends StatefulWidget {
  final List<HospitalInvitation> invitations;
  final HospitalDetailStatus status;
  final String baseUrl;
  final VoidCallback onReload;

  const InvitationsTab({
    super.key,
    required this.invitations,
    required this.status,
    required this.baseUrl,
    required this.onReload,
  });

  @override
  State<InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends State<InvitationsTab> {
  final Set<String> _cancellingIds = {};
  final Set<String> _cancelledIds = {};

  Future<void> _cancelInvitation(
    BuildContext context,
    HospitalInvitation invitation,
  ) async {
    if (_cancellingIds.contains(invitation.id)) return;
    setState(() => _cancellingIds.add(invitation.id));

    final result = await sl<HospitalInvitationsRepository>()
        .cancelInvitation(invitationId: invitation.id);

    if (!mounted) return;

    result.fold(
      onFailure: (failure) {
        setState(() => _cancellingIds.remove(invitation.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      onSuccess: (_) {
        setState(() {
          _cancellingIds.remove(invitation.id);
          _cancelledIds.add(invitation.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('hospitals.detail.invitation_cancel_success'.tr()),
          ),
        );
        widget.onReload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == HospitalDetailStatus.loading &&
        widget.invitations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.invitations.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => widget.onReload(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('hospitals.detail.invitations_empty'.tr()),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: widget.onReload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('hospitals.actions.retry'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => widget.onReload(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.invitations.length,
        itemBuilder: (context, index) {
          final inv = widget.invitations[index];
          final doctorName = inv.inviteeDoctor?.displayName.isNotEmpty == true
              ? inv.inviteeDoctor!.displayName
              : inv.inviteeDoctor?.userId ?? '?';
          final imageUrl =
              inv.inviteeDoctor?.avatarImage(baseUrl: widget.baseUrl);
          final effectiveStatus =
              _cancelledIds.contains(inv.id) ? 'cancelled' : inv.status;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InvitationCard(
              doctorName: doctorName,
              status: effectiveStatus,
              invitedBy: inv.invitedByName,
              imageUrl: imageUrl,
              onCancel: effectiveStatus == 'pending'
                  ? () => _cancelInvitation(context, inv)
                  : null,
              isCancelling: _cancellingIds.contains(inv.id),
            ),
          );
        },
      ),
    );
  }
}
