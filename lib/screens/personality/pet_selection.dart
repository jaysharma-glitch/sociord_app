import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_pets.dart';

class PetSelectionScreen extends ConsumerStatefulWidget {
  final PageController? pageController;
  final List<bool> selectedOptions;

  const PetSelectionScreen({
    super.key,
    this.pageController,
    required this.selectedOptions,
  });

  @override
  ConsumerState<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen> {
  late final Future<List<dynamic>> _petOptionsFuture;

  @override
  void initState() {
    super.initState();
    _petOptionsFuture =
        ref.read(userPersonalityNotifierProvider.notifier).getPetOption();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _petOptionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SkeletonLoaderPets());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading pet options',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else if (snapshot.hasData) {
          final petOptions = snapshot.data!;
          return GridSelector(
            list: petOptions,
            selectedList: widget.selectedOptions,
            canSelectOnlyOne: true,
            aspectRatio: 2.7,
            crossAxisCount: 1,
          );
        } else {
          return const Center(child: Text('No pet options available'));
        }
      },
    );
  }
}
