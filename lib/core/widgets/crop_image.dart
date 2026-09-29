import 'package:flutter/material.dart';

import '../theme/build_context_x.dart';

/// Photo for a crop, keyed by catalog id — the harvest `Crops` and the
/// `FertilizerCrops` tables share keys where both have the crop. Crops the
/// app has no photo for (e.g. one added server-side later) fall back
/// to [fallbackIcon], so the catalog never has to wait on a UI release.
class CropImage extends StatelessWidget {
  const CropImage({
    super.key,
    required this.cropId,
    this.size = 48,
    this.borderRadius = 14,
    this.fallbackIcon = Icons.grass_rounded,
  }) : aspectRatio = null;

  /// Full-bleed variant for headers: fills the width at [aspectRatio].
  const CropImage.banner({
    super.key,
    required this.cropId,
    double this.aspectRatio = 16 / 9,
    this.borderRadius = 24,
    this.fallbackIcon = Icons.grass_rounded,
  }) : size = null;

  final String cropId;

  /// Square side length; `null` for [CropImage.banner].
  final double? size;
  final double borderRadius;

  /// Width / height for [CropImage.banner]; `null` for the square variant.
  final double? aspectRatio;

  /// Shown on a tinted tile when there's no photo for [cropId].
  final IconData fallbackIcon;

  static const _assets = <String, String>{
    'maize': 'assets/images/crops/maize.jpg',
    'rice-lowland': 'assets/images/crops/rice-lowland.jpg',
    'rice-upland': 'assets/images/crops/rice-upland.jpg',
    'cassava': 'assets/images/crops/cassava.jpg',
    'sweet-potato': 'assets/images/crops/sweet-potato.jpg',
    'potato': 'assets/images/crops/potato.jpg',
    'groundnut': 'assets/images/crops/groundnut.jpg',
    'cowpea': 'assets/images/crops/cowpea.jpg',
    'soybean': 'assets/images/crops/soybean.jpg',
    'sorghum': 'assets/images/crops/sorghum.jpg',
    'millet-pearl': 'assets/images/crops/millet-pearl.jpg',
    'wheat': 'assets/images/crops/wheat.jpg',
    'tomato': 'assets/images/crops/tomato.jpg',
    'pepper-chili': 'assets/images/crops/pepper-chili.jpg',
    'okra': 'assets/images/crops/okra.jpg',
    'cocoa': 'assets/images/crops/cocoa.jpg',
    'oil-palm': 'assets/images/crops/oil-palm.jpg',
  };

  /// The bundled asset path for [cropId], or `null` if there's no photo.
  static String? assetFor(String cropId) => _assets[cropId];

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(cropId);
    final radius = BorderRadius.circular(borderRadius);

    Widget content = asset == null
        ? _Fallback(icon: fallbackIcon, iconSize: size == null ? 48 : size! * 0.46)
        : Image.asset(
            asset,
            fit: BoxFit.cover,
            // Decode thumbnails near display size instead of at full resolution.
            cacheWidth: size == null ? null : (size! * MediaQuery.devicePixelRatioOf(context)).round(),
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => _Fallback(icon: fallbackIcon, iconSize: size == null ? 48 : size! * 0.46),
          );

    content = ClipRRect(borderRadius: radius, child: content);

    // Hairline edge so white-background product shots don't bleed into
    // light cards.
    content = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: context.agriColors.divider.withValues(alpha: 0.6), width: 0.5),
      ),
      child: content,
    );

    if (size != null) return SizedBox.square(dimension: size, child: content);
    return AspectRatio(aspectRatio: aspectRatio!, child: content);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.icon, required this.iconSize});

  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary.withValues(alpha: 0.28), colors.primary.withValues(alpha: 0.10)],
        ),
      ),
      child: Center(child: Icon(icon, color: colors.primary, size: iconSize)),
    );
  }
}
