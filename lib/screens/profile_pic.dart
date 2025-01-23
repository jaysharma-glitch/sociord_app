import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class ProfilePicScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile-pic';
  const ProfilePicScreen({super.key});

  @override
  _ProfilePicScreenState createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends ConsumerState<ProfilePicScreen> {
  File? _image;
  CroppedFile? _croppedFile;
  bool isLoading = false;
  bool isTooLarge = false;
  bool isImageLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      isImageLoading = true;
    });
    try {
      final pickedFile;
      if (source == ImageSource.camera) {
        print('in ifff');
        pickedFile = await _picker.pickImage(
            source: source,
            preferredCameraDevice: CameraDevice.front,
            imageQuality: 90);
      } else {
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        await _cropImage(pickedFile.path);
        if (_croppedFile != null) {
          File imageFile = File(_croppedFile!.path);
          await _compressImage(imageFile);
          setState(() {
            isImageLoading = false;
          });
        }
      } else {
        setState(() {
          isImageLoading = false;
          _image = null;
          _croppedFile = null;
        });
      }
    } catch (e) {
      setState(() {
        isImageLoading = false;
      });
      print("Error picking image: $e");
    }
  }

  Future<void> _cropImage(path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Profile Pic',
          toolbarColor: kAppPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
          aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
        ),
        IOSUiSettings(
          title: 'Profile Pic',
          aspectRatioLockEnabled: true,
          rotateButtonsHidden: true,
          aspectRatioPresets: [CropAspectRatioPreset.ratio3x2],
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
    }
  }

  Future<void> _compressImage(File imageFile) async {
    setState(() {
      isTooLarge = false;
    });
    // Compress the image
    final compressedImage = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80, // Adjust quality as needed
      format: CompressFormat.png, // Ensure the image is converted to PNG
    );
    // Check the size
    final imageSize = compressedImage!.length;
    print(imageSize);
    if (imageSize > 5 * 1024 * 1024) {
      // 5MB
      setState(() {
        isTooLarge = true;
      });
      throw Exception("Image size exceeds 5MB");
    }

    // Update the file with compressed data
    await imageFile.writeAsBytes(compressedImage);
  }

  @override
  Widget build(BuildContext context) {
    var userState = ref.watch(userNotifierProvider);
    var userNotifier = ref.read(userNotifierProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome ${userState.firstName}!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'You\'re all set. Ready to update your profile display image ?',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: kAppPurple,
                      fontSize: 15,
                    ),
              ),
              SizedBox(
                height: 50,
              ),
              _croppedFile == null
                  ? Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _pickImage(ImageSource.gallery);
                              },
                              child: Text(
                                'Upload from device',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _pickImage(ImageSource.camera);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAppGreen,
                              ),
                              child: Text(
                                'Take a selfie',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: kAppBlack),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
                              child: Text(
                                'Skip for now',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: kAppPurple),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: isImageLoading
                                ? Container(
                                    height: 200,
                                    width: 200,
                                    child: CircularProgressIndicator(),
                                  )
                                : Image.file(
                                    File(_croppedFile!.path),
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.4,
                                  ),
                          ),
                        ),
                        if (isTooLarge)
                          Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'Image size is too large. Kindly upload an image below 5MB in size',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: kAppRed),
                            ),
                          ),
                        if (!isImageLoading && !isTooLarge)
                          Row(
                            children: [
                              Text(
                                'Needs adjustments?',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _cropImage(_croppedFile!.path);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 15,
                                ),
                                label: Text('Edit',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300)),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  backgroundColor: kAppGreay,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Border radius
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (!isImageLoading && !isTooLarge)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_croppedFile == null) return;
                                  final filetype =
                                      'image/png'; // or detect the file type dynamically

                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final signedUrl = await userNotifier
                                        .getSignedUrl(filetype);
                                    await userNotifier.uploadImage(
                                        File(_croppedFile!.path), signedUrl);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Upload successful!')),
                                    );
                                  } catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (e
                                        .toString()
                                        .contains('Connection refused')) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              CustomSnackBar().build(context));
                                    } else {
                                      print("Error ${e.toString()}");
                                    }
                                  }

                                  // File imageFile = File(_croppedFile!.path);
                                  // Uint8List imageBytes =
                                  //     await imageFile.readAsBytes();
                                  // String base64Image = base64Encode(imageBytes);
                                  // String imageString =
                                  //     "data:image/png;base64,$base64Image"; // Format to send to backend

                                  // try {
                                  //   setState(() {
                                  //     isLoading = true;
                                  //   });

                                  //   var result = await userNotifier
                                  //       .addProfilePic(imageString);

                                  //   setState(() {
                                  //     isLoading = false;
                                  //   });
                                  //   if (result != null) {
                                  //     print('success');
                                  //   }
                                  // } catch (e) {
                                  //   setState(() {
                                  //     isLoading = false;
                                  //   });
                                  //   if (e
                                  //       .toString()
                                  //       .contains('Connection refused')) {
                                  //     ScaffoldMessenger.of(context).showSnackBar(
                                  //         CustomSnackBar().build(context));
                                  //   } else {
                                  //     print("Error ${e.toString()}");
                                  //   }
                                  // }
                                },
                                child: isLoading
                                    ? kLoadingIndicator
                                    : Text(
                                        'Continue',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (!isImageLoading)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (!isLoading) {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return SizedBox(
                                              height: 200,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            _pickImage(
                                                                ImageSource
                                                                    .gallery);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      kAppBlack),
                                                          child: Text(
                                                            'Upload from device',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headlineSmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Center(
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            _pickImage(
                                                                ImageSource
                                                                    .camera);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side:
                                                                const BorderSide(
                                                              color: kAppBlack,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Take a Selfie',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headlineSmall
                                                                ?.copyWith(
                                                                    color:
                                                                        kAppBlack),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ));
                                        });
                                  }
                                },
                                child: Text(
                                  'Change Image',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: kAppPurple),
                                ),
                              ),
                            ),
                          )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
