import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class BottomSheetContent extends StatelessWidget {
  const BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned(top: -10, right: 20, child: Icon(Icons.cancel)),
        Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                'We want to keep things real',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: kAppBlack, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8.0),
              Text(
                'We use your mobile number for verification to ensure you\'re a real person. It\'s the most reliable method available.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 16.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Things we want',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: kAppDarkGreen,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8.0),
                        const IconWithText(
                            textt: 'Real People',
                            icon: Icons.check,
                            iconColor: kAppDarkGreen),
                        const IconWithText(
                            textt: 'Quality Content',
                            icon: Icons.check,
                            iconColor: kAppDarkGreen),
                        const IconWithText(
                            textt: 'Great App Experience',
                            icon: Icons.check,
                            iconColor: kAppDarkGreen),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Things we want to avoid',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: kAppRed,
                                    fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8.0),
                        const IconWithText(
                            textt: 'Bot Accounts',
                            icon: Icons.cancel_outlined,
                            iconColor: kAppRed),
                        const IconWithText(
                            textt: 'Bullies and Trolls',
                            icon: Icons.cancel_outlined,
                            iconColor: kAppRed),
                        const IconWithText(
                            textt: 'Security Risks',
                            icon: Icons.cancel_outlined,
                            iconColor: kAppRed),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Continue',
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }
}

class IconWithText extends StatelessWidget {
  final String textt;
  final IconData icon;
  final Color iconColor;
  const IconWithText(
      {super.key,
      required this.textt,
      required this.icon,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: 2.0),
        Expanded(
          child: Text(
            textt,
            style:
                Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
