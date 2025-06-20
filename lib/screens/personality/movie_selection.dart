import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_personality.dart';

class MovieSelectionScreen extends ConsumerStatefulWidget {
  final PageController? pageController;
  final List<bool> selectedOptions;

  const MovieSelectionScreen({
    super.key,
    this.pageController,
    required this.selectedOptions,
  });

  @override
  ConsumerState<MovieSelectionScreen> createState() =>
      _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends ConsumerState<MovieSelectionScreen> {
  late final Future<List<dynamic>> _movieOptionsFuture;

  @override
  void initState() {
    super.initState();
    _movieOptionsFuture = ref
        .read(userPersonalityNotifierProvider.notifier)
        .getBingeWatchOption();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _movieOptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SkeletonLoaderPersonality());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading movie options',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else if (snapshot.hasData) {
          final movieOptions = snapshot.data!;
          return GridSelector(
            list: movieOptions,
            selectedList: widget.selectedOptions,
          );
        } else {
          return const Center(child: Text('No movie options available'));
        }
      },
    );
  }
}
