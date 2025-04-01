import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/provider/location_provider.dart';
import 'package:uuid/uuid.dart';

class LocationSearch extends ConsumerStatefulWidget {
  final PageController? pageController;
  const LocationSearch({super.key, this.pageController});

  @override
  ConsumerState<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends ConsumerState<LocationSearch> {
  final TextEditingController _controller = TextEditingController();
  final _uuid = const Uuid();
  String _sessionToken = '123456';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _sessionToken = _uuid.v4();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    print('hi');
    final input = _controller.text.trim();
    if (input.length > 2 && _sessionToken.isNotEmpty) {
      ref
          .read(locationNotifierProvider.notifier)
          .getSuggestion(input, _sessionToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final suggestions = locationState.suggestions ?? [];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Search your location",
                  hintText: "Enter your location",
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  border: kTextFormFieldBorderStyles,
                  enabledBorder: kTextFormFieldBorderStyles,
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: suggestions.isEmpty
                    ? Center(
                        child: Text(
                          'No suggestions yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = suggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(
                              suggestion['description'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            onTap: () async {
                              final placeId = suggestion['place_id'];
                              await ref
                                  .read(locationNotifierProvider.notifier)
                                  .fetchPlaceDetails(placeId);

                              final selectedCity = ref
                                  .read(locationNotifierProvider)
                                  .location
                                  ?.city;

                              if (context.canPop()) {
                                context.pop(selectedCity);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
