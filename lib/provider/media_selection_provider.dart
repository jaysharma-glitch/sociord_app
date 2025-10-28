import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:photo_manager/photo_manager.dart';

part 'media_selection_provider.g.dart';

@riverpod
class MediaSelectionNotifier extends _$MediaSelectionNotifier {
  @override
  List<AssetEntity> build() {
    return [];
  }

  void addMedia(AssetEntity asset) {
    if (!state.contains(asset)) {
      state = [...state, asset];
    }
  }

  void removeMedia(AssetEntity asset) {
    state = state.where((item) => item.id != asset.id).toList();
  }

  void toggleMedia(AssetEntity asset) {
    if (state.any((item) => item.id == asset.id)) {
      removeMedia(asset);
    } else {
      addMedia(asset);
    }
  }

  void clearSelection() {
    state = [];
  }

  bool isSelected(AssetEntity asset) {
    return state.any((item) => item.id == asset.id);
  }

  int getSelectionCount() {
    return state.length;
  }

  List<AssetEntity> getSelectedMedia() {
    return List.from(state);
  }
}

@riverpod
class MediaTypeNotifier extends _$MediaTypeNotifier {
  @override
  AssetType build() {
    return AssetType.image;
  }

  void setMediaType(AssetType type) {
    state = type;
  }
}

@riverpod
class GalleryAssetsNotifier extends _$GalleryAssetsNotifier {
  @override
  List<AssetEntity> build() {
    return [];
  }

  void setAssets(List<AssetEntity> assets) {
    state = assets;
  }

  void clearAssets() {
    state = [];
  }
}
