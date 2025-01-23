import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/personality_trait_model.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_personality.dart';

class SoundtrackSelectionScreen extends ConsumerStatefulWidget {
  final PageController pageController;
  final List selectedOptions;

  SoundtrackSelectionScreen(
      {super.key, required this.pageController, required this.selectedOptions});

  @override
  _SoundtrackSelectionScreenState createState() =>
      _SoundtrackSelectionScreenState();
}

class _SoundtrackSelectionScreenState
    extends ConsumerState<SoundtrackSelectionScreen> {
  Future<List<dynamic>> fetchSoundtrackOptions() async {
    var userPersonalityNotifier =
        ref.read(userPersonalityNotifierProvider.notifier);
    try {
      var result = await userPersonalityNotifier.getSoundtrackOptions();

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
              child: SkeletonLoaderPersonality()); // Show loader while waiting
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error loading soundtracks')); // Handle errors
        } else if (snapshot.hasData) {
          // Replace kSoundtrackOptions with the API data
          List<dynamic> soundtrackOptions = snapshot.data!;
          return GridSelector(
            isFirst: true,
            list: soundtrackOptions, // Use the API data here
            selectedList: widget.selectedOptions,
          );
        } else {
          return Center(child: Text('No soundtracks available'));
        }
      },
    );
  }
}
