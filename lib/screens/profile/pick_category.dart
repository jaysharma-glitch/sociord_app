import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/grid_selector.dart';

class PickCategory extends StatefulWidget {
  final selectedOptions;
  const PickCategory({super.key, this.selectedOptions});

  @override
  State<PickCategory> createState() => _PickCategoryState();
}

class _PickCategoryState extends State<PickCategory> {
  late TextEditingController _searchController = TextEditingController();

  var isLoading = false;
  var categoryNotFound = false;
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
            onChanged: (value) async {},
          ),
          GridSelector(
            list: kCategoryOptions.map((map) => Option.fromMap(map)).toList(),
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
