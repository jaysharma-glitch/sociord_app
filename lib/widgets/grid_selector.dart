import 'package:flutter/material.dart';
import 'package:sociord/models/personality_trait_model.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/network_image.dart';

class GridSelector extends StatefulWidget {
  final bool isFirst;
  final List<dynamic> list;
  final List selectedList;
  final PageController? pageController;
  final double aspectRatio;
  final int crossAxisCount;
  final bool canSelectOnlyOne;
  final bool isLoading;
  final onNext;

  const GridSelector({
    super.key,
    this.isFirst = false,
    required this.list,
    required this.selectedList,
    required this.pageController,
    required this.onNext,
    this.isLoading = false,
    this.aspectRatio = 0.54,
    this.crossAxisCount = 3,
    this.canSelectOnlyOne = false,
  });

  @override
  State<GridSelector> createState() => _GridSelectorState();
}

class _GridSelectorState extends State<GridSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              height: widget.isFirst
                  ? MediaQuery.of(context).size.height * 0.63
                  : MediaQuery.of(context).size.height * 0.51,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.crossAxisCount,
                  childAspectRatio: widget.aspectRatio,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.list.length,
                itemBuilder: (context, index) {
                  final option = widget.list[index];
                  return GestureDetector(
                    onTap: () {
                      if (widget.canSelectOnlyOne) {
                        setState(() {
                          for (int i = 0; i < widget.selectedList.length; i++) {
                            widget.selectedList[i] = false;
                          }
                          widget.selectedList[index] =
                              !widget.selectedList[index];
                        });
                      } else {
                        setState(() {
                          widget.selectedList[index] =
                              !widget.selectedList[index];
                        });
                      }
                    },
                    child: widget.crossAxisCount != 1
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CustomeNetworkImage(url: option!.image),
                                  if (widget.selectedList[index])
                                    const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.purple,
                                          size: 20,
                                        ))
                                  else
                                    Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Icon(Icons.brightness_1,
                                            size: 20,
                                            color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(option.title,
                                  style: Theme.of(context).textTheme.bodySmall),
                              Text(
                                option.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 9),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  CustomeNetworkImage(url: option!.image),
                                  if (widget.selectedList[index])
                                    const Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.purple,
                                          size: 20,
                                        ))
                                  else
                                    Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Icon(Icons.brightness_1,
                                            size: 20,
                                            color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(option.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(color: kAppBlack)),
                                    Text(
                                      option.description,
                                      softWrap: true,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
          if (widget.selectedList.contains(true))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                onPressed: widget.onNext,
                child: widget.isLoading
                    ? kLoadingIndicator
                    : Text(
                        'Continues',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
