import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/network_image.dart';

/// Shows description with a max line count; if over, shows "Read more" / "Read less" to expand.
class ExpandableDescription extends StatefulWidget {
  final String text;
  final int maxLinesCollapsed;
  final TextStyle? style;

  const ExpandableDescription({
    super.key,
    required this.text,
    this.maxLinesCollapsed = 2,
    this.style,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 10,
          height: 1.1,
          fontFamily: 'Lato',
        );
    final style = widget.style ?? theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLinesCollapsed,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final needsExpand = tp.didExceedMaxLines;

        if (!needsExpand) {
          return Text(
            widget.text,
            style: style,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                maxLines: _expanded ? null : widget.maxLinesCollapsed,
                overflow: _expanded ? null : TextOverflow.ellipsis,
                style: style,
              ),
              const SizedBox(height: 2),
              Text(
                _expanded ? 'Read less' : 'Read more',
                style: style.copyWith(
                  color: kAppPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GridSelector extends StatefulWidget {
  final bool isFirst;
  final List<dynamic> list;
  final List selectedList;
  final double aspectRatio;
  final int crossAxisCount;
  final bool canSelectOnlyOne;
  final paddingFromAround;

  const GridSelector({
    super.key,
    this.isFirst = false,
    required this.list,
    required this.selectedList,
    this.aspectRatio = 0.61,
    this.crossAxisCount = 3,
    this.canSelectOnlyOne = false,
    this.paddingFromAround = 20.0,
  });

  @override
  State<GridSelector> createState() => _GridSelectorState();
}

class _GridSelectorState extends State<GridSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 0.0,
        left: widget.paddingFromAround,
        right: widget.paddingFromAround,
      ),
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
                  widget.selectedList[index] = !widget.selectedList[index];
                });
              } else {
                setState(() {
                  widget.selectedList[index] = !widget.selectedList[index];
                });
              }
            },
            child: widget.crossAxisCount != 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRect(
                          child: Stack(
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
                                  ),
                                )
                              else
                                Positioned(
                                  top: 1,
                                  right: 1,
                                  child: Icon(
                                    Icons.brightness_1,
                                    size: 20,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: kAppBlack,
                            ),
                      ),
                      option.description == null
                          ? const SizedBox()
                          : ExpandableDescription(
                              text: option.description!,
                              maxLinesCollapsed: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontSize: 10,
                                    height: 1.1,
                                    fontFamily: 'Lato',
                                    color: kAppBlack,
                                  ),
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
                            Text(
                              option.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: kAppBlack),
                            ),
                            option.description == null
                                ? const SizedBox()
                                : Text(
                                    option.description,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontFamily: 'Lato',
                                        ),
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
    );
  }
}
