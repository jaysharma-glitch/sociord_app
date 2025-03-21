import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

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
          // Header Row: Title + Dismiss Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: type == "Quickies"
                ? Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // ✅ Better alignment
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Thought you'd like these quickies, ",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kAppPurple,
                              ),
                          children: [
                            TextSpan(
                              text: userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: kAppPurple,
                                  ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onDismiss,
                        child: Text("Dismiss",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 12,
                                    color: kAppBlack,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1)),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Some Creators you might like",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: kAppPurple,
                                ),
                      ),
                      GestureDetector(
                        onTap: onDismiss,
                        child: Text("Dismiss",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    fontSize: 12,
                                    color: kAppBlack,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1)),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 10),

          // Recommendation Cards
          SizedBox(
            height: 160,
            child: recommendations.length <= 3
                ? Center(
                    // ✅ Center if items ≤ 3
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: recommendations
                          .map((item) => _buildRecommendationCard(
                                item["image"]!,
                                item["title"]!,
                                context,
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
                      return _buildRecommendationCard(
                          recommendations[index]["image"]!,
                          recommendations[index]["title"]!,
                          context);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper method to build each recommendation card
  Widget _buildRecommendationCard(String imagePath, String title, context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 6.0), // ✅ Balanced spacing
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
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    )),
          ),
        ],
      ),
    );
  }
}
