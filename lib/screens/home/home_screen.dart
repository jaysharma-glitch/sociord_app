import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/feed_slider.dart';
import 'package:sociord/widgets/home/post_widget.dart';
import 'package:sociord/widgets/home/quicky_recommendation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                kLogoText,
                height: 28,
              ),
              const SizedBox(
                width: 5,
              ),
              Image.asset(kChevronDown)
            ],
          ),
        ),
        backgroundColor: kAppWhite,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              kNotification,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () {},
            child: Image.asset(kMessage),
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            FeedSlider(),
            const SizedBox(
              height: 20,
            ),
            QuickyRecommendation(
              userName: 'Arjun',
              onDismiss: () {},
              recommendations: const [
                {"image": kQuicky1, "title": "My Royal Transformation"},
                {"image": kQuicky2, "title": "Exploring Cheese"},
                {"image": kQuicky3, "title": "The Modern Man’s..."}
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            PostWidget(
              profileImage: kCreator1,
              username: "darius_nova1",
              category: "Music, Dance & Performance",
              postImage: kPost1,
              likes: 20000,
              comments: 500000,
              shares: 1000,
              title: "Dancing Through Life Freestyle Fun",
              rating: "Excellent",
              views: 250000,
              timeAgo: "10 days ago",
              categoryColor: Colors.pink,
            )
          ],
        ),
      ),
    );
  }
}
