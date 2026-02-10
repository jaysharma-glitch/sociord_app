import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class SetUsernameWidget extends ConsumerStatefulWidget {
  final PageController? pageController;

  const SetUsernameWidget({super.key, this.pageController});

  @override
  ConsumerState<SetUsernameWidget> createState() => _SetUsernameWidgetState();
}

class _SetUsernameWidgetState extends ConsumerState<SetUsernameWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  bool isButtonVisible = false; // Only show when username is available
  bool isLoading = false;
  bool userNameExists = false;
  bool userNameAccepted = false;
  bool isLoadingSuggestions = false; // Track loading state for suggestions

  List<String> suggestions = [];
  int suggestionsOffset = 0; // Track how many suggestions have been shown
  bool _isFirstSuggestionCall = true; // Track if this is the first suggestion call
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final existingUsername = ref.read(userNotifierProvider).userName;
    if (existingUsername != null && existingUsername.isNotEmpty) {
      _usernameController.text = existingUsername;
      // Check if existing username is still available
      if (existingUsername.length >= 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _performUsernameCheck(existingUsername);
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleUsernameChange(String value) async {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    print('=== Username Change Handler ===');
    print('Input value: "$value"');
    print('Value length: ${value.length}');

    // If less than 3 characters, clear state and don't check
    if (value.length < 3) {
      print('Value too short (< 3 chars), clearing state');
      setState(() {
        suggestions = []; // Clear suggestions
        userNameExists = false;
        userNameAccepted = false;
        isButtonVisible = false;
        isLoading = false;
      });
      return;
    }

    // Don't show loading while typing - only show when actually checking
    // Debounce: Wait 0.5 seconds after user stops typing before checking
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performUsernameCheck(value);
    });
  }

  Future<void> _performUsernameCheck(String value) async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final userState = ref.read(userNotifierProvider);

    print('=== Performing Username Check (after debounce) ===');
    print('Checking username: "$value"');

    // Show loading only when actually checking
    setState(() {
      isLoading = true;
      userNameAccepted = false;
      isButtonVisible = false;
      userNameExists = false; // Clear previous error state
      _isFirstSuggestionCall = true; // Reset for new username check
    });

    try {
      print('Calling checkUserName with: "$value"');
      final isAvailable = await userNotifier.checkUserName(value);
      print(
        'checkUserName response: $isAvailable (type: ${isAvailable.runtimeType})',
      );

      final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
      final regexMatch = regex.hasMatch(value);
      print('Regex match for "$value": $regexMatch');

      if (isAvailable == null) {
        print('ERROR: isAvailable is null!');
        setState(() {
          isLoading = false;
          userNameExists = false;
          userNameAccepted = false;
          isButtonVisible = false;
        });
        return;
      }

      if (!isAvailable) {
        print('Username "$value" is NOT available (taken or reserved)');
        setState(() {
          userNameExists = true;
          userNameAccepted = false;
          isButtonVisible = false;
          isLoading = false; // Stop loading since check is complete
        });

        final userId = userState.userId;
        print('Current userId: "$userId"');
        print(
          'Generating username options for "$value" with userId: "$userId"',
        );

        // Generate suggestions if userId exists
        if (userId != null && userId.isNotEmpty) {
          setState(() {
            isLoadingSuggestions = true;
          });
          try {
            final result = await userNotifier.generateUsernameOptions(
              value,
              userId,
              skipPriority1: false, // First call - show Priority 1
            );
            _isFirstSuggestionCall = false; // Mark that we've made the first call
            print('generateUsernameOptions response: $result');

            if (result != null && result.isNotEmpty) {
              print('Setting ${result.length} suggestions: $result');
              setState(() {
                suggestions = List<String>.from(result);
                suggestionsOffset = 0; // Reset offset when new suggestions are generated
                _isFirstSuggestionCall = false; // Mark that we've received suggestions
                isLoadingSuggestions = false;
              });
            } else {
              print('No suggestions returned or result is empty');
              setState(() {
                suggestions = [];
                suggestionsOffset = 0;
                isLoadingSuggestions = false;
              });
            }
          } catch (suggestionError) {
            print('Error generating suggestions: $suggestionError');
            // Even if suggestions fail, username is still not available
            // Keep the state as not available
            setState(() {
              suggestions = [];
              suggestionsOffset = 0;
              isLoadingSuggestions = false;
              userNameExists = true;
              userNameAccepted = false;
              isButtonVisible = false;
            });
          }
        } else {
          print('No userId available, skipping suggestions');
          setState(() {
            suggestions = [];
            isLoadingSuggestions = false;
          });
        }
        return; // Exit early - don't proceed with validation
      } else if (!regexMatch) {
        print('Username "$value" failed regex validation');
        setState(() {
          isLoading = false;
          userNameExists = false;
          userNameAccepted = false;
          isButtonVisible = false; // No Continue button if regex fails
          suggestions = []; // Clear suggestions on regex failure
          suggestionsOffset = 0;
        });
      } else {
        // Username is available AND passes regex validation
        print('Username "$value" is AVAILABLE and valid!');
        setState(() {
          isLoading = false;
          userNameExists = false;
          userNameAccepted = true;
          isButtonVisible = true; // Show Continue button only when available
          suggestions = []; // Clear suggestions when username is available
        suggestionsOffset = 0;
        _isFirstSuggestionCall = true; // Reset for next username check
        });
      }
    } catch (e) {
      print('ERROR in _performUsernameCheck: $e');
      print('Error type: ${e.runtimeType}');

      // On error, don't show Continue button - user must wait for successful check
      setState(() {
        isLoading = false;
        userNameExists = false;
        userNameAccepted = false; // Don't accept on error
        isButtonVisible = false; // Don't show Continue button on error
          suggestions = []; // Clear suggestions on error
          suggestionsOffset = 0;
      });

      // On error, check if it's a connection error
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar().build(context));
      } else {
        // For other errors (like GraphQL errors), show a message
        print('API error occurred - username check failed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to verify username availability. Please try again.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      print('Error handled - Continue button hidden until successful check');
    }
  }

  Widget _buildSuggestions(BuildContext context) {
    // Show suggestions widget when username exists (is unavailable) OR when we have suggestions
    if (!userNameExists && suggestions.isEmpty && !isLoadingSuggestions) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (isLoadingSuggestions)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (suggestions.isEmpty)
          Text(
            'No suggestions available. Try a different username.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8.0,
            children: [
              // Show suggestions starting from offset
              // First call (offset 0): show first 5 Priority 1
              // First "More" (offset 5): show next 3 Priority 1 + 2 mixed (5 total)
              // Subsequent "More": show next 5 mixed priorities
              for (final suggestion in suggestions.skip(suggestionsOffset).take(5))
                ChoiceChip(
                  label: Text(suggestion),
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  selected: false,
                  backgroundColor: kAppGreay,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (_) {
                    _usernameController.text = suggestion;
                    // Trigger availability check for the selected suggestion
                    _performUsernameCheck(suggestion);
                  },
                ),
              // "More" button - always available, generates new suggestions on click
              // Since there are infinite combinations, always show the button when we have suggestions
              if (suggestions.isNotEmpty || isLoadingSuggestions)
                ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isLoadingSuggestions
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'More',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                backgroundColor: kAppGreay,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                side: BorderSide.none,
                onPressed: isLoadingSuggestions ? null : () async {
                  // Generate new suggestions instead of just paginating
                  final userState = ref.read(userNotifierProvider);
                  final userId = userState.userId;
                  final currentUsername = _usernameController.text.trim();
                  
                  if (userId != null && userId.isNotEmpty && currentUsername.isNotEmpty) {
                    setState(() {
                      isLoadingSuggestions = true;
                    });
                    
                    try {
                      final userNotifier = ref.read(userNotifierProvider.notifier);
                      print('=== More button clicked - generating new suggestions ===');
                      print('Current username: "$currentUsername", userId: "$userId"');
                      final result = await userNotifier.generateUsernameOptions(
                        currentUsername,
                        userId,
                        skipPriority1: !_isFirstSuggestionCall, // Skip Priority 1 after first call
                      );
                      _isFirstSuggestionCall = false; // Mark that we've made a call
                      
                      print('New suggestions received: ${result?.length ?? 0}');
                      if (result != null && result.isNotEmpty) {
                        print('First 5 new suggestions: ${result.take(5).join(", ")}');
                      }
                      
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          suggestions = List<String>.from(result);
                          suggestionsOffset = 0; // Reset offset for new suggestions
                          isLoadingSuggestions = false;
                        });
                        print('Suggestions updated: ${suggestions.length} total');
                      } else {
                        print('No suggestions returned from backend');
                        setState(() {
                          isLoadingSuggestions = false;
                        });
                      }
                    } catch (e) {
                      print('Error generating new suggestions: $e');
                      setState(() {
                        isLoadingSuggestions = false;
                      });
                    }
                  }
                },
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a username for your profile.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                CustomInputFormatter(),
              ],
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                errorBorder: kTextFormFieldBorderStyles.copyWith(
                  borderSide: const BorderSide(color: kAppRed),
                ),
                errorText: userNameExists
                    ? 'Sorry, this username is taken. Please pick another.'
                    : null,
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : userNameExists
                    ? const Icon(Icons.block, color: kAppRed)
                    : userNameAccepted
                    ? const Icon(Icons.check_circle, color: kAppDarkGreen)
                    : null,
              ),
              onChanged: _handleUsernameChange,
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
                if (!regex.hasMatch(value))
                  return 'Username can\'t have special characters';
                return null;
              },
            ),
            if (userNameAccepted) const SizedBox(height: 10),
            if (userNameAccepted)
              Text(
                'Great Pick!',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: kAppDarkGreen),
              ),
            const SizedBox(height: 30),
            _buildSuggestions(context),
            const SizedBox(height: 30),
            if (isButtonVisible)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final username = _usernameController.text.trim();
                      print('=== Continue button pressed ===');
                      print('Saving username: "$username"');

                      try {
                        // First reserve username temporarily
                        final reserved = await userNotifier.saveUsername(username);
                        
                        if (reserved) {
                          // Then set it permanently
                          final success = await userNotifier.setUsernamePermanently(username);
                          
                          if (success) {
                            print('Username set permanently, navigating to next page');
                            widget.pageController?.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            print('Failed to set username permanently');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to set username. Please try again.',
                                ),
                              ),
                            );
                          }
                        } else {
                          print('Failed to reserve username');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to reserve username. Please try again.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error reserving username: $e');
                        final errorStr = e.toString().toLowerCase();
                        String errorMessage =
                            'Failed to reserve username. Please try again.';

                        // Update UI state and generate suggestions for both "taken" and "reserved" errors
                        if (errorStr.contains('taken') ||
                            errorStr.contains('already') ||
                            errorStr.contains('reserved')) {
                          if (errorStr.contains('reserved')) {
                            errorMessage =
                                'This username is currently reserved by another user. Please choose another.';
                          } else {
                            errorMessage =
                                'This username is already taken. Please choose another.';
                          }

                          // Update UI state
                          setState(() {
                            userNameExists = true;
                            userNameAccepted = false;
                            isButtonVisible = false;
                          });

                          // Generate suggestions for the unavailable username
                          final userId = ref.read(userNotifierProvider).userId;
                          if (userId != null && userId.isNotEmpty) {
                            try {
                              final result = await userNotifier
                                  .generateUsernameOptions(username, userId, skipPriority1: false);
                              if (result != null && result.isNotEmpty) {
                                setState(() {
                                  suggestions = List<String>.from(result);
                suggestionsOffset = 0;
                                });
                              }
                            } catch (suggestionError) {
                              print(
                                'Error generating suggestions: $suggestionError',
                              );
                            }
                          }
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(errorMessage)));
                      }
                    }
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!RegExp(r'^[a-z0-9_.]*$').hasMatch(text)) return oldValue;
    if (text.contains('..')) return oldValue;
    return newValue;
  }
}
