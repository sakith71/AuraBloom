// lib/screens/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/services/community-service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final List<String> _availableTags = [
    'Pain Management',
    'Exercises',
    'Diets',
    'Reproductive Health',
  ];

  final List<String> _selectedTags = [];
  bool _isAnonymous = false;
  bool _isLoading = false;

  // For image upload
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  // Open emoji picker
  void _openEmojiPicker() {
    // This is a simplified representation
    // You would implement an emoji picker here based on your needs
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Emoji Picker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Sample emoji grid - in a real app, you'd use an emoji picker package
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  // Sample emojis
                  List<String> sampleEmojis = [
                    '😊',
                    '😂',
                    '❤️',
                    '👍',
                    '🙏',
                    '😍',
                    '😭',
                    '😁',
                    '🥰',
                    '😘',
                    '🤔',
                    '😔',
                    '🙄',
                    '😌',
                    '😴',
                    '🤗',
                    '🥺',
                    '😳',
                    '😎',
                    '🙂',
                  ];
                  return GestureDetector(
                    onTap: () {
                      // Insert emoji at current cursor position
                      final text = _contentController.text;
                      final selection = _contentController.selection;
                      final newText = text.replaceRange(
                        selection.start,
                        selection.end,
                        sampleEmojis[index % sampleEmojis.length],
                      );
                      _contentController.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(
                          offset:
                              selection.start + 2, // Emoji length is usually 2
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        sampleEmojis[index % sampleEmojis.length],
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles.map((e) => File(e.path)).toList());
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  // Take a photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  // Remove an image from selection
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    setState(() {
    });

    try {
      final List<String> imageUrls = [];
      final user = _communityService.currentUser;
      final userId = user?.uid ?? 'anonymous';

      for (var imageFile in _selectedImages) {
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
        final Reference storageRef = FirebaseStorage.instance.ref().child(
          'posts_images/$fileName',
        );

        final UploadTask uploadTask = storageRef.putFile(imageFile);
        final TaskSnapshot taskSnapshot = await uploadTask;

        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading images: $e')));
      return [];
    } finally {
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter post content')),
      );
      return;
    }

    if (_selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one tag')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First upload images if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages();
      }

      // Create post with image URLs
      await _communityService.addPost(
        content: _contentController.text.trim(),
        tags: _selectedTags,
        images: imageUrls.isEmpty ? null : imageUrls,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Get appropriate icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pain Management':
        return Icons.healing;
      case 'Exercises':
        return Icons.fitness_center;
      case 'Diets':
        return Icons.restaurant_menu;
      case 'Reproductive Health':
        return Icons.spa;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove background color and elevation for appbar
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style: TextStyle(
            color:
                Colors
                    .black, // Change text color to black for better visibility
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(
          color: Colors.black,
        ), // Change back button color to black
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color:
                            Colors
                                .pink, // Change loading indicator color to match theme
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Post',
                      style: TextStyle(
                        color:
                            Colors
                                .pink, // Change button text color to pink to match theme
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content TextField with emoji button
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Share your thoughts...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: _openEmojiPicker,
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Colors.amber,
                          ),
                          tooltip: 'Add emoji',
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Selected Images Preview
              if (_selectedImages.isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          _selectedImages[index],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Image Upload Options
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: _pickImages,
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.green,
                            ),
                            tooltip: 'Upload from gallery',
                          ),
                          const Text('Gallery', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: _takePhoto,
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                            ),
                            tooltip: 'Take a photo',
                          ),
                          const Text('Camera', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Post Options
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Anonymous Toggle
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Post Anonymously'),
                        subtitle: const Text(
                          'Your name will not be shown with this post',
                        ),
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tags Section
              const Text(
                'Select Tags (Required)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () => _toggleTag(tag),
                        child: Chip(
                          avatar: Icon(
                            _getCategoryIcon(tag),
                            color: isSelected ? Colors.white : Colors.pink,
                            size: 18,
                          ),
                          label: Text(tag),
                          backgroundColor:
                              isSelected
                                  ? Colors.pink.withOpacity(0.7)
                                  : Colors.grey[200],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 100), // Bottom padding for scrolling
            ],
          ),
        ),
      ),
    );
  }
}
