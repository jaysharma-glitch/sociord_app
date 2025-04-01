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

  bool isButtonVisible = false;
  bool isLoading = false;
  bool userNameExists = false;
  bool userNameAccepted = false;

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    final existingUsername = ref.read(userNotifierProvider).userName;
    if (existingUsername != null && existingUsername.isNotEmpty) {
      _usernameController.text = existingUsername;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleUsernameChange(String value) async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final userState = ref.read(userNotifierProvider);

    if (value.length <= 2) {
      setState(() {
        suggestions.clear();
        userNameExists = false;
        userNameAccepted = false;
        isButtonVisible = false;
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      final isAvailable = await userNotifier.checkUserName(value);
      final regex = RegExp(r'^[a-zA-Z0-9_.]+$');

      if (!isAvailable) {
        setState(() {
          userNameExists = true;
          userNameAccepted = false;
          isButtonVisible = false;
        });

        final result =
            await userNotifier.generateUsernameOptions(value, 'user_123');
        if (result != null) {
          setState(() {
            suggestions = List<String>.from(result);
          });
        }
      } else if (!regex.hasMatch(value)) {
        setState(() {
          userNameExists = false;
          userNameAccepted = false;
          isButtonVisible = false;
        });
      } else {
        setState(() {
          userNameExists = false;
          userNameAccepted = true;
          isButtonVisible = true;
        });
      }
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(CustomSnackBar().build(context));
      }
      setState(() {
        isLoading = false;
        userNameExists = false;
        userNameAccepted = false;
        isButtonVisible = false;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildSuggestions(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox();

    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: [
            for (final suggestion in suggestions)
              ChoiceChip(
                label: Text(suggestion),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                padding: const EdgeInsets.symmetric(vertical: 5),
                selected: false,
                backgroundColor: kAppGreay,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (_) {
                  _usernameController.text = suggestion;
                  setState(() {
                    userNameAccepted = true;
                    userNameExists = false;
                    isButtonVisible = true;
                  });
                },
              ),
            ActionChip(
              label: Row(
                children: [
                  const Icon(Icons.refresh, size: 18),
                  const SizedBox(width: 5),
                  Text('More',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              backgroundColor: kAppGreay,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 5),
              side: BorderSide.none,
              onPressed: () async {
                final result = await userNotifier.generateUsernameOptions(
                    _usernameController.text, 'user_123');
                if (result != null) {
                  setState(() => suggestions = List<String>.from(result));
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
            Text('Set a username for your profile.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w400)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                CustomInputFormatter()
              ],
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                errorBorder: kTextFormFieldBorderStyles.copyWith(
                    borderSide: const BorderSide(color: kAppRed)),
                errorText: userNameExists
                    ? 'Sorry, this username is taken. Please pick another.'
                    : null,
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : userNameExists
                        ? const Icon(Icons.cancel_outlined, color: kAppRed)
                        : userNameAccepted
                            ? const Icon(Icons.check_circle,
                                color: kAppDarkGreen)
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
              Text('Great Pick!',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: kAppDarkGreen)),
            const SizedBox(height: 30),
            _buildSuggestions(context),
            const SizedBox(height: 30),
            if (isButtonVisible)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      userNotifier.setUserName(_usernameController.text);
                      widget.pageController?.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text('Continue',
                      style: Theme.of(context).textTheme.headlineSmall),
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
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (!RegExp(r'^[a-z0-9_.]*$').hasMatch(text)) return oldValue;
    if (text.contains('..')) return oldValue;
    return newValue;
  }
}
