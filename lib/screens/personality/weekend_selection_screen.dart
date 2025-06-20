import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_personality.dart';

class WeekendSelectionScreen extends ConsumerStatefulWidget {
  final PageController? pageController;
  final List<bool> selectedOptions;

  const WeekendSelectionScreen({
    super.key,
    this.pageController,
    required this.selectedOptions,
  });

  @override
  ConsumerState<WeekendSelectionScreen> createState() =>
      _WeekendSelectionScreenState();
}

class _WeekendSelectionScreenState
    extends ConsumerState<WeekendSelectionScreen> {
  late final Future<List<dynamic>> _weekendOptionsFuture;

  @override
  void initState() {
    super.initState();
    _weekendOptionsFuture =
        ref.read(userPersonalityNotifierProvider.notifier).getWeekendOption();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _weekendOptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SkeletonLoaderPersonality());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading weekend options',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else if (snapshot.hasData) {
          final weekendOptions = snapshot.data!;
          return GridSelector(
            list: weekendOptions,
            selectedList: widget.selectedOptions,
          );
        } else {
          return const Center(child: Text('No weekend options available'));
        }
      },
    );
  }
}
