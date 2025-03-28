import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/location_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:sociord/constants/ui.dart';

class LocationSearch extends ConsumerStatefulWidget {
  final pageController;
  const LocationSearch({super.key, this.pageController});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LocationSearchState();
}

class _LocationSearchState extends ConsumerState<LocationSearch> {
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  String street = '';
  String city = '';
  String state = '';
  String zipCode = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onChanged();
    });
  }

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    if (_controller.text.length > 2) {
      ref
          .read(locationNotifierProvider.notifier)
          .getSuggestion(_controller.text, _sessionToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    print(locationState.suggestions);
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: height,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Search your location",
                hintText: "Enter your location",
                hintStyle: Theme.of(context).textTheme.bodyLarge,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {},
            ),
            Expanded(
              child: ListView.builder(
                itemCount: locationState.suggestions != null
                    ? locationState.suggestions!.length
                    : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text(
                      locationState.suggestions![index]['description'],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      // Handle the location selection here
                      await ref
                          .read(locationNotifierProvider.notifier)
                          .fetchPlaceDetails(
                              locationState.suggestions![index]['place_id']);

                      // ignore: use_build_context_synchronously
                      context.pop(
                          ref.watch(locationNotifierProvider).location?.city);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
