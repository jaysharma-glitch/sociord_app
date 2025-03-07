import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/widgets/grid_selector.dart';
import 'package:sociord/widgets/textfield_with_sumbit.dart';

class PickCategory extends StatefulWidget {
  final selectedOptions;
  final categoryNotFound;
  final pageController;
  const PickCategory(
      {super.key,
      this.selectedOptions,
      this.categoryNotFound,
      this.pageController});

  @override
  State<PickCategory> createState() => _PickCategoryState();
}

class _PickCategoryState extends State<PickCategory> {
  late TextEditingController _searchController = TextEditingController();

  var isLoading = false;

  var searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: _searchController,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 12, color: kAppBlack, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              filled: true,
              fillColor: kBorderGreay.withOpacity(0.5),
              hintText: "Search",
              hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 12, color: kAppBlack, fontWeight: FontWeight.w300),
              isDense: true, // ✅ Reduces default height
              contentPadding: EdgeInsets.zero,
              prefixIcon: const Padding(
                padding: EdgeInsets.all(0),
                child: Icon(Icons.search, color: kAppBlack, size: 18),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 35,
                minHeight: 35,
              ),

              border: kTextFormFieldBorderStyles.copyWith(
                  borderRadius: BorderRadius.circular(5)),
              enabledBorder: kTextFormFieldBorderStyles.copyWith(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5)),
              focusedBorder: kTextFormFieldBorderStyles.copyWith(
                borderSide: BorderSide.none, // ✅ Same as enabledBorder
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onChanged: (value) async {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          widget.categoryNotFound
              ? Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Sorry, we couldn\'t find any category called "$searchQuery"',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          color: kBorderGreay.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText(
                            text: 'What us to add a new category?',
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
                                    fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                                'Tell us what you’d like to see in our list and we’ll try our best to add it as soon as possible.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 10)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const TextFieldWithSubmit()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.pageController.nextPage(
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeIn,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          backgroundColor: kAppPurple,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Continue',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith()),
                      ),
                    ),
                  ],
                )
              : GridSelector(
                  list: kCategoryOptions
                      .map((map) => Option.fromMap(map))
                      .toList(),
                  selectedList: widget.selectedOptions!,
                  canSelectOnlyOne: true,
                  aspectRatio: 0.68,
                  paddingFromAround: 0.0,
                )
        ],
      ),
    );
  }
}

class Option {
  final String image;
  final String title;
  final description;
  Option({required this.image, required this.title, required this.description});

  // ✅ Factory method to convert a Map into an Option object
  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
        image: map["image"] ?? "",
        title: map['title'] ?? "",
        description: map['description' ?? '']); // Default empty string if null
  }
}
