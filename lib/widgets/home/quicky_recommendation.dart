import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class HomePageRecommendation extends StatelessWidget {
  final String type;
  final String userName;
  final VoidCallback onDismiss;
  final List<Map<String, String>> recommendations;

  const HomePageRecommendation({
    super.key,
    this.type = "Quickies",
    required this.userName,
    required this.onDismiss,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 10),
          _buildRecommendationList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final title = type == "Quickies"
        ? RichText(
            text: TextSpan(
              text: "Thought you'd like these quickies, ",
              style: _headerTextStyle(context),
              children: [
                TextSpan(
                  text: userName,
                  style: _headerTextStyle(context),
                ),
              ],
            ),
          )
        : Text(
            "Some Creators you might like",
            style: _headerTextStyle(context),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          GestureDetector(
            onTap: onDismiss,
            child: Text(
              "Dismiss",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    color: kAppBlack,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(BuildContext context) {
    final isShort = recommendations.length <= 3;

    return SizedBox(
      height: 160,
      child: isShort
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: recommendations
                    .map((item) => _buildCard(
                          imagePath: item["image"]!,
                          title: item["title"]!,
                          context: context,
                        ))
                    .toList(),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: recommendations.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return _buildCard(
                  imagePath: item["image"]!,
                  title: item["title"]!,
                  context: context,
                );
              },
            ),
    );
  }

  Widget _buildCard({
    required String imagePath,
    required String title,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 110,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 110,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: kAppPurple,
        );
  }
}
