import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/doctors/models/doctor_model.dart';
import 'package:nav_care_user_app/presentation/features/doctors/view/doctor_detail_page.dart';

class NavcareDoctorsPage extends StatelessWidget {
  final List<DoctorModel> doctors;
  final String titleKey;

  const NavcareDoctorsPage({
    super.key,
    required this.doctors,
    this.titleKey = 'home.doctors_choice.title',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(titleKey.tr()),
      ),
      body: doctors.isEmpty
          ? Center(
              child: Text(
                'home.doctors_choice.empty'.tr(),
                style: textTheme.bodyLarge,
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                int crossAxisCount = 1;
                double childAspectRatio = 0.92;

                if (maxWidth >= 1200) {
                  crossAxisCount = 4;
                  childAspectRatio = 0.78;
                } else if (maxWidth >= 900) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.8;
                } else if (maxWidth >= 600) {
                  crossAxisCount = 2;
                  childAspectRatio = 0.75;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    final bio =
                        doctor.bioForLocale(context.locale.languageCode);
                    final baseUrl = sl<AppConfig>().api.baseUrl;
                    final coverPath = doctor.avatarImage(baseUrl: baseUrl) ??
                        doctor.coverImage(baseUrl: baseUrl);
                    final avatarPath = doctor.avatarImage(baseUrl: baseUrl);
                    final displayName = doctor.displayName.trim().isNotEmpty
                        ? doctor.displayName
                        : doctor.specialty;
                    final specialtyLabel = doctor.specialty.trim().isNotEmpty
                        ? doctor.specialty
                        : 'home.doctors_choice.title'.tr();
                    final colorScheme = Theme.of(context).colorScheme;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailPage(
                                doctorId: doctor.id,
                                initial: doctor,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _DoctorCover(path: coverPath),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.15),
                                          Colors.black.withOpacity(0.45),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (doctor.rating > 0)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              doctor.rating.toStringAsFixed(1),
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (avatarPath != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child:
                                    _DoctorAvatar(path: avatarPath, radius: 30),
                              )
                            else
                              const SizedBox(height: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      specialtyLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Text(
                                        bio,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                    if (doctor.email != null &&
                                        doctor.email!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              doctor.email!,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _DoctorCover extends StatelessWidget {
  final String? path;

  const _DoctorCover({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget placeholder(
        {IconData icon = Icons.person_rounded, double size = 48}) {
      return Container(
        color: theme.colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(icon, size: size),
      );
    }

    final imagePath = path;
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder();
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder(icon: Icons.person_outline_rounded, size: 40);
        },
        errorBuilder: (context, error, stackTrace) =>
            placeholder(icon: Icons.image_not_supported_rounded, size: 36),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          placeholder(icon: Icons.image_not_supported_rounded, size: 36),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String path;
  final double radius;

  const _DoctorAvatar({required this.path, required this.radius});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget fallback() {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_rounded,
          size: radius,
        ),
      );
    }

    if (path.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            path,
            width: radius * 2 - 6,
            height: radius * 2 - 6,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback(),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.asset(
          path,
          width: radius * 2 - 6,
          height: radius * 2 - 6,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback(),
        ),
      ),
    );
  }
}
