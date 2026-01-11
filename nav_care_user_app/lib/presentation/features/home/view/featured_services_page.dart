import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/services/services_repository.dart';
import 'package:nav_care_user_app/presentation/features/service_offerings/view/service_offerings_by_service_page.dart';

import '../../../../data/services/models/service_model.dart';

class FeaturedServicesPage extends StatefulWidget {
  final List<ServiceModel> services;

  const FeaturedServicesPage({super.key, required this.services});

  @override
  State<FeaturedServicesPage> createState() => _FeaturedServicesPageState();
}

class _FeaturedServicesPageState extends State<FeaturedServicesPage> {
  final ScrollController _scrollController = ScrollController();
  final List<ServiceModel> _services = [];
  bool _isLoading = false;
  bool _hasNext = true;
  int _page = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _services.addAll(widget.services);
    _scrollController.addListener(_onScroll);
    if (_services.isEmpty) {
      _loadPage(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasNext) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.85) {
      _loadPage();
    }
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (reset) {
      _page = 1;
      _services.clear();
      _hasNext = true;
    }

    try {
      final repository = sl<ServicesRepository>();
      final result = await repository.getServices(page: _page, limit: 20);
      setState(() {
        _services.addAll(result.items);
        _hasNext = _page < result.meta!.totalPages;
        _page += 1;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'home.featured_services.error'.tr();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('home.featured_services.title'.tr()),
      ),
      body: _services.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? Center(
                  child: Text(
                    _errorMessage ?? 'home.featured_services.empty'.tr(),
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPage(reset: true),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: _services.length + (_hasNext ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _services.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final service = _services[index];
                      final name =
                          service.nameForLanguage(context.locale.languageCode);
                      final imagePath = service.imageUrl(baseUrl);

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _openService(context, service),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: imagePath == null
                                    ? Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported_rounded,
                                        ),
                                      )
                                    : Image.network(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.image_not_supported_rounded,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _openService(BuildContext context, ServiceModel service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceOfferingsByServicePage(service: service),
      ),
    );
  }
}
