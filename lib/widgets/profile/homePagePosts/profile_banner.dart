// lib/widgets/profile/profile_banner.dart
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ProfileBanner extends StatelessWidget {
  final String title;
  final String desc;
  final String image;
  final String? cta;
  final VoidCallback? ctaLink;
  final bool centerAlign;

  const ProfileBanner({
    super.key,
    required this.title,
    required this.desc,
    required this.image,
    this.cta,
    this.ctaLink,
    this.centerAlign = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      padding: EdgeInsets.symmetric(horizontal: centerAlign ? 20 : 15),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAppPurple, kAppOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment:
                centerAlign
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: centerAlign ? TextAlign.center : TextAlign.left,
                style: textTheme.headlineSmall!.copyWith(
                  fontSize: centerAlign ? 20 : 12,
                  color: kAppWhite,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                width:
                    centerAlign
                        ? double.infinity
                        : MediaQuery.of(context).size.width * 0.65,
                child: Text(
                  desc,
                  textAlign: centerAlign ? TextAlign.center : TextAlign.left,
                  style: textTheme.bodySmall!.copyWith(
                    fontSize: centerAlign ? 12 : 10,
                    color: kAppWhite,
                  ),
                ),
              ),
              SizedBox(height: centerAlign ? 50 : 10),
              if (cta != null && ctaLink != null)
                ElevatedButton(
                  onPressed: ctaLink,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: kAppWhite,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GradientText(
                        text: cta!,
                        gradient: const LinearGradient(
                          colors: [kAppPurple, kAppOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        style: textTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset(kRightArrow),
                    ],
                  ),
                ),
            ],
          ),
          Positioned(
            top: centerAlign ? 55 : 0,
            left: centerAlign ? 0 : null,
            right: centerAlign ? 0 : -8,
            child: Align(
              alignment: centerAlign ? Alignment.topCenter : Alignment.topRight,
              child: Image.asset(image, width: centerAlign ? 200 : null),
            ),
          ),
        ],
      ),
    );
  }
}
