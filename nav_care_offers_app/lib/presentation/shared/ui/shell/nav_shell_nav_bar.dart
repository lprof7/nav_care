import 'package:flutter/material.dart';

import 'nav_shell_destination.dart';

class NavShellNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavShellDestination> destinations;

  const NavShellNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  State<NavShellNavBar> createState() => _NavShellNavBarState();
}

class _NavShellNavBarState extends State<NavShellNavBar> {
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _itemKeys;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.currentIndex;
    _itemKeys =
        List.generate(widget.destinations.length, (_) => GlobalKey());
    _scrollToSelected();
  }

  @override
  void didUpdateWidget(covariant NavShellNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations.length != widget.destinations.length) {
      _itemKeys =
          List.generate(widget.destinations.length, (_) => GlobalKey());
    }
    if (_lastIndex != widget.currentIndex) {
      _lastIndex = widget.currentIndex;
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentIndex < 0 ||
          widget.currentIndex >= _itemKeys.length) {
        return;
      }
      final context = _itemKeys[widget.currentIndex].currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        height: 68,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            List.generate(widget.destinations.length, (index) {
                          final destination = widget.destinations[index];
                          final isSelected = index == widget.currentIndex;
                          final textColor = isSelected
                              ? colorScheme.primary
                              : theme.textTheme.bodyMedium?.color ??
                                  colorScheme.secondary;

                          return Padding(
                            key: _itemKeys[index],
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                        .withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => widget.onTap(index),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      AnimatedScale(
                                        scale: isSelected ? 1.06 : 1,
                                        duration:
                                            const Duration(milliseconds: 220),
                                        curve: Curves.easeOutCubic,
                                        child: Icon(destination.icon,
                                            color: textColor),
                                      ),
                                      if (isSelected) const SizedBox(width: 4),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 180),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        transitionBuilder:
                                            (child, animation) {
                                          final slideTween = Tween<Offset>(
                                            begin: Offset(
                                              isRtl ? -0.12 : 0.12,
                                              0,
                                            ),
                                            end: Offset.zero,
                                          );
                                          return SlideTransition(
                                            position:
                                                slideTween.animate(animation),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: isSelected
                                            ? Padding(
                                                key: const ValueKey('label'),
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .only(start: 6),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  child: Text(
                                                    destination.label,
                                                    style: theme.textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      height: 1.0,
                                                    ),
                                                    strutStyle: StrutStyle(
                                                      fontSize: theme.textTheme
                                                          .bodyMedium
                                                          ?.fontSize,
                                                      height: 1.0,
                                                      forceStrutHeight: true,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(
                                                key: ValueKey('empty')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
