import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_personality.dart';

class WeekendSelectionScreen extends ConsumerStatefulWidget {
  final pageController;
  WeekendSelectionScreen({super.key, this.pageController});

  @override
  _WeekendSelectionScreenState createState() => _WeekendSelectionScreenState();
}

class _WeekendSelectionScreenState
    extends ConsumerState<WeekendSelectionScreen> {
  final List<bool> selectedOptions = List.generate(11, (index) => false);

  Future<List<dynamic>> fetchSoundtrackOptions() async {
    var userPersonalityNotifier =
        ref.read(userPersonalityNotifierProvider.notifier);
    try {
      var result = await userPersonalityNotifier.getWeekendOption();

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
              child: Text('Error loading weekend options')); // Handle errors
        } else if (snapshot.hasData) {
          // Replace kSoundtrackOptions with the API data
          List<dynamic> weekendOptions = snapshot.data!;
          return GridSelector(
            list: weekendOptions, // Use the API data here
            selectedList: selectedOptions,
            pageController: widget.pageController,
            isLoading: isLoading,
            onNext: () async {
              List<String> selectedIds = [];
              for (int i = 0; i < weekendOptions.length; i++) {
                if (selectedOptions[i]) {
                  // Assuming `id` is an integer, modify if it's another type (e.g. String)
                  selectedIds.add(weekendOptions[i]!.id);
                }
              }

              try {
                setState(() {
                  isLoading = true;
                });

                // var result =
                //     await userPersonalityNotifier.addUserSoundtrackSelection(
                //         userNotifier.userId, selectedIds);
                var result = await userPersonalityNotifier
                    .addUserWeekendSelection(userState.userId, selectedIds);

                setState(() {
                  isLoading = false;
                });
                if (result != null) {
                  widget.pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              } catch (e) {
                setState(() {
                  isLoading = false;
                });
                if (e.toString().contains('Connection refused')) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(CustomSnackBar().build(context));
                } else {
                  print(e.toString());
                }
              }

              // widget.pageController.nextPage(
              //   duration: Duration(milliseconds: 300),
              //   curve: Curves.easeIn,
              // );
            },
          );
        } else {
          return Center(child: Text('No soundtracks available'));
        }
      },
    );
  }
}
