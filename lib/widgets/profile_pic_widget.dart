// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kampusmart2/Theme/app_theme.dart';
import '../services/image_picker_service.dart';
import '../services/profile_service.dart';

class ProfilePicWidget extends StatefulWidget {
  final String? imageUrl; // null if no image
  final VoidCallback? onAddPressed;
  final VoidCallback? onImageUpdated; // Callback when image is updated
  final double radius;
  final double height;
  final double width;
  final bool isEditable; // Whether the user can edit the image

  const ProfilePicWidget({
    super.key,
    this.imageUrl,
    this.onAddPressed,
    this.onImageUpdated,
    required this.radius, // default radius
    required this.height, // default height
    required this.width, // default width
    this.isEditable = true, // Default to editable
  });

  @override
  State<ProfilePicWidget> createState() => _ProfilePicWidgetState();
}

class _ProfilePicWidgetState extends State<ProfilePicWidget> {
  String? _currentImageUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.imageUrl;
    _loadCurrentUserImage();
  }

  Future<void> _loadCurrentUserImage() async {
    if (_currentImageUrl == null || _currentImageUrl!.isEmpty) {
      print('ProfilePicWidget: Loading current user image...');
      final imageUrl = await ProfileService.getCurrentUserProfileImageUrl();
      print('ProfilePicWidget: Retrieved image URL: $imageUrl');

      if (mounted && imageUrl != null && imageUrl.isNotEmpty) {
        setState(() {
          _currentImageUrl = imageUrl;
        });
        print(
          'ProfilePicWidget: Updated current image URL to: $_currentImageUrl',
        );
      }
    } else {
      print('ProfilePicWidget: Already have image URL: $_currentImageUrl');
    }
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    // Check if it's a valid Firebase Storage URL or other valid image URL
    return url.startsWith('https://') &&
        (url.contains('firebasestorage.googleapis.com') ||
            url.contains('firebase') ||
            url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif'));
  }

  Future<void> _handleImageTap() async {
    if (!widget.isEditable) return;

    final hasImage = _currentImageUrl != null && _currentImageUrl!.isNotEmpty;

    if (hasImage) {
      // Show options for existing image
      final action = await ImagePickerService.showImageOptionsDialog(
        context,
        _currentImageUrl!,
      );

      if (action != null) {
        switch (action) {
          case 'view':
            ImagePickerService.showFullScreenImage(context, _currentImageUrl!);
            break;
          case 'change':
            await _pickNewImage();
            break;
          case 'remove':
            await _removeImage();
            break;
        }
      }
    } else {
      // No image, show picker dialog
      await _pickNewImage();
    }
  }

  Future<void> _pickNewImage() async {
    print('ProfilePicWidget: Picking new image...');
    final pickedImage = await ImagePickerService.showImageSourceDialog(context);

    if (pickedImage != null) {
      print('ProfilePicWidget: Image picked: ${pickedImage.path}');

      setState(() {
        _isUpdating = true;
      });

      try {
        print('ProfilePicWidget: Calling ProfileService.updateProfileImage...');
        final success = await ProfileService.updateProfileImage(pickedImage);
        print('ProfilePicWidget: Update result: $success');

        if (success) {
          // Reload the image URL
          print('ProfilePicWidget: Reloading image URL...');
          final newImageUrl =
              await ProfileService.getCurrentUserProfileImageUrl();
          print('ProfilePicWidget: New image URL: $newImageUrl');

          if (mounted) {
            setState(() {
              _currentImageUrl = newImageUrl;
              _isUpdating = false;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: AppTheme.lightGreen,
              ),
            );

            // Call callback if provided
            widget.onImageUpdated?.call();
          }
        } else {
          if (mounted) {
            setState(() {
              _isUpdating = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile picture'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('ProfilePicWidget: Error updating profile picture: $e');
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile picture: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      print('ProfilePicWidget: No image was picked');
    }
  }

  Future<void> _removeImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text(
          'Are you sure you want to remove your profile picture?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final success = await ProfileService.deleteProfileImage();

        if (success) {
          if (mounted) {
            setState(() {
              _currentImageUrl = null;
              _isUpdating = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture removed successfully!'),
                backgroundColor: AppTheme.lightGreen,
              ),
            );

            // Call callback if provided
            widget.onImageUpdated?.call();
          }
        } else {
          if (mounted) {
            setState(() {
              _isUpdating = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to remove profile picture'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing profile picture: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alreadyHasAnImage =
        _currentImageUrl != null &&
        _currentImageUrl!.isNotEmpty &&
        _isValidImageUrl(_currentImageUrl);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: widget.isEditable ? _handleImageTap : null,
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: AppTheme.borderGrey.withOpacity(0.9),
              child: alreadyHasAnImage
                  ? ClipOval(
                      child: Image.network(
                        _currentImageUrl!,
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryOrange,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading profile image: $error');
                          return Image.asset(
                            'assets/default_profile.png',
                            width: widget.width,
                            height: widget.height,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    )
                  : Image.asset(
                      'assets/default_profile.png',
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        if (widget.isEditable)
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: _isUpdating
                  ? null
                  : (widget.onAddPressed ?? _handleImageTap),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.borderGrey.withOpacity(0.4),
                child: _isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
