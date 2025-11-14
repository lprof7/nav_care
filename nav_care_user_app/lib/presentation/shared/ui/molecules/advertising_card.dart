import 'package:flutter/material.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/advertising/models/advertising_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvertisingCard extends StatelessWidget {
  final Advertising advertising;
  final double aspectRatio;
  final double borderRadius;

  const AdvertisingCard({
    super.key,
    required this.advertising,
    this.aspectRatio = 64 / 27,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final imageUrl = advertising.image.startsWith('http')
        ? advertising.image
        : '$baseUrl/${advertising.image}';
    print(imageUrl);

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: () {
          _launchURL(advertising.link);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
