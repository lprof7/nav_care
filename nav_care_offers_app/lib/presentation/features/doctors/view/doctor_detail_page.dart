import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/doctors/doctors_repository.dart';
import 'package:nav_care_offers_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_offers_app/data/invitations/models/hospital_invitation.dart';

class DoctorDetailPage extends StatefulWidget {
  final String doctorId;
  final DoctorModel? initial;
  final String? hospitalId;
  final List<DoctorModel>? hospitalDoctors;
  final List<HospitalInvitation>? invitations;

  const DoctorDetailPage({
    super.key,
    required this.doctorId,
    this.initial,
    this.hospitalId,
    this.hospitalDoctors,
    this.invitations,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Future<DoctorModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DoctorModel> _load() async {
    if (widget.initial != null) return widget.initial!;
    final result = await sl<DoctorsRepository>().getDoctorById(widget.doctorId);
    return result.fold(
      onFailure: (failure) => throw Exception(failure.message),
      onSuccess: (doctor) => doctor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = _load();
          });
          await _future;
        },
        child: FutureBuilder<DoctorModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorView(
                message: 'hospitals.detail.doctors_empty'.tr(),
                onRetry: () => setState(() {
                  _future = _load();
                }),
              );
            }

            final doctor = snapshot.data!;
            final locale = context.locale.languageCode;
            final bio = doctor.bioForLocale(locale);
            final avatar =
                doctor.avatarImage(baseUrl: baseUrl) ?? doctor.coverImage(baseUrl: baseUrl);
            final cover = avatar ?? doctor.coverImage(baseUrl: baseUrl);
            final isMember = (widget.hospitalDoctors ?? [])
                .any((d) => d.id == doctor.id || d.userId == doctor.userId);
            HospitalInvitation? invitation;
            for (final inv in widget.invitations ?? []) {
              if (inv.inviteeDoctor?.id == doctor.id) {
                invitation = inv;
                break;
              }
            }
            final bool canSendInvitation =
                !isMember && (invitation == null || invitation.status == 'rejected');

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  title: Text(
                    doctor.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _HeroImage(imageUrl: cover),
                      _SummaryCard(
                        doctor: doctor,
                        avatarUrl: avatar,
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (widget.hospitalId != null && !isMember)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FilledButton(
                              onPressed: canSendInvitation
                                  ? () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'hospitals.detail.invitation_send'.tr(),
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Text(canSendInvitation
                                  ? 'hospitals.detail.invitation_send'.tr()
                                  : 'hospitals.detail.invitation_sent'.tr()),
                            ),
                          ),
                        _Section(
                          icon: Icons.info_rounded,
                          title: 'hospitals.detail.about'.tr(),
                          child: Text(
                            bio.isNotEmpty
                                ? bio
                                : 'hospitals.detail.no_description'.tr(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _Section(
                          icon: Icons.contact_phone_rounded,
                          title: 'hospitals.detail.contact'.tr(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                icon: Icons.email_rounded,
                                label: doctor.email ?? '--',
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                icon: Icons.phone_rounded,
                                label: doctor.phone ?? '--',
                              ),
                            ],
                          ),
                        ),
                        if (doctor.affiliations.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _Section(
                            icon: Icons.business_center_rounded,
                            title: 'hospitals.detail.stats.clinics'.tr(),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: doctor.affiliations
                                  .map(
                                    (aff) => Chip(
                                      label: Text(aff),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imageUrl;
  const _HeroImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person_rounded, size: 48),
                  ),
                )
              : Container(
                  color: theme.colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_rounded, size: 48),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final DoctorModel doctor;
  final String? avatarUrl;

  const _SummaryCard({
    required this.doctor,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage:
                    (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
                onBackgroundImageError: (_, __) {},
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_rounded, size: 30)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating > 0
                              ? doctor.rating.toStringAsFixed(1)
                              : '--',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.isNotEmpty ? label : '--',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 46, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('service_offerings.list.retry'.tr()),
          ),
        ],
      ),
    );
  }
}
