import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';

import '../../utils/asset_path_constants.dart';

class ProfileBanner extends StatelessWidget {
  final String title;
  final String desc;
  final String image;
  final String cta;
  final ctaLink;

  const ProfileBanner(
      {super.key,
      required this.title,
      required this.desc,
      required this.image,
      required this.cta,
      required this.ctaLink});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kAppPurple, kAppOrange],
            begin: Alignment.topLeft, // Gradient starts from top-left
            end: Alignment.bottomRight, // Gradient ends at bottom-right
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 12)),
                  const SizedBox(
                    height: 2,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Text(
                      desc,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 10, color: kAppWhite),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: ctaLink,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: kAppWhite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.zero,
                          bottomRight: Radius.zero,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientText(
                          text: cta,
                          gradient: const LinearGradient(
                            colors: [kAppPurple, kAppOrange],
                            begin: Alignment
                                .topLeft, // Gradient starts from top-left
                            end: Alignment
                                .bottomRight, // Gradient ends at bottom-right
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset(kRightArrow)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(top: -20, right: -8, child: Image.asset(image)),
          ],
        ));
  }
}
