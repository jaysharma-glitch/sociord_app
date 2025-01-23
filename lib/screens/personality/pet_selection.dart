import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_pets.dart';

class PetSelectionScreen extends ConsumerStatefulWidget {
  final pageController;
  final selectedOptions;
  PetSelectionScreen(
      {super.key, this.pageController, required this.selectedOptions});

  @override
  _PetSelectionScreenState createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends ConsumerState<PetSelectionScreen> {
  Future<List<dynamic>> fetchSoundtrackOptions() async {
    var userPersonalityNotifier =
        ref.read(userPersonalityNotifierProvider.notifier);
    try {
      var result = await userPersonalityNotifier.getPetOption();

      return result;
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(CustomSnackBar().build(context));
      } else {
        print(e.toString());
      }
      return [];
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var userPersonalityNotifier =
        ref.read(userPersonalityNotifierProvider.notifier);
    var userState = ref.watch(userNotifierProvider);
    return FutureBuilder<List<dynamic>>(
      future: fetchSoundtrackOptions(), // Fetch data from API
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: SkeletonLoaderPets()); // Show loader while waiting
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error loading weekend options')); // Handle errors
        } else if (snapshot.hasData) {
          // Replace kSoundtrackOptions with the API data
          List<dynamic> petOptions = snapshot.data!;
          return GridSelector(
            list: petOptions, // Use the API data here
            selectedList: widget.selectedOptions,
            canSelectOnlyOne: true,
            aspectRatio: 2.7,
            crossAxisCount: 1,
          );
        } else {
          return Center(child: Text('No soundtracks available'));
        }
      },
    );
  }
}
