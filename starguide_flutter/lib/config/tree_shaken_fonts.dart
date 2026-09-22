import 'package:flutter/widgets.dart';
import 'package:shad/shad.dart' show LucideIcons;

/// One icon from each font that a dependency bundles but the app never uses.
///
/// Every font in the manifest is downloaded before the app's first frame. The
/// release build subsets an icon font to the glyphs the app references, but
/// leaves a font untouched when nothing references it at all, so the unused
/// fonts shipped whole: the five lighter Lucide weights and the Geist family
/// from shad, some 2.6 MB. Naming one glyph from each here makes the build
/// subset them to a couple of kilobytes.
///
/// The app uses the regular and 600 Lucide weights, and Inter for text. Should
/// it ever use another of these fonts, remove that font from this list, or its
/// text would render as missing glyphs.
const kTreeShakenFonts = <IconData>[
  LucideIcons.file100,
  LucideIcons.file200,
  LucideIcons.file300,
  LucideIcons.file400,
  LucideIcons.file500,
  IconData(0x41, fontFamily: 'Geist', fontPackage: 'shad'),
  IconData(0x41, fontFamily: 'GeistMono', fontPackage: 'shad'),
];
