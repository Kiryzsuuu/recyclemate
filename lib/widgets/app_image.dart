import 'dart:convert';
import 'package:flutter/material.dart';

/// Menampilkan gambar dari base64 string atau URL biasa.
class AppImage extends StatelessWidget {
  final String src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty) return placeholder ?? _fallback();

    if (src.startsWith('data:image')) {
      try {
        final base64Str = src.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder ?? _fallback(),
        );
      } catch (_) {
        return placeholder ?? _fallback();
      }
    }

    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => placeholder ?? _fallback(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _fallback() => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      );
}
