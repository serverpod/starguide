import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter/material.dart';

ChatTheme createChatTheme(BuildContext context) {
  final theme = Theme.of(context);

  return ChatTheme.light().copyWith(
    colors: ChatColors(
      primary: theme.colorScheme.primary,
      onPrimary: theme.colorScheme.onPrimary,
      surface: theme.colorScheme.surface,
      onSurface: theme.colorScheme.onSurface,
      surfaceContainer: theme.colorScheme.surfaceContainer,
      surfaceContainerHigh: theme.colorScheme.surfaceContainerHigh,
      surfaceContainerLow: theme.colorScheme.surfaceContainerLow,
    ),
    typography: ChatTypography(
      bodySmall: theme.textTheme.bodyMedium!,
      bodyMedium: theme.textTheme.bodyMedium!,
      bodyLarge: theme.textTheme.bodyMedium!,
      labelSmall: theme.textTheme.labelSmall!,
      labelMedium: theme.textTheme.labelMedium!,
      labelLarge: theme.textTheme.labelLarge!,
    ),
  );
}
