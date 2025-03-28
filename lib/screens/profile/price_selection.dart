import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class PriceSelection extends StatefulWidget {
  final pageController;
  const PriceSelection({super.key, this.pageController});

  @override
  State<PriceSelection> createState() => _PriceSelectionState();
}

class _PriceSelectionState extends State<PriceSelection> {
  var price;
  final List<int> prices = List.generate(90, (index) => index + 10);

  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: price ?? 10);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _selectPrice(BuildContext context) async {
    if (price != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.jumpToItem(prices.indexOf(price));
      });
    }
    showModalBottomSheet(
        backgroundColor: kAppWhite,
        context: context,
        builder: (context) {
          int selectedPrice = price ?? 0; // Temporary variable inside modal
          return StatefulBuilder(builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: kAppBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Fixed Divider (Always stays in center)
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                              thickness: 1,
                              color: kAppBlack,
                              indent: 100,
                              endIndent: 100),
                          SizedBox(height: 40), // Space for scrolling number
                          Divider(
                              thickness: 1,
                              color: Colors.black,
                              indent: 100,
                              endIndent: 100),
                        ],
                      ),

                      // Scrollable Price Picker
                      SizedBox(
                        height: 150, // Controls visible area
                        child: ListWheelScrollView.useDelegate(
                          controller: _controller,
                          itemExtent: 50, // Spacing between items
                          physics:
                              const FixedExtentScrollPhysics(), // Snaps to items

                          onSelectedItemChanged: (index) {
                            setModalState(() {
                              price = prices[index];
                            });
                            setState(() {
                              price = prices[index];
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: prices.length,
                            builder: (context, index) {
                              bool isSelected = prices[index] == price;
                              return Center(
                                child: Stack(
                                  children: [
                                    isSelected
                                        ? const SizedBox(height: 10)
                                        : const SizedBox(),
                                    Center(
                                      child: Text(
                                        "${prices[index]}",
                                        style: isSelected
                                            ? Theme.of(context)
                                                .textTheme
                                                .headlineMedium!
                                                .copyWith(
                                                    color: kAppBlack,
                                                    fontWeight: FontWeight.w600)
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(color: kDarkGreay),
                                      ),
                                    ),
                                    isSelected
                                        ? Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(
                                              price < 40
                                                  ? "Good choice—fair for everyone"
                                                  : price < 70
                                                      ? "Consider if this fits your content"
                                                      : "This might be too high to start with",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: price < 40
                                                          ? kAppDarkGreen
                                                          : price < 70
                                                              ? kAppOrange
                                                              : kAppRed,
                                                      fontSize: 10),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Continue Button
                  const SizedBox(height: 20),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Monthly',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: kAppWhite,
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 2,
                                  decoration: BoxDecoration(
                                      color: kAppBlack,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Pick Your Price – What\'s Your Content Worth?',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: kAppBlack),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'Think about what your content brings to the table. If you charge too much, subscribers might hesitate. But if you\'re fair to your audience, you\'ll build a loyal following.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '🧐 Why can\'t I charge more than ₹99?',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: kAppPurple, fontSize: 15),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'To charge more, you need consistent uploads and strong ratings. Keep your audience engaged and, as you grow, so will your pricing options',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '❗️ Why not below ₹10?',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: kAppPurple, fontSize: 15),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                'We want to make sure your efforts are sustainable. Anything below ₹10 wouldn\'t support the time and effort you put into your content.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        );
                      });
                },
                child: Image.asset(
                  kQuestionMark,
                  height: 12,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectPrice(context);
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: kBorderGreay,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      price == null ? 'Select a price' : '₹$price',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: price == null
                              ? FontWeight.w300
                              : FontWeight.w500),
                    ),
                  ),
                  Image.asset(kDropDown)
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          price == null
              ? const SizedBox()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: Text(
                      'Continue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
