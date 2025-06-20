import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_personality.dart';

class ConnectSelectionScreen extends ConsumerStatefulWidget {
  final PageController? pageController;
  final List<bool> selectedOptions;

  const ConnectSelectionScreen({
    super.key,
    this.pageController,
    required this.selectedOptions,
  });

  @override
  ConsumerState<ConnectSelectionScreen> createState() =>
      _ConnectSelectionScreenState();
}

class _ConnectSelectionScreenState
    extends ConsumerState<ConnectSelectionScreen> {
  late final Future<List<dynamic>> _connectOptionsFuture;

  @override
  void initState() {
    super.initState();
    _connectOptionsFuture =
        ref.read(userPersonalityNotifierProvider.notifier).getConnectOption();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _connectOptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SkeletonLoaderPersonality());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading connect options',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else if (snapshot.hasData) {
          final connectionOptions = snapshot.data!;
          return GridSelector(
            list: connectionOptions,
            selectedList: widget.selectedOptions,
            canSelectOnlyOne: true,
          );
        } else {
          return const Center(child: Text('No connect options available'));
        }
      },
    );
  }
}
