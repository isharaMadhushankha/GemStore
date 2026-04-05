import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class AddGemScreen extends StatefulWidget {
  const AddGemScreen({super.key});
  @override
  State<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends State<AddGemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _uploadAndSave() async {
    if (_selectedImage == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select an image and enter a name")),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage.from('images').upload(fileName, _selectedImage!);
      final imageUrl =
          supabase.storage.from('images').getPublicUrl(fileName);
      await supabase.from('gems').insert({
        'gem_name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'contact_no': _contactController.text,
        'image_url': imageUrl,
        'user_id': supabase.auth.currentUser!.id,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Widget leading,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF6b6b7e),
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13131f),
            border: Border.all(color: const Color(0xFF2a2a3e)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Focus(
            onFocusChange: (hasFocus) => setState(() {}),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: textAlign,
              style: const TextStyle(
                  color: Color(0xFFd8d8e8), fontSize: 13),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF3a3a52)),
                prefixIcon: leading,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Row(children: [
          Text(text.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Color(0xFF4a4a62))),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: Color(0xFF1e1e2e))),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0f),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a0f),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF13131f),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2a2a3e))),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Color(0xFFc9a84c)),
          ),
        ),
        title: const Text('Add Gem Listing',
            style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFFf0d080))),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFc9a84c)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Gem Photo'),

                  // Image picker
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13131f),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedImage != null
                              ? const Color(0xFFc9a84c)
                              : const Color(0xFF2a2a3e),
                          width: 1.5,
                          // dashed border workaround via CustomPaint optional
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1e1e2e),
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  child: const Icon(Icons.photo_camera_outlined,
                                      size: 22, color: Color(0xFF6b6b7e)),
                                ),
                                const SizedBox(height: 10),
                                const Text('Tap to select from gallery',
                                    style: TextStyle(
                                        fontFamily: 'sans-serif',
                                        fontSize: 12,
                                        color: Color(0xFF5a5a72))),
                                const SizedBox(height: 3),
                                const Text('JPG, PNG — best quality',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF3a3a52))),
                              ],
                            )
                          : !kIsWeb && _selectedImage != null
                              ? Stack(children: [
                                  Image.file(_selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withOpacity(0.7),
                                        border: Border.all(
                                            color: const Color(0xFF2a2a3e)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('✓ Selected',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFc9a84c))),
                                    ),
                                  ),
                                ])
                              : Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1e1e2e),
                                          borderRadius: BorderRadius.circular(23),
                                        ),
                                        child: const Icon(Icons.check,
                                            size: 22, color: Color(0xFFc9a84c)),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text('✓ Image selected',
                                          style: TextStyle(
                                              fontFamily: 'sans-serif',
                                              fontSize: 12,
                                              color: Color(0xFF5a5a72))),
                                    ],
                                  ),
                                ),
                    ),
                  ),

                  _sectionLabel('Gem Details'),

                  _buildField(
                    controller: _nameController,
                    label: 'Gem Name',
                    hintText: 'e.g. Blue Sapphire, Ruby...',
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 8),
                      child: Text('💎',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _priceController,
                    label: 'Price (LKR)',
                    hintText: '0.00',
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 4),
                      child: Text('LKR',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF6b6b7e))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _contactController,
                    label: 'Contact Number',
                    hintText: '+94 7X XXX XXXX',
                    keyboardType: TextInputType.phone,
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 8),
                      child: Icon(Icons.phone_outlined,
                          size: 16, color: Color(0xFF4a4a62)),
                    ),
                  ),

                  _sectionLabel('Quick Fill'),

                  // Quick chips
                  Wrap(
                    spacing: 8,
                    children: [
                      ['Blue Sapphire', const Color(0xFF4a7ab5)],
                      ['Ruby', const Color(0xFFa83232)],
                      ['Emerald', const Color(0xFF2a7a4a)],
                      ['Alexandrite', const Color(0xFF7a4ab5)],
                    ].map((item) {
                      return GestureDetector(
                        onTap: () => setState(
                            () => _nameController.text = item[0] as String),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF13131f),
                            border:
                                Border.all(color: const Color(0xFF2a2a3e)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: item[1] as Color,
                                    shape: BoxShape.circle,
                                  )),
                              const SizedBox(width: 5),
                              Text(item[0] as String,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF5a5a72))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Post button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _uploadAndSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFc9a84c),
                        foregroundColor: const Color(0xFF0a0a0f),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('💎', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Text('Post Gem Ad',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}