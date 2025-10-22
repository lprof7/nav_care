import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_offers_app/presentation/features/home/view/home_page.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_app_bar.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_destination.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_drawer.dart';
import 'package:nav_care_offers_app/presentation/shared/ui/shell/nav_shell_nav_bar.dart';

import '../viewmodel/nav_shell_cubit.dart';

class NavShellPage extends StatelessWidget {
  const NavShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavShellCubit(),
      child: BlocBuilder<NavShellCubit, NavShellState>(
        builder: (context, state) {
          final cubit = context.read<NavShellCubit>();
          final destinations = _buildDestinations(context);

          return Scaffold(
            appBar: const NavShellAppBar(
              notificationCount: 0,
            ),
            drawer: NavShellDrawer(
              selectedIndex: state.currentIndex,
              destinations: destinations,
              onDestinationSelected: cubit.setTab,
              onVerifyTap: () {},
              currentLocale: context.locale,
              supportedLocales: context.supportedLocales,
              onLocaleChanged: (locale) async {
                if (locale == context.locale) return;
                await context.setLocale(locale);
              },
            ),
            body: IndexedStack(
              index: state.currentIndex,
              children: destinations
                  .map<Widget>((destination) =>
                      (destination as NavShellDestination).content)
                  .toList(),
            ),
            bottomNavigationBar: NavShellNavBar(
              currentIndex: state.currentIndex,
              destinations: destinations,
              onTap: cubit.setTab,
            ),
          );
        },
      ),
    );
  }

  List<NavShellDestination> _buildDestinations(BuildContext context) {
    return [
      NavShellDestination(
        label: 'shell.nav_home'.tr(),
        icon: Icons.home_rounded,
        content: const HomePage(),
        badgeLabel: 'shell.badge_new'.tr(),
      ),
      NavShellDestination(
        label: 'shell.nav_services'.tr(),
        icon: Icons.medical_services_rounded,
        content: const _PlaceholderSection(titleKey: 'shell.nav_services'),
      ),
      NavShellDestination(
        label: 'shell.nav_hospitals'.tr(),
        icon: Icons.local_hospital_rounded,
        content: const _PlaceholderSection(titleKey: 'shell.nav_hospitals'),
      ),
      NavShellDestination(
        label: 'shell.nav_profile'.tr(),
        icon: Icons.person_rounded,
        content: const _PlaceholderSection(titleKey: 'shell.nav_profile'),
      ),
    ];
  }
}

class _PlaceholderSection extends StatelessWidget {
  final String titleKey;
  const _PlaceholderSection({required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        titleKey.tr(),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
