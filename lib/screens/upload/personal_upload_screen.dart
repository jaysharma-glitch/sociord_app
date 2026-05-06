import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:path/path.dart' as p;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/provider/media_selection_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/services/collection_service.dart';
import 'package:sociord/services/post_service.dart';
import 'package:sociord/services/user_service.dart';
import 'package:sociord/services/permission_service.dart';
import 'package:sociord/services/pixabay_music_service.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/media_thumbnail.dart';
import 'package:video_player/video_player.dart';

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

enum _ExplorerEditTool {
  brightness,
  contrast,
  sharpen,
  saturation,
  crop,
  rotate,
}

enum _CreatorEditTool {
  cut,
  crop,
  rotate,
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
              mediaType: AssetType.video,
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
  static const LinearGradient _brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF822FAF), Color(0xFFFA7921)],
  );

  static const List<String> _musicGenres = <String>[
    'Romantic',
    'Upbeat',
    'Techno',
    'Dance',
    'Mystic',
  ];
  static const List<String> _filterPreviewUrls = <String>[
    'https://sociord-app.b-cdn.net/assets/filtersImage/Vintage.jpg',
    'https://sociord-app.b-cdn.net/assets/filtersImage/Cinematic.jpg',
    'https://sociord-app.b-cdn.net/assets/filtersImage/Saturated.jpg',
    'https://sociord-app.b-cdn.net/assets/filtersImage/Brighten.jpg',
    'https://sociord-app.b-cdn.net/assets/filtersImage/Vignette.jpg',
  ];

  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  bool _isRecordMode = false;
  int _selectedTabIndex = 0;
  _UploadStep _step = _UploadStep.select;
  int _selectedPreviewIndex = 0;
  bool _isFilterTab = true;
  final Map<String, String> _selectedFilterByAssetId = <String, String>{};
  _ExplorerEditTool _selectedExplorerTool = _ExplorerEditTool.brightness;
  _CreatorEditTool _selectedCreatorTool = _CreatorEditTool.cut;
  final Map<String, double> _brightnessByAssetId = <String, double>{};
  final Map<String, double> _contrastByAssetId = <String, double>{};
  final Map<String, double> _saturationByAssetId = <String, double>{};
  final Map<String, double> _sharpenByAssetId = <String, double>{};
  String _selectedGenre = '';
  String _selectedCollectionName = 'No';
  String? _selectedCollectionId;
  String _collectionDraftName = '';
  bool _showTitleRequiredError = false;
  bool _showExplorerTitleRequiredError = false;
  bool _isSearchingTagUsers = false;
  List<Map<String, String>> _tagSearchResults = const [];
  Timer? _tagSearchDebounce;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _longDescriptionController =
      TextEditingController();
  final TextEditingController _musicSearchController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();
  TextEditingController? _collectionNameController;

  final Map<String, File> _editedFiles = <String, File>{};
  final Map<String, VideoPlayerController> _videoControllers =
      <String, VideoPlayerController>{};
  final Map<String, BoxFit> _videoFitByAssetId = <String, BoxFit>{};
  final Map<String, double> _videoZoomByAssetId = <String, double>{};
  final Map<String, RangeValues> _videoCutRangeByAssetId =
      <String, RangeValues>{};
  final Map<String, int> _rotationTurns = <String, int>{};
  final Map<String, bool> _flipX = <String, bool>{};
  final Set<String> _taggedUserIds = <String>{};
  final Map<String, String> _taggedUserNames = <String, String>{};
  final Map<String, String> _taggedUserAvatars = <String, String>{};
  final UserService _userService = UserService();
  final CollectionService _collectionService = CollectionService();
  final PostService _postService = PostService();
  int _collectionSheetStep = 0;
  String? _selectedCollectionPreviewAssetId;
  List<Map<String, String>> _creatorCollections = <Map<String, String>>[];
  bool _isCreatingCollection = false;
  bool _isUploadingPost = false;
  static const List<Map<String, dynamic>> _explorerEditTools =
      <Map<String, dynamic>>[
        {
          'tool': _ExplorerEditTool.brightness,
          'title': 'Brightness',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Brightness.png',
        },
        {
          'tool': _ExplorerEditTool.contrast,
          'title': 'Contrast',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Contrast.png',
        },
        {
          'tool': _ExplorerEditTool.sharpen,
          'title': 'Sharpen',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Sharpen.png',
        },
        {
          'tool': _ExplorerEditTool.saturation,
          'title': 'Saturation',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Saturation.png',
        },
        {
          'tool': _ExplorerEditTool.crop,
          'title': 'Crop',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Crop.png',
        },
        {
          'tool': _ExplorerEditTool.rotate,
          'title': 'Rotate',
          'imageUrl': 'https://sociord-app.b-cdn.net/assets/edit/Rotate.png',
        },
      ];

  PixabayTrack? _selectedTrack;
  Future<List<PixabayTrack>>? _musicFuture;
  late final PixabayMusicService _musicService;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedCoverImageFile;

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
    _tagSearchDebounce?.cancel();
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _titleController.dispose();
    _longDescriptionController.dispose();
    _musicSearchController.dispose();
    _tagSearchController.dispose();
    _collectionNameController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _primeFilterPreviewCache();
  }

  Future<void> _initializeGallery() async {
    try {
      final permissionState = await PhotoManager.requestPermissionExtend();
      final hasPermission = permissionState.isAuth;
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
                    _prepareVideoPreviewIfNeeded(selectedMedia.first);
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
              child: Stack(
                children: [
                  Positioned.fill(child: _buildEditedMediaPreview(selected)),
                  if (selected.type == AssetType.video)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 12,
                      child: Center(child: _buildCreatorPlayPauseButton(selected)),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (selectedMedia.length > 1) ...[
          const SizedBox(height: 8),
          _buildCreatorSelectedMediaStrip(selectedMedia),
        ],
        const SizedBox(height: 8),
        _buildEditorTabBar(),
        const SizedBox(height: 10),
        if (_isFilterTab)
          _buildFilterStrip(selected)
        else
          _buildEditTools(selected),
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
                RichText(
                  text: TextSpan(
                    style: kBodyMediumBlack.copyWith(fontFamily: 'Lato'),
                    children: [
                      const TextSpan(
                        text: 'This must explain what your video is about\n',
                      ),
                      TextSpan(
                        text: '( Max 150 characters )',
                        style: kBodyMediumBlack.copyWith(
                          fontFamily: 'Lato',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  maxLength: 150,
                  onChanged: (value) {
                    if (_showTitleRequiredError && value.trim().isNotEmpty) {
                      setState(() {
                        _showTitleRequiredError = false;
                      });
                    }
                  },
                  style: kBodyMediumBlack.copyWith(fontFamily: 'Gibson'),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'THE BEST hot chocolate in Paris',
                    hintStyle: kBodyMediumBlack.copyWith(
                      color: kDarkGreay,
                      fontFamily: 'Gibson',
                    ),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _focusedInputBorder(),
                  ),
                ),
                if (_showTitleRequiredError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Title is required',
                      style: kBodySmallBlack.copyWith(
                        color: Colors.red,
                        fontFamily: 'Gibson',
                        fontWeight: FontWeight.w600,
                      ),
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
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gibson',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploadingPost ? null : _preparePostPayload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPurple,
                      foregroundColor: kAppWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isUploadingPost
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kAppWhite,
                                ),
                              ),
                            )
                            : Text(
                              'Upload',
                              style: kHeadlineSmallWhite.copyWith(
                                fontSize: 18,
                                fontFamily: 'Gibson',
                                fontWeight: FontWeight.w600,
                              ),
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
                style: kHeadlineSmallWhite.copyWith(
                  fontSize: 30,
                  fontFamily: 'Lato',
                ),
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
                    style: kHeadlineSmallWhite.copyWith(
                      fontSize: 18,
                      fontFamily: 'Gibson',
                      fontWeight: FontWeight.w600,
                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF4D9BFF), width: 3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildEditedMediaPreview(selected),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      child: Container(
                        height: 36,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0xCCFFFFFF),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedMedia.length > 1) ...[
          const SizedBox(height: 8),
          _buildExplorerSelectedMediaStrip(selectedMedia),
        ],
        const SizedBox(height: 8),
        _buildExplorerEditorTabBarWithSize(selected),
        const SizedBox(height: 10),
        if (_isFilterTab)
          _buildFilterStrip(selected)
        else
          _buildExplorerEditTools(selected),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildExplorerSelectedMediaStrip(List<AssetEntity> selectedMedia) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: selectedMedia.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final asset = selectedMedia[index];
          final isSelected = _selectedPreviewIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPreviewIndex = index;
              });
            },
            child: Container(
              width: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? kAppPurple : const Color(0x33000000),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: _buildEditedMediaPreview(asset),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatorSelectedMediaStrip(List<AssetEntity> selectedMedia) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: selectedMedia.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final asset = selectedMedia[index];
          final isSelected = _selectedPreviewIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPreviewIndex = index;
              });
              _prepareVideoPreviewIfNeeded(asset);
            },
            child: Container(
              width: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? kAppPurple : const Color(0x33000000),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: _buildAssetImage(asset),
            ),
          );
        },
      ),
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
                Text(
                  '1. Confirm your uploads',
                  style: kBodyMediumPurple.copyWith(
                    fontFamily: 'Gibson',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedMedia.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 110,
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
                Text(
                  '2. Give your post a title',
                  style: kBodyMediumPurple.copyWith(
                    fontFamily: 'Gibson',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '( Max 150 characters )',
                  style: kBodySmallBlack.copyWith(
                    color: kAppBlack,
                    fontFamily: 'Lato',
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  maxLength: 150,
                  onChanged: (value) {
                    if (_showExplorerTitleRequiredError &&
                        value.trim().isNotEmpty) {
                      setState(() {
                        _showExplorerTitleRequiredError = false;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'My trip to Paris',
                    hintStyle: kBodyMediumBlack.copyWith(color: kDarkGreay),
                    border: _inputBorder(),
                    enabledBorder: _inputBorder(),
                    focusedBorder: _focusedInputBorder(),
                  ),
                ),
                if (_showExplorerTitleRequiredError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Title is required',
                      style: kBodySmallBlack.copyWith(
                        color: Colors.red,
                        fontFamily: 'Gibson',
                        fontWeight: FontWeight.w600,
                      ),
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
                      fontFamily: 'Gibson',
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploadingPost ? null : _preparePostPayload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppPurple,
                      foregroundColor: kAppWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isUploadingPost
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  kAppWhite,
                                ),
                              ),
                            )
                            : Text(
                              'Upload',
                              style: kHeadlineSmallWhite.copyWith(
                                fontSize: 18,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w600,
                              ),
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
          leadingTextStyle: kBodyMediumBlack.copyWith(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
          ),
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
              _searchBuddies(_tagSearchController.text);
            },
            decoration: InputDecoration(
              hintText: 'Search buddies',
              hintStyle: kBodyMediumBlack.copyWith(
                fontFamily: 'Gibson',
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: kAppLightGreay,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              prefixIcon: const Icon(Icons.search, size: 34),
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
                          final username = _taggedUserNames[id] ?? id;
                          final avatarUrl = _taggedUserAvatars[id] ?? '';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                _buildBuddyAvatar(avatarUrl, username),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    username,
                                    style: kHeadlineSmallBlack.copyWith(
                                      fontFamily: 'Gibson',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _taggedUserIds.remove(id);
                                      _taggedUserAvatars.remove(id);
                                      _taggedUserNames.remove(id);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 38,
                                    color: kAppBlack,
                                  ),
                                ),
                              ],
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
                    child: Text(
                      'Continue',
                      style: kBodyMediumWhite.copyWith(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
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
    final query = _tagSearchController.text.trim();

    return Column(
      children: [
        _buildTopActionBar(
          leadingLabel: 'Go back',
          leadingTextStyle: kBodyMediumBlack.copyWith(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
          ),
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
            onChanged: _onTagSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search buddies',
              hintStyle: kBodyMediumBlack.copyWith(
                fontFamily: 'Gibson',
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: kAppLightGreay,
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              prefixIcon: const Icon(Icons.search, size: 30),
              suffixIcon: IconButton(
                onPressed: () {
                  _tagSearchController.clear();
                  _onTagSearchChanged('');
                },
                icon: const Icon(Icons.close, size: 32, color: kAppBlack),
              ),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _focusedInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child:
              query.length < 2
                  ? Center(
                    child: Text(
                      'Type at least 2 letters to search',
                      style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
                    ),
                  )
                  : _isSearchingTagUsers
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
                    ),
                  )
                  : _tagSearchResults.isEmpty
                  ? Center(
                    child: Text(
                      'No users found',
                      style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _tagSearchResults.length,
                    itemBuilder: (context, index) {
                      final user = _tagSearchResults[index];
                      final id = user['id']!;
                      final username = user['username']!;
                      final selected = _taggedUserIds.contains(id);
                      final avatarUrl = user['profilePic'] ?? '';
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _taggedUserIds.remove(id);
                              _taggedUserAvatars.remove(id);
                              _taggedUserNames.remove(id);
                            } else {
                              _taggedUserIds.add(id);
                              _taggedUserNames[id] = username;
                              _taggedUserAvatars[id] = avatarUrl;
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              _buildBuddyAvatar(avatarUrl, username),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  username,
                                  style: kHeadlineSmallBlack.copyWith(
                                    fontFamily: 'Gibson',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle,
                                  color: kAppPurple,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  void _onTagSearchChanged(String value) {
    _tagSearchDebounce?.cancel();
    _tagSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchBuddies(value);
    });
    setState(() {});
  }

  Future<void> _searchBuddies(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 2) {
      if (!mounted) return;
      setState(() {
        _isSearchingTagUsers = false;
        _tagSearchResults = const [];
      });
      return;
    }

    setState(() {
      _isSearchingTagUsers = true;
    });

    try {
      final userId = ref.read(userNotifierProvider).userId;
      final results = await _userService.searchUsers(
        query: trimmedQuery,
        excludeUserId: userId,
      );
      if (!mounted) return;
      setState(() {
        _tagSearchResults = results;
        _isSearchingTagUsers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tagSearchResults = const [];
        _isSearchingTagUsers = false;
      });
    }
  }

  Widget _buildBuddyAvatar(String avatarUrl, String username) {
    final hasUrl = avatarUrl.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        height: 48,
        color: kAppLightGreay,
        child:
            hasUrl
                ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildAvatarFallback(username),
                )
                : _buildAvatarFallback(username),
      ),
    );
  }

  Widget _buildAvatarFallback(String username) {
    final initial = username.isEmpty ? '?' : username.substring(0, 1);
    return Center(
      child: Text(
        initial.toUpperCase(),
        style: kBodyMediumPurple.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTopActionBar({
    required String leadingLabel,
    required VoidCallback onLeadingTap,
    String? trailingLabel,
    VoidCallback? onTrailingTap,
    TextStyle? leadingTextStyle,
    TextStyle? trailingTextStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _buildActionChip(
            label: leadingLabel,
            icon: Icons.arrow_back,
            onTap: onLeadingTap,
            textStyle: leadingTextStyle,
          ),
          const Spacer(),
          if (trailingLabel != null)
            _buildActionChip(
              label: trailingLabel,
              icon: Icons.arrow_forward,
              onTap: onTrailingTap ?? () {},
              filled: true,
              textStyle: trailingTextStyle,
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
    TextStyle? textStyle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? null : kAppLightGreay,
          gradient: filled ? _brandGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              filled
                  ? const [
                    BoxShadow(
                      color: Color(0x22000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: filled ? kAppWhite : kAppLightBlack),
            const SizedBox(width: 6),
            Text(
              label,
              style:
                  textStyle ??
                  (filled ? kBodyMediumWhite : kBodyMediumBlack).copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lato',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryRecordToggle() {
    final isExplorer = widget.mode == UploadFlowMode.explorer;
    final secondaryLabel = isExplorer ? 'Capture' : 'Record';
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleItem(
              'Gallery',
              !_isRecordMode,
              onTap: () {
                setState(() {
                  _isRecordMode = false;
                });
              },
            ),
          ),
          Expanded(
            child: _buildToggleItem(
              secondaryLabel,
              _isRecordMode,
              onTap: isExplorer ? _handleCaptureTap : _handleRecordTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool active, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
              fontFamily: 'Gibson',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRecordTap() async {
    setState(() {
      _isRecordMode = true;
    });

    final hasCameraPermission = await PermissionService.requestCameraPermission();
    if (!hasCameraPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to record a video'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    final XFile? capturedVideo = await _imagePicker.pickVideo(
      source: ImageSource.camera,
    );
    if (!mounted) return;

    if (capturedVideo == null) {
      setState(() {
        _isRecordMode = false;
      });
      return;
    }

    await PhotoManager.editor.saveVideo(File(capturedVideo.path));
    await _loadGalleryAssets();
    await _selectCapturedAssetByPath(capturedVideo.path);
    setState(() {
      _isRecordMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video recorded. Select it from gallery to continue.'),
        backgroundColor: kAppPurple,
      ),
    );
  }

  Future<void> _handleCaptureTap() async {
    setState(() {
      _isRecordMode = true;
    });

    final hasCameraPermission = await PermissionService.requestCameraPermission();
    if (!hasCameraPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to capture media'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    final currentTab = widget.mode.tabs[_selectedTabIndex];
    if (currentTab.mediaType == AssetType.video) {
      final XFile? capturedVideo = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (!mounted) return;
      if (capturedVideo == null) {
        setState(() {
          _isRecordMode = false;
        });
        return;
      }
      await PhotoManager.editor.saveVideo(File(capturedVideo.path));
      await _loadGalleryAssets();
      await _selectCapturedAssetByPath(capturedVideo.path);
      setState(() {
        _isRecordMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video captured. Select it from gallery to continue.'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    final XFile? capturedImage = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (!mounted) return;
    if (capturedImage == null) {
      setState(() {
        _isRecordMode = false;
      });
      return;
    }
    await PhotoManager.editor.saveImageWithPath(capturedImage.path);
    await _loadGalleryAssets();
    await _selectCapturedAssetByPath(capturedImage.path);
    setState(() {
      _isRecordMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo captured. Select it from gallery to continue.'),
        backgroundColor: kAppPurple,
      ),
    );
  }

  Future<void> _selectCapturedAssetByPath(String capturedPath) async {
    final currentTab = widget.mode.tabs[_selectedTabIndex];
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
      hasAll: true,
    );
    if (albums.isEmpty) return;

    final recentAlbum = albums.first;
    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 300);
    final filtered =
        assets.where((asset) => asset.type == currentTab.mediaType).toList();
    if (filtered.isEmpty) return;

    final capturedName = p.basename(capturedPath);
    AssetEntity? matchedAsset;

    for (final asset in filtered.take(60)) {
      final file = await asset.file;
      if (file == null) continue;
      if (file.path == capturedPath || p.basename(file.path) == capturedName) {
        matchedAsset = asset;
        break;
      }
    }

    if (matchedAsset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Captured media saved. Please select it manually.'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    ref.read(mediaSelectionNotifierProvider.notifier).addMedia(matchedAsset);
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
              if (isSelected)
                _buildGradientText(
                  title,
                  kHeadlineSmallPurple.copyWith(fontFamily: 'Gibson'),
                )
              else
                Text(
                  title,
                  style: kHeadlineSmallBlack.copyWith(
                    color: kAppBlack,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Gibson',
                  ),
                ),
              const SizedBox(height: 4),
              if (isSelected)
                Container(
                  width: 64,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: _brandGradient,
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
        if (selected)
          _buildGradientText(
            label,
            kHeadlineSmallPurple.copyWith(fontFamily: 'Lato'),
          )
        else
          Text(
            label,
            style: kHeadlineSmallBlack.copyWith(fontFamily: 'Lato'),
          ),
        if (selected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 64,
            height: 2,
            decoration: BoxDecoration(
              gradient: _brandGradient,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }

  Widget _buildGradientText(String text, TextStyle style) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => _brandGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
      child: Text(text, style: style.copyWith(color: kAppWhite)),
    );
  }

  Widget _buildFilterStrip(AssetEntity selectedAsset) {
    const presets = <Map<String, String>>[
      {'id': 'none', 'label': 'Original', 'imageUrl': ''},
      {
        'id': 'vintage',
        'label': 'Vintage',
        'imageUrl': 'https://sociord-app.b-cdn.net/assets/filtersImage/Vintage.jpg',
      },
      {
        'id': 'cinematic',
        'label': 'Cinematic',
        'imageUrl':
            'https://sociord-app.b-cdn.net/assets/filtersImage/Cinematic.jpg',
      },
      {
        'id': 'saturated',
        'label': 'Saturated',
        'imageUrl':
            'https://sociord-app.b-cdn.net/assets/filtersImage/Saturated.jpg',
      },
      {
        'id': 'brighten',
        'label': 'Brighten',
        'imageUrl':
            'https://sociord-app.b-cdn.net/assets/filtersImage/Brighten.jpg',
      },
      {
        'id': 'vignette',
        'label': 'Vignette',
        'imageUrl':
            'https://sociord-app.b-cdn.net/assets/filtersImage/Vignette.jpg',
      },
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = presets[index];
          final selectedFilterId =
              _selectedFilterByAssetId[selectedAsset.id] ?? 'none';
          final isSelected = selectedFilterId == item['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilterByAssetId[selectedAsset.id] = item['id']!;
              });
            },
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: kAppLightGreay,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? kAppPurple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child:
                      item['id'] == 'none'
                          ? const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: kAppLightBlack,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: item['imageUrl']!,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration.zero,
                              placeholder:
                                  (_, __) => const ColoredBox(
                                    color: kAppLightGreay,
                                    child: Center(
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.8,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                kAppPurple,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: kAppLightBlack,
                                    ),
                                  ),
                            ),
                          ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['label']!,
                  style: kBodySmallBlack.copyWith(fontFamily: 'Lato'),
                ),
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
                imageUrl: 'https://sociord-app.b-cdn.net/assets/edit/videoCut.png',
                selected: _selectedCreatorTool == _CreatorEditTool.cut,
                onTap: () {
                  setState(() {
                    _selectedCreatorTool = _CreatorEditTool.cut;
                  });
                  _ensureVideoController(selectedAsset);
                },
              ),
              _buildEditAction(
                imageUrl:
                    'https://sociord-app.b-cdn.net/assets/edit/videoCrop.png',
                selected: _selectedCreatorTool == _CreatorEditTool.crop,
                onTap: () {
                  setState(() {
                    _selectedCreatorTool = _CreatorEditTool.crop;
                    _videoFitByAssetId[selectedAsset.id] = BoxFit.cover;
                    _videoZoomByAssetId[selectedAsset.id] =
                        _videoZoomByAssetId[selectedAsset.id] ?? 1.0;
                  });
                },
              ),
              _buildEditAction(
                imageUrl:
                    'https://sociord-app.b-cdn.net/assets/edit/videoRotate.png',
                selected: _selectedCreatorTool == _CreatorEditTool.rotate,
                onTap: () {
                  setState(() {
                    _selectedCreatorTool = _CreatorEditTool.rotate;
                  });
                  _rotateCurrentAsset(selectedAsset);
                },
              ),
            ],
          ),
          if (_selectedCreatorTool == _CreatorEditTool.cut) ...[
            const SizedBox(height: 10),
            _buildCreatorCutTimeline(selectedAsset),
          ] else if (_selectedCreatorTool == _CreatorEditTool.crop &&
              selectedAsset.type == AssetType.video) ...[
            const SizedBox(height: 10),
            _buildCreatorCropZoomControls(selectedAsset),
          ],
        ],
      ),
    );
  }

  Widget _buildExplorerEditTools(AssetEntity selectedAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _explorerEditTools.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final toolMap = _explorerEditTools[index];
                final tool = toolMap['tool'] as _ExplorerEditTool;
                final title = toolMap['title'] as String;
                final imageUrl = toolMap['imageUrl'] as String;
                final isSelected =
                    _selectedExplorerTool == tool && _isAdjustmentTool(tool);
                return _buildExplorerEditItem(
                  label: title,
                  imageUrl: imageUrl,
                  selected: isSelected,
                  onTap: () async {
                    if (!mounted) return;
                    setState(() {
                      _selectedExplorerTool = tool;
                    });
                    if (tool == _ExplorerEditTool.crop) {
                      await _cropCurrentAsset(selectedAsset);
                    } else if (tool == _ExplorerEditTool.rotate) {
                      _rotateCurrentAsset(selectedAsset);
                    }
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
          ),
          if (_isAdjustmentTool(_selectedExplorerTool)) ...[
            const SizedBox(height: 8),
            _buildExplorerAdjustmentSlider(selectedAsset),
          ],
        ],
      ),
    );
  }

  Widget _buildExplorerEditItem({
    required String imageUrl,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0x1A4D9BFF) : Colors.transparent,
          border: Border.all(
            color: selected ? const Color(0xFF4D9BFF) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.tune_rounded, color: kAppLightBlack),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: kBodySmallBlack.copyWith(
                color: selected ? kAppPurple : kAppLightBlack,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorerEditorTabBarWithSize(AssetEntity asset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4D9BFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_assetSizeLabel(asset), style: kBodyMediumWhite),
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
      ),
    );
  }

  Widget _buildEditAction({
    required String imageUrl,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        width: 56,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? const Color(0x1A822FAF) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0x66822FAF) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Image.network(
              imageUrl,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              color: selected ? kAppPurple : kAppBlack,
              errorBuilder:
                  (_, __, ___) =>
                      Icon(Icons.tune_rounded, color: selected ? kAppPurple : kAppBlack),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorCutTimeline(AssetEntity asset) {
    if (asset.type != AssetType.video) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<VideoPlayerController?>(
      future: _ensureVideoController(asset),
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller == null || !controller.value.isInitialized) {
          return const SizedBox(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
              ),
            ),
          );
        }
        final totalSeconds = controller.value.duration.inMilliseconds / 1000.0;
        final safeTotal = totalSeconds <= 0 ? 1.0 : totalSeconds;
        final range =
            _videoCutRangeByAssetId[asset.id] ?? RangeValues(0, safeTotal);

        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final left = (range.start / safeTotal) * constraints.maxWidth;
                final right = (range.end / safeTotal) * constraints.maxWidth;
                return Container(
                  height: 46,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kAppLightGreay,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildVideoTimelineThumb(asset)),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: left.clamp(0, constraints.maxWidth),
                        child: Container(color: const Color(0x66000000)),
                      ),
                      Positioned(
                        left: right.clamp(0, constraints.maxWidth),
                        top: 0,
                        bottom: 0,
                        width: (constraints.maxWidth - right).clamp(
                          0,
                          constraints.maxWidth,
                        ),
                        child: Container(color: const Color(0x66000000)),
                      ),
                      Positioned(
                        left: left.clamp(0, constraints.maxWidth - 2),
                        top: 0,
                        bottom: 0,
                        child: Container(width: 2.4, color: kAppWhite),
                      ),
                      Positioned(
                        left: (right - 2.4).clamp(0, constraints.maxWidth - 2.4),
                        top: 0,
                        bottom: 0,
                        child: Container(width: 2.4, color: kAppWhite),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 0.1,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              overlayColor: const Color(0x22822FAF),
                              thumbColor: kAppWhite,
                              rangeTrackShape:
                                  const RoundedRectRangeSliderTrackShape(),
                              rangeThumbShape: const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 9,
                              ),
                            ),
                            child: RangeSlider(
                              values: range,
                              min: 0,
                              max: safeTotal,
                              onChanged: (value) {
                                setState(() {
                                  _videoCutRangeByAssetId[asset.id] = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              '${range.start.toStringAsFixed(1)}s - ${range.end.toStringAsFixed(1)}s',
              style: kBodySmallBlack.copyWith(color: kAppLightBlack),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVideoTimelineThumb(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(600, 120)),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final thumb = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              const tileWidth = 48.0;
              final tileCount = (constraints.maxWidth / tileWidth).ceil().clamp(
                6,
                20,
              );
              return Row(
                children: List.generate(tileCount, (index) {
                  return Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(thumb, fit: BoxFit.cover),
                        if (index > 0)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: Color(0x22FFFFFF),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              );
            },
          );
        }
        return const ColoredBox(color: Color(0x22000000));
      },
    );
  }

  Widget _buildCreatorCropZoomControls(AssetEntity asset) {
    final zoom = (_videoZoomByAssetId[asset.id] ?? 1.0).clamp(1.0, 2.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                final current = (_videoZoomByAssetId[asset.id] ?? 1.0);
                _videoZoomByAssetId[asset.id] = (current - 0.1).clamp(1.0, 2.5);
              });
            },
            icon: const Icon(Icons.remove, color: kAppLightBlack),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 2.5),
              child: Slider(
                value: zoom,
                min: 1.0,
                max: 2.5,
                activeColor: kAppPurple,
                onChanged: (value) {
                  setState(() {
                    _videoZoomByAssetId[asset.id] = value;
                  });
                },
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                final current = (_videoZoomByAssetId[asset.id] ?? 1.0);
                _videoZoomByAssetId[asset.id] = (current + 0.1).clamp(1.0, 2.5);
              });
            },
            icon: const Icon(Icons.add, color: kAppLightBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: kBodyMediumPurple.copyWith(
          fontWeight: FontWeight.w700,
          fontFamily: 'Gibson',
        ),
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
                style: kBodyMediumBlack.copyWith(
                  color: kAppLightBlack,
                  fontFamily: 'Gibson',
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: kAppPurple),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImagePicker(List<AssetEntity> selectedMedia) {
    return InkWell(
      onTap: _pickCoverImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorderGreay),
        ),
        clipBehavior: Clip.antiAlias,
        child:
            _selectedCoverImageFile == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 34, color: kAppPurple),
                    Text('Upload Image', style: kBodySmallPurple),
                  ],
                )
                : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedCoverImageFile!, fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCoverImageFile = null;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xAA000000),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: kAppWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final hasGalleryPermission = await PermissionService.requestGalleryPermission();
    if (!hasGalleryPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gallery permission is required to select cover image'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (!mounted || picked == null) return;

    setState(() {
      _selectedCoverImageFile = File(picked.path);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cover image selected'),
        backgroundColor: kAppPurple,
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
    final displayOrder = selectedIndex + 1;

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
    final brightness = _brightnessByAssetId[asset.id] ?? 0;
    final contrast = _contrastByAssetId[asset.id] ?? 1;
    final saturation = _saturationByAssetId[asset.id] ?? 1;
    final sharpen = _sharpenByAssetId[asset.id] ?? 0;
    final matrix = _buildColorMatrix(
      _selectedFilterByAssetId[asset.id] ?? 'none',
      contrast,
      brightness,
      saturation,
      sharpen,
    );
    final quarterTurns = _rotationTurns[asset.id] ?? 0;
    final isFlipped = _flipX[asset.id] ?? false;

    final Widget base;
    if (asset.type == AssetType.video) {
      base = _buildVideoPreview(asset);
    } else {
      base =
          _editedFiles[asset.id] != null
              ? Image.file(_editedFiles[asset.id]!, fit: BoxFit.cover)
              : _buildAssetImage(asset);
    }

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

  Widget _buildVideoPreview(AssetEntity asset) {
    return FutureBuilder<VideoPlayerController?>(
      future: _ensureVideoController(asset),
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller == null || !controller.value.isInitialized) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
              ),
            ),
          );
        }
        final fit = _videoFitByAssetId[asset.id] ?? BoxFit.cover;
        final zoom = _videoZoomByAssetId[asset.id] ?? 1.0;
        return ColoredBox(
          color: Colors.black,
          child: Transform.scale(
            scale: zoom,
            child: SizedBox.expand(
              child: FittedBox(
                fit: fit,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreatorPlayPauseButton(AssetEntity asset) {
    return FutureBuilder<VideoPlayerController?>(
      future: _ensureVideoController(asset),
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller == null || !controller.value.isInitialized) {
          return const SizedBox.shrink();
        }
        final isPlaying = controller.value.isPlaying;
        return InkWell(
          onTap: () {
            if (isPlaying) {
              controller.pause();
            } else {
              _pauseAllVideosExcept(asset.id);
              controller.play();
            }
            setState(() {});
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xB2000000),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: kAppWhite,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isPlaying ? 'Pause' : 'Play',
                  style: kBodySmallWhite.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<VideoPlayerController?> _ensureVideoController(AssetEntity asset) async {
    if (asset.type != AssetType.video) return null;
    final existing = _videoControllers[asset.id];
    if (existing != null) {
      return existing;
    }
    final file = await asset.file;
    if (file == null) return null;
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    controller.setLooping(true);
    controller.addListener(() {
      final range = _videoCutRangeByAssetId[asset.id];
      if (range == null || !controller.value.isInitialized) {
        return;
      }
      final positionSeconds = controller.value.position.inMilliseconds / 1000.0;
      if (positionSeconds > range.end) {
        controller.seekTo(Duration(milliseconds: (range.start * 1000).round()));
      }
    });
    _videoControllers[asset.id] = controller;
    if (mounted) {
      setState(() {});
    }
    return controller;
  }

  Future<void> _prepareVideoPreviewIfNeeded(AssetEntity asset) async {
    if (asset.type != AssetType.video) return;
    await _ensureVideoController(asset);
    _pauseAllVideosExcept(asset.id);
  }

  void _pauseAllVideosExcept(String activeAssetId) {
    for (final entry in _videoControllers.entries) {
      if (entry.key != activeAssetId && entry.value.value.isPlaying) {
        entry.value.pause();
      }
    }
  }


  List<double> _buildColorMatrix(
    String preset,
    double contrast,
    double brightness,
    double saturation,
    double sharpen,
  ) {
    final brightnessValue = brightness * 255;
    final effectiveContrast = contrast + (sharpen * 0.35);
    final effectiveSaturation = saturation + (sharpen * 0.15);
    if (preset == 'vintage') {
      return <double>[
        0.9 * effectiveContrast,
        0.1,
        0.0,
        0,
        brightnessValue + 10,
        0.0,
        0.8 * effectiveContrast,
        0.1,
        0,
        brightnessValue + 6,
        0.0,
        0.1,
        0.7 * effectiveContrast,
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
        1.15 * effectiveContrast,
        -0.05,
        -0.05,
        0,
        brightnessValue,
        -0.05,
        1.15 * effectiveContrast,
        -0.05,
        0,
        brightnessValue,
        -0.05,
        -0.05,
        1.15 * effectiveContrast,
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
        1.2 * effectiveContrast * effectiveSaturation,
        0,
        0,
        0,
        brightnessValue,
        0,
        1.2 * effectiveContrast * effectiveSaturation,
        0,
        0,
        brightnessValue,
        0,
        0,
        1.2 * effectiveContrast * effectiveSaturation,
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
        effectiveContrast,
        0,
        0,
        0,
        brightnessValue + 35,
        0,
        effectiveContrast,
        0,
        0,
        brightnessValue + 35,
        0,
        0,
        effectiveContrast,
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
        0.9 * effectiveContrast,
        0,
        0,
        0,
        brightnessValue - 8,
        0,
        0.9 * effectiveContrast,
        0,
        0,
        brightnessValue - 8,
        0,
        0,
        0.9 * effectiveContrast,
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
      effectiveContrast * effectiveSaturation,
      0,
      0,
      0,
      brightnessValue,
      0,
      effectiveContrast * effectiveSaturation,
      0,
      0,
      brightnessValue,
      0,
      0,
      effectiveContrast * effectiveSaturation,
      0,
      brightnessValue,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  bool _isAdjustmentTool(_ExplorerEditTool tool) {
    return tool == _ExplorerEditTool.brightness ||
        tool == _ExplorerEditTool.contrast ||
        tool == _ExplorerEditTool.sharpen ||
        tool == _ExplorerEditTool.saturation;
  }

  String _assetSizeLabel(AssetEntity asset) {
    return '${asset.width} x ${asset.height}';
  }

  Widget _buildExplorerAdjustmentSlider(AssetEntity asset) {
    final tool = _selectedExplorerTool;
    final value = _adjustmentValue(asset, tool);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_adjustmentIcon(tool), color: kAppLightBlack, size: 20),
          Expanded(
            child: Slider(
              activeColor: kAppPurple,
              value: value,
              min: _adjustmentMin(tool),
              max: _adjustmentMax(tool),
              onChanged: (newValue) {
                setState(() {
                  _setAdjustmentValue(asset, tool, newValue);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _adjustmentIcon(_ExplorerEditTool tool) {
    switch (tool) {
      case _ExplorerEditTool.brightness:
        return Icons.wb_sunny_outlined;
      case _ExplorerEditTool.contrast:
        return Icons.contrast;
      case _ExplorerEditTool.sharpen:
        return Icons.diamond_outlined;
      case _ExplorerEditTool.saturation:
        return Icons.opacity_outlined;
      case _ExplorerEditTool.crop:
      case _ExplorerEditTool.rotate:
        return Icons.tune;
    }
  }

  double _adjustmentValue(AssetEntity asset, _ExplorerEditTool tool) {
    switch (tool) {
      case _ExplorerEditTool.brightness:
        return _brightnessByAssetId[asset.id] ?? 0;
      case _ExplorerEditTool.contrast:
        return _contrastByAssetId[asset.id] ?? 1;
      case _ExplorerEditTool.sharpen:
        return _sharpenByAssetId[asset.id] ?? 0;
      case _ExplorerEditTool.saturation:
        return _saturationByAssetId[asset.id] ?? 1;
      case _ExplorerEditTool.crop:
      case _ExplorerEditTool.rotate:
        return 0;
    }
  }

  void _setAdjustmentValue(
    AssetEntity asset,
    _ExplorerEditTool tool,
    double value,
  ) {
    switch (tool) {
      case _ExplorerEditTool.brightness:
        _brightnessByAssetId[asset.id] = value;
        break;
      case _ExplorerEditTool.contrast:
        _contrastByAssetId[asset.id] = value;
        break;
      case _ExplorerEditTool.sharpen:
        _sharpenByAssetId[asset.id] = value;
        break;
      case _ExplorerEditTool.saturation:
        _saturationByAssetId[asset.id] = value;
        break;
      case _ExplorerEditTool.crop:
      case _ExplorerEditTool.rotate:
        break;
    }
  }

  double _adjustmentMin(_ExplorerEditTool tool) {
    switch (tool) {
      case _ExplorerEditTool.brightness:
        return -0.4;
      case _ExplorerEditTool.contrast:
        return 0.6;
      case _ExplorerEditTool.sharpen:
        return 0;
      case _ExplorerEditTool.saturation:
        return 0.6;
      case _ExplorerEditTool.crop:
      case _ExplorerEditTool.rotate:
        return 0;
    }
  }

  double _adjustmentMax(_ExplorerEditTool tool) {
    switch (tool) {
      case _ExplorerEditTool.brightness:
        return 0.4;
      case _ExplorerEditTool.contrast:
        return 1.6;
      case _ExplorerEditTool.sharpen:
        return 1;
      case _ExplorerEditTool.saturation:
        return 1.8;
      case _ExplorerEditTool.crop:
      case _ExplorerEditTool.rotate:
        return 1;
    }
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
    if (asset.type == AssetType.video) {
      setState(() {
        _videoFitByAssetId[asset.id] = BoxFit.cover;
        _videoZoomByAssetId[asset.id] = _videoZoomByAssetId[asset.id] ?? 1.0;
      });
      return;
    }
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

  void _loadMusic() {
    setState(() {
      _musicFuture = _musicService.searchTracks(
        query: _musicSearchController.text.trim(),
        category: _selectedGenre,
      );
    });
  }

  Future<void> _loadCreatorCollections() async {
    final userId = ref.read(userNotifierProvider).userId;
    if (userId == null || userId.isEmpty) {
      _creatorCollections = <Map<String, String>>[];
      return;
    }
    try {
      final collections = await _collectionService.getCollectionsByUser(userId);
      _creatorCollections = collections;
    } catch (_) {
      _creatorCollections = <Map<String, String>>[];
    }
  }

  Future<void> _openCollectionSheet() async {
    final selectedMedia = ref.read(mediaSelectionNotifierProvider);
    await _loadCreatorCollections();
    if (!mounted) return;
    final collectionItems = <Map<String, String>>[
      {'id': 'create_new', 'name': 'Create - Start a new collection'},
      ..._creatorCollections,
    ];

    _collectionSheetStep = 0;
    _isCreatingCollection = false;
    _selectedCollectionPreviewAssetId =
        selectedMedia.isNotEmpty ? selectedMedia.first.id : null;
    _collectionNameController?.dispose();
    _collectionNameController = TextEditingController(text: _collectionDraftName);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kAppWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget content;
            if (_collectionSheetStep == 0) {
              content = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...collectionItems.map((collection) {
                    final isCreateNew = collection['id'] == 'create_new';
                    return ListTile(
                      title:
                          isCreateNew
                              ? RichText(
                                text: TextSpan(
                                  style: kBodyMediumBlack.copyWith(
                                    fontFamily: 'Gibson',
                                      fontSize: 16,
                                    color: kAppBlack,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Create - '),
                                    TextSpan(
                                      text: 'Start a new collection',
                                      style: kBodyMediumPurple.copyWith(
                                        fontFamily: 'Gibson',
                                        fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Text(
                                collection['name']!,
                                style: kBodyMediumBlack.copyWith(
                                  fontFamily: 'Gibson',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        if (isCreateNew) {
                          _selectedCollectionId = null;
                          _selectedCollectionName = 'No';
                          _collectionDraftName = '';
                          _collectionNameController?.clear();
                          setModalState(() => _collectionSheetStep = 1);
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
            } else if (_collectionSheetStep == 1) {
              content = SizedBox(
                height: MediaQuery.of(context).size.height * 0.88,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildActionChip(
                            label: 'Go back',
                            icon: Icons.arrow_back,
                            onTap:
                                () => setModalState(() => _collectionSheetStep = 0),
                          ),
                          const Spacer(),
                          Image.network(
                            'https://sociord-app.b-cdn.net/assets/logo.png',
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => Text(
                                  'Sociord',
                                  style: kHeadlineSmallBlack.copyWith(
                                    fontFamily: 'Lato',
                                    fontSize: 44,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 78),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 112,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: kAppPurple,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDADADA),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Create a New Collection',
                        style: kHeadlineSmallBlack.copyWith(
                          fontFamily: 'Gibson',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'What would you like to name it ?',
                        style: kBodyMediumPurple.copyWith(
                          fontFamily: 'Gibson',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Name your collection',
                        style: kBodyMediumBlack.copyWith(
                          fontFamily: 'Gibson',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _collectionNameController,
                        style: kBodyMediumBlack.copyWith(fontFamily: 'Gibson'),
                        decoration: InputDecoration(
                          hintText: "Arjun's Day Out",
                          hintStyle: kBodyMediumBlack.copyWith(
                            color: kDarkGreay,
                            fontFamily: 'Gibson',
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _focusedInputBorder(),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _collectionDraftName =
                                _collectionNameController?.text.trim() ?? '';
                            setModalState(() => _collectionSheetStep = 2);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAppPurple,
                            foregroundColor: kAppWhite,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: kHeadlineSmallWhite.copyWith(
                              fontFamily: 'Gibson',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final preview =
                  selectedMedia
                      .where((asset) => asset.id == _selectedCollectionPreviewAssetId)
                      .cast<AssetEntity?>()
                      .firstWhere(
                        (_) => true,
                        orElse:
                            () =>
                                selectedMedia.isEmpty ? null : selectedMedia.first,
                      );
              content = SizedBox(
                height: MediaQuery.of(context).size.height * 0.88,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildActionChip(
                            label: 'Go back',
                            icon: Icons.arrow_back,
                            onTap:
                                () => setModalState(() => _collectionSheetStep = 1),
                          ),
                          const Spacer(),
                          Image.network(
                            'https://sociord-app.b-cdn.net/assets/logo.png',
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (_, __, ___) => Text(
                                  'Sociord',
                                  style: kHeadlineSmallBlack.copyWith(
                                    fontFamily: 'Lato',
                                    fontSize: 44,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 78),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 112,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: kAppPurple,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: kAppPurple,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Upload your first video',
                        style: kHeadlineSmallBlack.copyWith(
                          fontFamily: 'Gibson',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Let’s start your collection",
                        style: kBodyMediumPurple.copyWith(
                          fontFamily: 'Gibson',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 220,
                        height: 280,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: kAppLightGreay,
                          border: Border.all(color: const Color(0xFF00A2FF), width: 2),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child:
                                  preview == null
                                      ? const Icon(
                                        Icons.video_library,
                                        color: kAppLightBlack,
                                      )
                                      : _buildAssetImage(preview),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10,
                              child: Center(
                                child: InkWell(
                                  onTap: () async {
                                    if (selectedMedia.length <= 1) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Select multiple clips to change',
                                          ),
                                          backgroundColor: kAppPurple,
                                        ),
                                      );
                                      return;
                                    }
                                    final pickedId =
                                        await showModalBottomSheet<String>(
                                          context: context,
                                          backgroundColor: kAppWhite,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          builder: (sheetContext) {
                                            return SafeArea(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                      16,
                                                      16,
                                                      16,
                                                      20,
                                                    ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Choose clip',
                                                      style:
                                                          kHeadlineSmallBlack
                                                              .copyWith(
                                                                fontFamily:
                                                                    'Gibson',
                                                              ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    SizedBox(
                                                      height: 96,
                                                      child: ListView.separated(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            selectedMedia.length,
                                                        separatorBuilder:
                                                            (_, __) =>
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                        itemBuilder: (_, index) {
                                                          final asset =
                                                              selectedMedia[index];
                                                          final isCurrent =
                                                              asset.id ==
                                                              _selectedCollectionPreviewAssetId;
                                                          return InkWell(
                                                            onTap:
                                                                () => Navigator.pop(
                                                                  sheetContext,
                                                                  asset.id,
                                                                ),
                                                            child: Container(
                                                              width: 82,
                                                              clipBehavior:
                                                                  Clip.antiAlias,
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                border: Border.all(
                                                                  color:
                                                                      isCurrent
                                                                          ? kAppPurple
                                                                          : kBorderGreay,
                                                                  width:
                                                                      isCurrent
                                                                          ? 2
                                                                          : 1,
                                                                ),
                                                              ),
                                                              child: _buildAssetImage(
                                                                asset,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                    if (pickedId == null) return;
                                    setModalState(() {
                                      _selectedCollectionPreviewAssetId = pickedId;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kAppWhite,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Change Clip',
                                      style: kBodyMediumPurple.copyWith(
                                        fontFamily: 'Gibson',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          style: kBodyMediumBlack.copyWith(
                            fontFamily: 'Gibson',
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Please Note : ',
                              style: kBodyMediumPurple.copyWith(
                                fontFamily: 'Gibson',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  "You’ve picked a vertical video, so all future uploads in this collection must also be vertical.",
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCreatingCollection
                              ? null
                              : () async {
                                  setModalState(() {
                                    _isCreatingCollection = true;
                                  });
                            final name =
                                _collectionDraftName.isEmpty
                                    ? 'New Collection'
                                    : _collectionDraftName;
                            final userId = ref.read(userNotifierProvider).userId;
                            if (userId == null || userId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not found'),
                                  backgroundColor: kAppPurple,
                                ),
                              );
                              if (mounted) {
                                setModalState(() {
                                  _isCreatingCollection = false;
                                });
                              }
                              return;
                            }
                            try {
                              final created = await _collectionService.createCollection(
                                userId: userId,
                                title: name,
                              );
                              if (!mounted) return;
                              setState(() {
                                _selectedCollectionId = created['id'];
                                _selectedCollectionName = created['name'] ?? name;
                              });
                              await _loadCreatorCollections();
                              if (!mounted) return;
                              Navigator.pop(context);
                            } catch (_) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to create collection'),
                                  backgroundColor: kAppPurple,
                                ),
                              );
                              setModalState(() {
                                _isCreatingCollection = false;
                              });
                            }
                                  if (mounted) {
                                    setModalState(() {
                                      _isCreatingCollection = false;
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAppPurple,
                            foregroundColor: kAppWhite,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isCreatingCollection
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(kAppWhite),
                                  ),
                                )
                              : Text(
                                  'Confirm and Continue',
                                  style: kHeadlineSmallWhite.copyWith(
                                    fontFamily: 'Gibson',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(child: content);
          },
        );
      },
    );
    _collectionNameController?.dispose();
    _collectionNameController = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _preparePostPayload() async {
    final user = ref.read(userNotifierProvider);
    final selectedMedia = ref.read(mediaSelectionNotifierProvider);
    final tab = widget.mode.tabs[_selectedTabIndex];
    final title = _titleController.text.trim();

    if (user.userId == null || user.userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }
    if (selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one media file'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }
    if (title.isEmpty) {
      setState(() {
        _showTitleRequiredError = true;
        _showExplorerTitleRequiredError = widget.mode == UploadFlowMode.explorer;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title is required'),
          backgroundColor: kAppPurple,
        ),
      );
      return;
    }

    _draftInput['userId'] = user.userId ?? '';
    _draftInput['postType'] = tab.postType;
    _draftInput['title'] = title;
    _draftInput['description'] = _longDescriptionController.text.trim();
    _draftInput['backgroundMusic'] = _selectedTrack?.title ?? '';
    _draftInput['collectionId'] = tab.postType == 'CLIP' ? _selectedCollectionId : null;
    _draftInput['taggedUserIds'] = _taggedUserIds.toList();
    _draftInput['images'] =
        tab.mediaType == AssetType.image ? selectedMedia : <AssetEntity>[];
    _draftInput['videos'] =
        tab.mediaType == AssetType.video ? selectedMedia : <AssetEntity>[];
    _draftInput['coverImage'] =
        _selectedCoverImageFile ??
        (selectedMedia.isNotEmpty ? selectedMedia.first : null);

    setState(() {
      _isUploadingPost = true;
    });

    try {
      final imageFiles = await _assetEntitiesToMultipartFiles(
        selectedMedia.where((asset) => asset.type == AssetType.image).toList(),
        fieldName: 'images',
      );
      final videoFiles = await _assetEntitiesToMultipartFiles(
        selectedMedia.where((asset) => asset.type == AssetType.video).toList(),
        fieldName: 'videos',
      );
      final coverFile =
          widget.mode == UploadFlowMode.creator
              ? await _resolveCoverImageMultipartFile()
              : null;

      await _postService.createPostMedia(
        userId: user.userId!,
        postType: tab.postType,
        title: title,
        description: _longDescriptionController.text.trim(),
        backgroundMusic: _selectedTrack?.title,
        collectionId: tab.postType == 'CLIP' ? _selectedCollectionId : null,
        taggedUserIds: _taggedUserIds.toList(),
        images: imageFiles,
        videos: videoFiles,
        coverImage: coverFile,
      );

      if (!mounted) return;
      ref.read(mediaSelectionNotifierProvider.notifier).clearSelection();
      setState(() {
        _step = _UploadStep.select;
        _selectedPreviewIndex = 0;
        _titleController.clear();
        _longDescriptionController.clear();
        _selectedTrack = null;
        _selectedCollectionId = null;
        _selectedCollectionName = 'No';
        _showTitleRequiredError = false;
        _showExplorerTitleRequiredError = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post uploaded successfully'),
          backgroundColor: kAppPurple,
        ),
      );
      await _loadGalleryAssets();
    } catch (error) {
      // Keep this log for runtime diagnosis of upload failures.
      debugPrint('createPostMedia upload error: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload post: $error'),
          backgroundColor: kAppPurple,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPost = false;
        });
      }
    }
  }

  Future<List<http.MultipartFile>> _assetEntitiesToMultipartFiles(
    List<AssetEntity> assets, {
    required String fieldName,
  }) async {
    final files = <http.MultipartFile>[];
    for (final asset in assets) {
      final file = await asset.file;
      if (file == null) {
        debugPrint('Skipping asset ${asset.id}: unable to resolve local file');
        continue;
      }
      files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : '${asset.id}.bin',
        ),
      );
    }
    return files;
  }

  Future<http.MultipartFile?> _resolveCoverImageMultipartFile() async {
    if (_selectedCoverImageFile != null) {
      return http.MultipartFile.fromPath(
        'coverImage',
        _selectedCoverImageFile!.path,
        filename: _selectedCoverImageFile!.uri.pathSegments.isNotEmpty
            ? _selectedCoverImageFile!.uri.pathSegments.last
            : 'cover.jpg',
      );
    }
    final selectedMedia = ref.read(mediaSelectionNotifierProvider);
    if (selectedMedia.isEmpty) return null;
    final first = selectedMedia.first;
    final file = await first.file;
    if (file == null) return null;
    return http.MultipartFile.fromPath(
      'coverImage',
      file.path,
      filename:
          file.uri.pathSegments.isNotEmpty ? file.uri.pathSegments.last : 'cover.jpg',
    );
  }

  void _primeFilterPreviewCache() {
    for (final url in _filterPreviewUrls) {
      precacheImage(CachedNetworkImageProvider(url), context);
    }
  }
}
