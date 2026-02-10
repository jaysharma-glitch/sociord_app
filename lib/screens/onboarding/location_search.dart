import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final input = _controller.text.trim();
    print('Search input changed: "$input" (length: ${input.length})');
    if (input.length > 2 && _sessionToken.isNotEmpty) {
      print(
        'Calling getSuggestion with input: "$input", token: $_sessionToken',
      );
      ref
          .read(locationNotifierProvider.notifier)
          .getSuggestion(input, _sessionToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final suggestions = locationState.suggestions ?? [];
    final isLoading = locationState.loading;
    final error = locationState.error;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Search Location'),
      ),
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
                autofocus: true,
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: $error',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : suggestions.isEmpty
                        ? Center(
                          child: Text(
                            _controller.text.isEmpty
                                ? 'Start typing to search for your location'
                                : 'No suggestions found. Try a different search term.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                        : ListView.builder(
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = suggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(
                                suggestion['description'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle:
                                  suggestion['structured_formatting'] != null
                                      ? Text(
                                        suggestion['structured_formatting']['secondary_text'] ??
                                            '',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      )
                                      : null,
                              onTap: () async {
                                final placeId = suggestion['place_id'];
                                if (placeId != null) {
                                  await ref
                                      .read(locationNotifierProvider.notifier)
                                      .fetchPlaceDetails(placeId);

                                  final selectedCity =
                                      ref
                                          .read(locationNotifierProvider)
                                          .location
                                          ?.city;

                                  if (context.canPop()) {
                                    context.pop(selectedCity);
                                  }
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
