import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/provider/media_selection_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/services/permission_service.dart';
import 'package:sociord/services/pixabay_music_service.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/media_thumbnail.dart';

enum UploadFlowMode { creator, explorer }

enum _UploadStep {
  select,
  editor,
  details,
  music,
  longDescription,
  tagPeople,
  tagSearch,
}

class UploadTabConfig {
  const UploadTabConfig({
    required this.label,
    required this.mediaType,
    required this.postType,
  });

  final String label;
  final AssetType mediaType;
  final String postType;
}

extension UploadFlowModeX on UploadFlowMode {
  String get title =>
      this == UploadFlowMode.creator
          ? 'Upload Page - Creator'
          : 'Upload Page - Explorer';

  List<UploadTabConfig> get tabs =>
      this == UploadFlowMode.creator
          ? const [
            UploadTabConfig(
              label: 'Quickies',
              mediaType: AssetType.image,
              postType: 'QUICKIE',
            ),
            UploadTabConfig(
              label: 'Clips',
              mediaType: AssetType.video,
              postType: 'CLIP',
            ),
          ]
          : const [
            UploadTabConfig(
              label: 'Photos',
              mediaType: AssetType.image,
              postType: 'IMAGE',
            ),
            UploadTabConfig(
              label: 'Videos',
              mediaType: AssetType.video,
              postType: 'VIDEO',
            ),
          ];
}

class PersonalUploadScreen extends ConsumerStatefulWidget {
  const PersonalUploadScreen({super.key, this.mode = UploadFlowMode.explorer});

  final UploadFlowMode mode;

  @override
  ConsumerState<PersonalUploadScreen> createState() =>
      _PersonalUploadScreenState();
}

class _PersonalUploadScreenState extends ConsumerState<PersonalUploadScreen> {
  static const List<Map<String, String>> _collections = <Map<String, String>>[
    {'id': 'create_new', 'name': 'Create - Start a new collection'},
    {'id': 'c1', 'name': 'Midnight Munchies'},
    {'id': 'c2', 'name': 'Green Gains: Food & Fitness'},
    {
      'id': 'c3',
      'name': 'From Earth to Plate: My Journey into Farm-Fresh Foods',
    },
    {'id': 'c4', 'name': 'Nostalgic Nibbles: Rediscovering Childhood Flavours'},
  ];

  static const List<String> _musicGenres = <String>[
    'Romantic',
    'Upbeat',
    'Techno',
    'Dance',
    'Mystic',
  ];

  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  int _selectedTabIndex = 0;
  _UploadStep _step = _UploadStep.select;
  int _selectedPreviewIndex = 0;
  bool _isFilterTab = true;
  String _selectedFilterId = 'none';
  double _brightness = 0;
  final double _contrast = 1;
  double _saturation = 1;
  String _selectedGenre = '';
  String _selectedCollectionName = 'No';
  String? _selectedCollectionId;
  String _collectionDraftName = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _longDescriptionController =
      TextEditingController();
  final TextEditingController _musicSearchController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();

  final Map<String, File> _editedFiles = <String, File>{};
  final Map<String, int> _rotationTurns = <String, int>{};
  final Map<String, bool> _flipX = <String, bool>{};
  final Set<String> _taggedUserIds = <String>{};
  final List<Map<String, String>> _allTagUsers = const [
    {'id': 'u1', 'username': 'carlosinmotion'},
    {'id': 'u2', 'username': 'cosmic.route07'},
    {'id': 'u3', 'username': 'noahbright_11'},
    {'id': 'u4', 'username': 'rohanvibe'},
    {'id': 'u5', 'username': 'priya.vision'},
    {'id': 'u6', 'username': 'alex.orbit'},
    {'id': 'u7', 'username': 'devika.wave_25'},
    {'id': 'u8', 'username': 'grace.legacy'},
  ];

  PixabayTrack? _selectedTrack;
  Future<List<PixabayTrack>>? _musicFuture;
  late final PixabayMusicService _musicService;

  final Map<String, dynamic> _draftInput = <String, dynamic>{
    'userId': '',
    'postType': 'QUICKIE',
    'visibility': 'PUBLIC',
    'title': '',
    'description': '',
    'backgroundMusic': '',
    'collectionId': null,
    'taggedUserIds': <String>[],
    'images': <AssetEntity>[],
    'videos': <AssetEntity>[],
    'coverImage': null,
  };

  @override
  void initState() {
    super.initState();
    const apiKey = String.fromEnvironment('PIXABAY_API_KEY', defaultValue: '');
    _musicService = PixabayMusicService(apiKey);
    _initializeGallery();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _longDescriptionController.dispose();
    _musicSearchController.dispose();
    _tagSearchController.dispose();
    super.dispose();
  }

  Future<void> _initializeGallery() async {
    try {
      final hasPermission = await PermissionService.hasGalleryPermission();
      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _errorMessage =
              'Gallery permission is required to access your photos and videos.';
        });
        return;
      }

      setState(() {
        _hasPermission = true;
      });
      await _loadGalleryAssets();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gallery: $e';
      });
    }
  }

  Future<void> _loadGalleryAssets() async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: true,
      );
      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No photos or videos found in your gallery.';
        });
        return;
      }

      final recentAlbum = albums.first;
      final assets = await recentAlbum.getAssetListPaged(page: 0, size: 1000);
      final tab = widget.mode.tabs[_selectedTabIndex];
      final filtered =
          assets.where((asset) => asset.type == tab.mediaType).toList();

      ref.read(galleryAssetsNotifierProvider.notifier).setAssets(filtered);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gallery assets: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryAssets = ref.watch(galleryAssetsNotifierProvider);
    final selectedMedia = ref.watch(mediaSelectionNotifierProvider);

    return Scaffold(
      backgroundColor: kAppWhite,
      body: SafeArea(
        child: _buildStepContent(
          galleryAssets: galleryAssets,
          selectedMedia: selectedMedia,
        ),
      ),
    );
  }

  Widget _buildStepContent({
    required List<AssetEntity> galleryAssets,
    required List<AssetEntity> selectedMedia,
  }) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionError();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorMessage();
    }

    switch (_step) {
      case _UploadStep.select:
        return _buildSelectStep(galleryAssets, selectedMedia);
      case _UploadStep.editor:
        return _buildEditorStep(selectedMedia);
      case _UploadStep.details:
        return _buildDetailsStep(selectedMedia);
      case _UploadStep.music:
        return _buildMusicStep();
      case _UploadStep.longDescription:
        return _buildLongDescriptionStep();
      case _UploadStep.tagPeople:
        return _buildTagPeopleStep();
      case _UploadStep.tagSearch:
        return _buildTagSearchStep();
    }
  }

  Widget _buildSelectStep(
    List<AssetEntity> galleryAssets,
    List<AssetEntity> selectedMedia,
  ) {
    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Cancel',
          onLeadingTap: () => context.go(homeRoute),
          trailingLabel: selectedMedia.isNotEmpty ? 'Next' : null,
          onTrailingTap:
              selectedMedia.isNotEmpty
                  ? () {
                    setState(() {
                      _step = _UploadStep.editor;
                      _selectedPreviewIndex = 0;
                    });
                  }
                  : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildGalleryRecordToggle(),
        ),
        const SizedBox(height: 10),
        Expanded(
          child:
              galleryAssets.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MasonryGridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: galleryAssets.length,
                      itemBuilder: (context, index) {
                        final asset = galleryAssets[index];
                        if (widget.mode == UploadFlowMode.explorer) {
                          return _buildExplorerSelectionTile(asset);
                        }
                        return MediaThumbnail(
                          asset: asset,
                          onTap: () {
                            ref
                                .read(mediaSelectionNotifierProvider.notifier)
                                .toggleMedia(asset);
                          },
                        );
                      },
                    ),
                  ),
        ),
        _buildBottomTabs(),
      ],
    );
  }

  Widget _buildEditorStep(List<AssetEntity> selectedMedia) {
    if (widget.mode == UploadFlowMode.explorer) {
      return _buildExplorerEditorStep(selectedMedia);
    }

    if (selectedMedia.isEmpty) {
      return _buildFallbackInfo(
        'No media selected',
        'Please select media first.',
        onTap: () {
          setState(() {
            _step = _UploadStep.select;
          });
        },
      );
    }

    final selected =
        selectedMedia[_selectedPreviewIndex.clamp(0, selectedMedia.length - 1)];

    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Cancel',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.select;
            });
          },
          trailingLabel: 'Next',
          onTrailingTap: () {
            setState(() {
              _step = _UploadStep.details;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x33000000)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildEditedMediaPreview(selected),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildEditorTabBar(),
        const SizedBox(height: 10),
        if (_isFilterTab) _buildFilterStrip() else _buildEditTools(selected),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDetailsStep(List<AssetEntity> selectedMedia) {
    if (widget.mode == UploadFlowMode.explorer) {
      return _buildExplorerDetailsStep(selectedMedia);
    }

    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.editor;
            });
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('2. Add your title'),
                Text(
                  'This must explain what your video is about\n( Max 150 characters )',
                  style: kBodyMediumBlack,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  maxLength: 150,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'THE BEST hot chocolate in Paris',
                    hintStyle: kBodyMediumBlack.copyWith(color: kDarkGreay),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _focusedInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('3. Add a cover image ( Optional )'),
                Text(
                  'Opt for a clean, high-resolution cover image to\nstand out and capture attention at first glance.',
                  style: kBodyMediumBlack,
                ),
                const SizedBox(height: 8),
                _buildCoverImagePicker(selectedMedia),
                const SizedBox(height: 16),
                _buildSectionTitle('4. Select Background Music ( Optional )'),
                const SizedBox(height: 8),
                _buildDetailSelector(
                  text:
                      _selectedTrack == null
                          ? 'Pick a background track'
                          : '${_selectedTrack!.title} - ${_selectedTrack!.artist}',
                  onTap: () {
                    _loadMusic();
                    setState(() {
                      _step = _UploadStep.music;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('5. Add to a Collection ?'),
                const SizedBox(height: 8),
                _buildDetailSelector(
                  text: _selectedCollectionName,
                  onTap: _openCollectionSheet,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    setState(() {
                      _step = _UploadStep.longDescription;
                    });
                  },
                  child: Text(
                    '6. Add a longer description (Optional)  →',
                    style: kBodyMediumPurple.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _preparePostPayload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPurple,
                      foregroundColor: kAppWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Upload',
                      style: kHeadlineSmallWhite.copyWith(fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicStep() {
    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.details;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _musicSearchController,
            onChanged: (_) => _loadMusic(),
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: kAppLightGreay,
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final genre = _musicGenres[index];
              final isSelected = _selectedGenre == genre;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedGenre = isSelected ? '' : genre;
                  });
                  _loadMusic();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected ? kAppLightPurple : kAppWhite,
                    border: Border.all(color: kBorderGreay),
                  ),
                  child: Text(
                    genre,
                    style: isSelected ? kBodySmallPurple : kBodySmallBlack,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _musicGenres.length,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder<List<PixabayTrack>>(
            future: _musicFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
                  ),
                );
              }

              final tracks =
                  snapshot.data ?? PixabayMusicService.fallbackTracks;
              if (tracks.isEmpty) {
                return Center(
                  child: Text(
                    'No music found',
                    style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final isSelected = _selectedTrack?.id == track.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTrack = track;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? kAppPurple : Colors.transparent,
                          width: 1.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildMusicThumb(track),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kHeadlineSmallBlack,
                                ),
                                Text(
                                  track.artist,
                                  style: kBodyMediumBlack.copyWith(
                                    color: kAppLightBlack,
                                  ),
                                ),
                                Text(
                                  '${_formatDuration(track.duration)} | Used in ${track.usageCount} uploads',
                                  style: kBodySmallPurple,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemCount: tracks.length,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _step = _UploadStep.details;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppPurple,
                foregroundColor: kAppWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Continue',
                style: kHeadlineSmallWhite.copyWith(fontSize: 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLongDescriptionStep() {
    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.details;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a description', style: kHeadlineMediumBlack),
              Text(
                'This could help users understand your content better',
                style: kBodySmallPurple.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _longDescriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  border: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  focusedBorder: _focusedInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _step = _UploadStep.details;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppPurple,
                    foregroundColor: kAppWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Continue',
                    style: kHeadlineSmallWhite.copyWith(fontSize: 30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExplorerEditorStep(List<AssetEntity> selectedMedia) {
    if (selectedMedia.isEmpty) {
      return _buildFallbackInfo(
        'No media selected',
        'Please select media first.',
        onTap: () {
          setState(() {
            _step = _UploadStep.select;
          });
        },
      );
    }

    final first = selectedMedia.first;
    final second = selectedMedia.length > 1 ? selectedMedia[1] : null;

    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Cancel',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.select;
            });
          },
          trailingLabel: 'Next',
          onTrailingTap: () {
            setState(() {
              _step = _UploadStep.details;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreviewIndex = 0;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              _selectedPreviewIndex == 0
                                  ? kAppPurple
                                  : const Color(0x33000000),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildEditedMediaPreview(first),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (second == null) return;
                      setState(() {
                        _selectedPreviewIndex = 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              _selectedPreviewIndex == 1
                                  ? kAppPurple
                                  : const Color(0x33000000),
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child:
                          second == null
                              ? const ColoredBox(
                                color: kAppLightGreay,
                                child: Center(
                                  child: Icon(
                                    Icons.photo_library_outlined,
                                    color: kAppLightBlack,
                                  ),
                                ),
                              )
                              : _buildEditedMediaPreview(second),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildEditorTabBar(),
        const SizedBox(height: 10),
        if (_isFilterTab)
          _buildFilterStrip()
        else
          _buildExplorerEditTools(
            selectedMedia[_selectedPreviewIndex.clamp(
              0,
              selectedMedia.length - 1,
            )],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildExplorerDetailsStep(List<AssetEntity> selectedMedia) {
    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.editor;
            });
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. Confirm your uploads'),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedMedia.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 92,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildAssetImage(selectedMedia[index]),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('2. Give your post a title'),
                Text(
                  '( Max 150 characters )',
                  style: kBodySmallBlack.copyWith(color: kAppLightBlack),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  maxLength: 150,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'My trip to Paris',
                    hintStyle: kBodyMediumBlack.copyWith(color: kDarkGreay),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _focusedInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    setState(() {
                      _step = _UploadStep.tagPeople;
                    });
                  },
                  child: Text(
                    '3. Tag People in your post  →',
                    style: kBodyMediumPurple.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _preparePostPayload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPurple,
                      foregroundColor: kAppWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Upload',
                      style: kHeadlineSmallWhite.copyWith(fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagPeopleStep() {
    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.details;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            readOnly: true,
            onTap: () {
              setState(() {
                _step = _UploadStep.tagSearch;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search buddies',
              prefixIcon: const Icon(Icons.search),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tagged :',
                  style: kBodySmallPurple.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children:
                        _taggedUserIds.map((id) {
                          final user = _allTagUsers.firstWhere(
                            (u) => u['id'] == id,
                            orElse: () => {'id': id, 'username': id},
                          );
                          final username = user['username']!;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: kAppLightPurple,
                              child: Text(
                                username.substring(0, 1).toUpperCase(),
                                style: kBodySmallPurple.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(
                              username,
                              style: kBodyMediumBlack.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  _taggedUserIds.remove(id);
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _step = _UploadStep.details;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPurple,
                      foregroundColor: kAppWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSearchStep() {
    final query = _tagSearchController.text.trim().toLowerCase();
    final list =
        _allTagUsers.where((user) {
          if (query.isEmpty) return true;
          return user['username']!.toLowerCase().contains(query);
        }).toList();

    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          onLeadingTap: () {
            setState(() {
              _step = _UploadStep.tagPeople;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _tagSearchController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search buddies',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _tagSearchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final user = list[index];
              final id = user['id']!;
              final username = user['username']!;
              final selected = _taggedUserIds.contains(id);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: selected ? kAppPurple : kAppLightPurple,
                  child: Text(
                    username.substring(0, 1).toUpperCase(),
                    style: (selected ? kBodySmallWhite : kBodySmallPurple)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(username, style: kBodyMediumBlack),
                onTap: () {
                  setState(() {
                    if (selected) {
                      _taggedUserIds.remove(id);
                    } else {
                      _taggedUserIds.add(id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopActionBar({
    required String leadingLabel,
    required VoidCallback onLeadingTap,
    String? trailingLabel,
    VoidCallback? onTrailingTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _buildActionChip(
            label: leadingLabel,
            icon: Icons.arrow_back,
            onTap: onLeadingTap,
          ),
          const Spacer(),
          if (trailingLabel != null)
            _buildActionChip(
              label: trailingLabel,
              icon: Icons.arrow_forward,
              onTap: onTrailingTap ?? () {},
              filled: true,
            ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? kAppPurple : kAppLightGreay,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: filled ? kAppWhite : kAppLightBlack),
            const SizedBox(width: 6),
            Text(
              label,
              style: (filled ? kBodyMediumWhite : kBodyMediumBlack).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryRecordToggle() {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleItem('Gallery', true)),
          Expanded(child: _buildToggleItem('Record', false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active ? kAppPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          style: (active ? kBodyMediumWhite : kBodyMediumBlack).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kBorderGreay)),
      ),
      child: Row(
        children: List.generate(
          widget.mode.tabs.length,
          (index) => _buildBottomTab(widget.mode.tabs[index].label, index),
        ),
      ),
    );
  }

  Widget _buildBottomTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          ref.read(mediaSelectionNotifierProvider.notifier).clearSelection();
          _loadGalleryAssets();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    isSelected
                        ? kHeadlineSmallPurple
                        : kHeadlineSmallBlack.copyWith(
                          color: kAppBlack,
                          fontWeight: FontWeight.w500,
                        ),
              ),
              const SizedBox(height: 4),
              if (isSelected)
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: kAppPurple,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorTabBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _isFilterTab = true;
              });
            },
            child: _buildEditorTabLabel('Filters', _isFilterTab),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _isFilterTab = false;
              });
            },
            child: _buildEditorTabLabel('Edit', !_isFilterTab),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorTabLabel(String label, bool selected) {
    return Column(
      children: [
        Text(
          label,
          style: selected ? kHeadlineSmallPurple : kHeadlineSmallBlack,
        ),
        if (selected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 42,
            height: 2,
            color: kAppPurple,
          ),
      ],
    );
  }

  Widget _buildFilterStrip() {
    const presets = [
      {'id': 'none', 'label': 'Original'},
      {'id': 'vintage', 'label': 'Vintage'},
      {'id': 'cinematic', 'label': 'Cinematic'},
      {'id': 'saturated', 'label': 'Saturated'},
      {'id': 'brighten', 'label': 'Brighten'},
      {'id': 'vignette', 'label': 'Vignette'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = presets[index];
          final isSelected = _selectedFilterId == item['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilterId = item['id']!;
              });
            },
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: kAppLightGreay,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? kAppPurple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(item['label']!, style: kBodySmallBlack),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: presets.length,
      ),
    );
  }

  Widget _buildEditTools(AssetEntity selectedAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEditAction(
                icon: Icons.content_cut,
                onTap: () => _cropCurrentAsset(selectedAsset),
              ),
              _buildEditAction(
                icon: Icons.crop,
                onTap: () => _rotateCurrentAsset(selectedAsset),
              ),
              _buildEditAction(
                icon: Icons.flip,
                onTap: () => _flipCurrentAsset(selectedAsset),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: kAppLightGreay,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.brightness_6, color: kAppLightBlack),
                Expanded(
                  child: Slider(
                    activeColor: kAppPurple,
                    value: _brightness,
                    min: -0.4,
                    max: 0.4,
                    onChanged: (value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorerEditTools(AssetEntity selectedAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLabeledEditAction(
            icon: Icons.wb_sunny_outlined,
            label: 'Brightness',
            onTap: () {
              setState(() {
                _brightness = (_brightness + 0.05).clamp(-0.4, 0.4);
              });
            },
          ),
          _buildLabeledEditAction(
            icon: Icons.contrast,
            label: 'Contrast',
            onTap: () {
              setState(() {
                _brightness = (_brightness - 0.05).clamp(-0.4, 0.4);
              });
            },
          ),
          _buildLabeledEditAction(
            icon: Icons.diamond_outlined,
            label: 'Sharpen',
            onTap: () {
              setState(() {
                _selectedFilterId = 'cinematic';
              });
            },
          ),
          _buildLabeledEditAction(
            icon: Icons.opacity_outlined,
            label: 'Saturation',
            onTap: () {
              setState(() {
                _saturation = _saturation >= 1.3 ? 0.8 : _saturation + 0.1;
              });
            },
          ),
          _buildLabeledEditAction(
            icon: Icons.crop,
            label: 'Crop',
            onTap: () => _cropCurrentAsset(selectedAsset),
          ),
          _buildLabeledEditAction(
            icon: Icons.rotate_right,
            label: 'Rotate',
            onTap: () => _rotateCurrentAsset(selectedAsset),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledEditAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: kAppLightBlack, size: 22),
            const SizedBox(height: 4),
            Text(label, style: kBodySmallBlack),
          ],
        ),
      ),
    );
  }

  Widget _buildEditAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(icon, color: kAppLightBlack),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: kBodyMediumPurple.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildDetailSelector({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderGreay),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: kAppPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImagePicker(List<AssetEntity> selectedMedia) {
    final coverAsset = selectedMedia.isNotEmpty ? selectedMedia.first : null;
    return InkWell(
      onTap: () {
        if (coverAsset == null) return;
        _draftInput['coverImage'] = coverAsset;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover image selected'),
            backgroundColor: kAppPurple,
          ),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderGreay),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 34, color: kAppPurple),
            Text('Upload Image', style: kBodySmallPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicThumb(PixabayTrack track) {
    if (track.coverUrl.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note, color: kAppLightBlack),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        track.coverUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 64,
            height: 64,
            color: kAppLightGreay,
            child: const Icon(Icons.music_note, color: kAppLightBlack),
          );
        },
      ),
    );
  }

  Widget _buildExplorerSelectionTile(AssetEntity asset) {
    final selectedMedia = ref.watch(mediaSelectionNotifierProvider);
    final selectedIndex = selectedMedia.indexWhere(
      (item) => item.id == asset.id,
    );
    final isSelected = selectedIndex >= 0;
    final displayOrder = selectedMedia.length - selectedIndex;

    return GestureDetector(
      onTap: () {
        ref.read(mediaSelectionNotifierProvider.notifier).toggleMedia(asset);
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0x22000000) : Colors.transparent,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildAssetImage(asset),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF212121),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$displayOrder',
                        style: kBodySmallWhite.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditedMediaPreview(AssetEntity asset) {
    final matrix = _buildColorMatrix(_selectedFilterId, _contrast, _brightness);
    final quarterTurns = _rotationTurns[asset.id] ?? 0;
    final isFlipped = _flipX[asset.id] ?? false;

    final base =
        _editedFiles[asset.id] != null
            ? Image.file(_editedFiles[asset.id]!, fit: BoxFit.cover)
            : _buildAssetImage(asset);

    final transform =
        Matrix4.identity()
          ..multiply(Matrix4.diagonal3Values(isFlipped ? -1.0 : 1.0, 1.0, 1.0))
          ..rotateZ(quarterTurns * (math.pi / 2));

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: base,
      ),
    );
  }

  List<double> _buildColorMatrix(
    String preset,
    double contrast,
    double brightness,
  ) {
    final brightnessValue = brightness * 255;
    final saturation = _saturation;
    if (preset == 'vintage') {
      return <double>[
        0.9 * contrast,
        0.1,
        0.0,
        0,
        brightnessValue + 10,
        0.0,
        0.8 * contrast,
        0.1,
        0,
        brightnessValue + 6,
        0.0,
        0.1,
        0.7 * contrast,
        0,
        brightnessValue,
        0,
        0,
        0,
        1,
        0,
      ];
    }
    if (preset == 'cinematic') {
      return <double>[
        1.15 * contrast,
        -0.05,
        -0.05,
        0,
        brightnessValue,
        -0.05,
        1.15 * contrast,
        -0.05,
        0,
        brightnessValue,
        -0.05,
        -0.05,
        1.15 * contrast,
        0,
        brightnessValue,
        0,
        0,
        0,
        1,
        0,
      ];
    }
    if (preset == 'saturated') {
      return <double>[
        1.2 * contrast * saturation,
        0,
        0,
        0,
        brightnessValue,
        0,
        1.2 * contrast * saturation,
        0,
        0,
        brightnessValue,
        0,
        0,
        1.2 * contrast * saturation,
        0,
        brightnessValue,
        0,
        0,
        0,
        1,
        0,
      ];
    }
    if (preset == 'brighten') {
      return <double>[
        contrast,
        0,
        0,
        0,
        brightnessValue + 35,
        0,
        contrast,
        0,
        0,
        brightnessValue + 35,
        0,
        0,
        contrast,
        0,
        brightnessValue + 35,
        0,
        0,
        0,
        1,
        0,
      ];
    }
    if (preset == 'vignette') {
      return <double>[
        0.9 * contrast,
        0,
        0,
        0,
        brightnessValue - 8,
        0,
        0.9 * contrast,
        0,
        0,
        brightnessValue - 8,
        0,
        0,
        0.9 * contrast,
        0,
        brightnessValue - 8,
        0,
        0,
        0,
        1,
        0,
      ];
    }
    return <double>[
      contrast * saturation,
      0,
      0,
      0,
      brightnessValue,
      0,
      contrast * saturation,
      0,
      0,
      brightnessValue,
      0,
      0,
      contrast * saturation,
      0,
      brightnessValue,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  Widget _buildAssetImage(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(1600, 1600)),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        return const ColoredBox(
          color: kAppLightGreay,
          child: Center(
            child: Icon(Icons.image_not_supported, color: kAppLightBlack),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final tab = widget.mode.tabs[_selectedTabIndex];
    final isImageTab = tab.mediaType == AssetType.image;
    return Center(
      child: Text(
        isImageTab ? 'No Photos Found' : 'No Videos Found',
        style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
      ),
    );
  }

  Widget _buildFallbackInfo(
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: kHeadlineSmallBlack),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
          ),
          if (onTap != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onTap, child: const Text('Go back')),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionError() {
    return _buildFallbackInfo(
      'Gallery Permission Required',
      _errorMessage,
      onTap: () async => PermissionService.openAppSettings(),
    );
  }

  Widget _buildErrorMessage() {
    return _buildFallbackInfo(
      'Error Loading Gallery',
      _errorMessage,
      onTap: _initializeGallery,
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kBorderGreay),
    );
  }

  OutlineInputBorder _focusedInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: kAppPurple),
    );
  }

  Future<void> _cropCurrentAsset(AssetEntity asset) async {
    final source = _editedFiles[asset.id] ?? await asset.file;
    if (source == null) return;
    final result = await ImageCropper().cropImage(sourcePath: source.path);
    if (result == null) return;
    setState(() {
      _editedFiles[asset.id] = File(result.path);
    });
  }

  void _rotateCurrentAsset(AssetEntity asset) {
    setState(() {
      _rotationTurns[asset.id] = ((_rotationTurns[asset.id] ?? 0) + 1) % 4;
    });
  }

  void _flipCurrentAsset(AssetEntity asset) {
    setState(() {
      _flipX[asset.id] = !(_flipX[asset.id] ?? false);
    });
  }

  void _loadMusic() {
    setState(() {
      _musicFuture = _musicService.searchTracks(
        query: _musicSearchController.text.trim(),
        category: _selectedGenre,
      );
    });
  }

  Future<void> _openCollectionSheet() async {
    final selectedMedia = ref.read(mediaSelectionNotifierProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kAppWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int localStep = 0;
        final controller = TextEditingController(text: _collectionDraftName);
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget content;
            if (localStep == 0) {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  ..._collections.map((collection) {
                    return ListTile(
                      title: Text(collection['name']!, style: kBodyMediumBlack),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        if (collection['id'] == 'create_new') {
                          setModalState(() => localStep = 1);
                          return;
                        }
                        setState(() {
                          _selectedCollectionId = collection['id'];
                          _selectedCollectionName = collection['name']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              );
            } else if (localStep == 1) {
              content = Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create a New Collection', style: kHeadlineSmallBlack),
                    const SizedBox(height: 4),
                    Text(
                      'What would you like to name it ?',
                      style: kBodySmallPurple.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Arjun's Day Out",
                        border: _inputBorder(),
                        enabledBorder: _inputBorder(),
                        focusedBorder: _focusedInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _collectionDraftName = controller.text.trim();
                          setModalState(() => localStep = 2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAppPurple,
                          foregroundColor: kAppWhite,
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final preview =
                  selectedMedia.isEmpty ? null : selectedMedia.first;
              content = Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload your first video', style: kHeadlineSmallBlack),
                    Text(
                      "Let's start your collection",
                      style: kBodySmallPurple.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 130,
                      height: 160,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: kAppLightGreay,
                      ),
                      child:
                          preview == null
                              ? const Icon(
                                Icons.video_library,
                                color: kAppLightBlack,
                              )
                              : _buildAssetImage(preview),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Please Note: You've picked a vertical video, so all future uploads in this collection must also be vertical.",
                      style: kBodySmallBlack,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name =
                              _collectionDraftName.isEmpty
                                  ? 'New Collection'
                                  : _collectionDraftName;
                          setState(() {
                            _selectedCollectionId =
                                'new_${DateTime.now().millisecondsSinceEpoch}';
                            _selectedCollectionName = name;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAppPurple,
                          foregroundColor: kAppWhite,
                        ),
                        child: const Text('Confirm and Continue'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SafeArea(child: content);
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _preparePostPayload() {
    final user = ref.read(userNotifierProvider);
    final selectedMedia = ref.read(mediaSelectionNotifierProvider);
    final tab = widget.mode.tabs[_selectedTabIndex];

    _draftInput['userId'] = user.userId ?? '';
    _draftInput['postType'] = tab.postType;
    _draftInput['title'] = _titleController.text.trim();
    _draftInput['description'] = _longDescriptionController.text.trim();
    _draftInput['backgroundMusic'] = _selectedTrack?.title ?? '';
    _draftInput['collectionId'] = _selectedCollectionId;
    _draftInput['taggedUserIds'] = _taggedUserIds.toList();
    _draftInput['images'] =
        tab.mediaType == AssetType.image ? selectedMedia : <AssetEntity>[];
    _draftInput['videos'] =
        tab.mediaType == AssetType.video ? selectedMedia : <AssetEntity>[];
    _draftInput['coverImage'] =
        selectedMedia.isNotEmpty ? selectedMedia.first : null;

    final imageCount = (_draftInput['images'] as List).length;
    final videoCount = (_draftInput['videos'] as List).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payload ready: postType=${_draftInput['postType']}, images=$imageCount, videos=$videoCount',
        ),
        backgroundColor: kAppPurple,
      ),
    );
  }
}
