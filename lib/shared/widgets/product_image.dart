import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  bool get _isNetworkUrl =>
      url != null &&
      (url!.startsWith('http://') || url!.startsWith('https://'));

  bool get _isAsset => url != null && url!.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholderColor = scheme.surfaceContainerHighest;

    Widget image;

    if (url == null || url!.isEmpty) {
      image = Container(
        color: placeholderColor,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.image,
          size: 32,
          color: scheme.onSurfaceVariant,
        ),
      );
    } else if (_isNetworkUrl) {
      image = CachedNetworkImage(
        imageUrl: url!,
        fit: fit,
        placeholder: (_, __) => Shimmer.fromColors(
          baseColor: placeholderColor,
          highlightColor: scheme.surface,
          child: Container(color: placeholderColor),
        ),
        errorWidget: (_, __, ___) => Container(
          color: placeholderColor,
          alignment: Alignment.center,
          child: FaIcon(
            FontAwesomeIcons.fileImage,
            size: 28,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    } else if (_isAsset) {
      image = Image.asset(
        url!,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          color: placeholderColor,
          alignment: Alignment.center,
          child: FaIcon(
            FontAwesomeIcons.fileImage,
            size: 28,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    } else {
      image = Container(
        color: placeholderColor,
        alignment: Alignment.center,
        child: FaIcon(
          FontAwesomeIcons.fileImage,
          size: 28,
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}