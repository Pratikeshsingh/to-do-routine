import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/focus_override.dart';

/// Placeholder list for the focus % planner (full UI in v2).
final focusOverridesProvider =
    NotifierProvider<FocusOverridesNotifier, List<FocusOverride>>(
  FocusOverridesNotifier.new,
);

class FocusOverridesNotifier extends Notifier<List<FocusOverride>> {
  @override
  List<FocusOverride> build() => const [];

  void setPlaceholder(FocusOverride override) {
    state = [override];
  }

  void clear() => state = const [];
}
