import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemstore2/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class EditGemScreen extends StatefulWidget {
  final Map<String, dynamic> gem;
  const EditGemScreen({super.key, required this.gem});

  @override
  State<EditGemScreen> createState() => _EditGemScreenState();
}

class _EditGemScreenState extends State<EditGemScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _contactController;
  File? _newImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.gem['gem_name'] ?? '');
    _priceController = TextEditingController(
        text: (widget.gem['price'] as num?)?.toString() ?? '');
    _contactController =
        TextEditingController(text: widget.gem['contact_no'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? img =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _newImage = File(img.path));
  }

  Future<void> _confirmAndUpdate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _GemDialog(
        icon: '✦',
        title: 'Save Changes?',
        subtitle: 'Your gem listing will be updated in the marketplace.',
        confirmLabel: 'Update',
        confirmColor: const Color(0xFFc9a84c),
        confirmTextColor: const Color(0xFF0a0a0f),
        useGoldGradient: true,
      ),
    );
    if (confirmed != true) return;
    await _performUpdate();
  }

  Future<void> _performUpdate() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          goldSnackBar('Please enter a gem name'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? imageUrl = widget.gem['image_url'];

      if (_newImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await _newImage!.readAsBytes();
        await supabase.storage.from('images').uploadBinary(
              fileName, bytes,
              fileOptions:
                  const FileOptions(contentType: 'image/jpeg'),
            );
        imageUrl =
            supabase.storage.from('images').getPublicUrl(fileName);
      }

      await supabase.from('gems').update({
        'gem_name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'contact_no': _contactController.text,
        if (imageUrl != null) 'image_url': imageUrl,
      }).match({'id': widget.gem['id']});

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('✦  Listing updated successfully'));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(goldSnackBar('Error: $e'));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required Widget leading,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF6b6b7e))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFF13131f),
              border: Border.all(color: const Color(0xFF2a2a3e)),
              borderRadius: BorderRadius.circular(10)),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: textAlign,
            style:
                const TextStyle(color: Color(0xFFd8d8e8), fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF3a3a52)),
              prefixIcon: leading,
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFFc9a84c)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

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
                shape: BoxShape.circle,
                color: const Color(0xFF13131f),
                border: Border.all(color: const Color(0xFF2a2a3e))),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Color(0xFFc9a84c)),
          ),
        ),
        title: const Text('Edit Listing',
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFF13131f),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _newImage != null
                                  ? const Color(0xFFc9a84c)
                                  : const Color(0xFF2a2a3e),
                              width: 1.5)),
                      clipBehavior: Clip.antiAlias,
                      child: _newImage != null
                          ? Stack(children: [
                              Image.file(_newImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                              Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.black.withOpacity(0.7),
                                        border: Border.all(
                                            color:
                                                const Color(0xFF2a2a3e)),
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: const Text('✓ New photo',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFFc9a84c))),
                                  )),
                            ])
                          : widget.gem['image_url'] != null
                              ? Stack(children: [
                                  Image.network(widget.gem['image_url'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity),
                                  Container(
                                      color:
                                          Colors.black.withOpacity(0.4)),
                                  const Center(
                                      child: Icon(
                                          Icons.photo_camera_outlined,
                                          color: Colors.white60,
                                          size: 28)),
                                ])
                              : const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_camera_outlined,
                                        size: 26,
                                        color: Color(0xFF4a4a62)),
                                    SizedBox(height: 8),
                                    Text('Tap to change photo',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF5a5a72))),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    controller: _nameController,
                    label: 'Gem Name',
                    hint: 'e.g. Blue Sapphire',
                    leading: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Text('💎',
                            style: TextStyle(fontSize: 14))),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _priceController,
                    label: 'Price (LKR)',
                    hint: '0.00',
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    leading: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 4),
                        child: Text('LKR',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6b6b7e)))),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _contactController,
                    label: 'Contact Number',
                    hint: '+94 7X XXX XXXX',
                    keyboardType: TextInputType.phone,
                    leading: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 8),
                        child: Icon(Icons.phone_outlined,
                            size: 15, color: Color(0xFF4a4a62))),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmAndUpdate,
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFc9a84c),
                          foregroundColor: const Color(0xFF0a0a0f),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✦',
                              style: TextStyle(fontSize: 13)),
                          SizedBox(width: 8),
                          Text('Update Listing',
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

// ─── Shared Dialog Widget ───────────────────────────────────────────────────

class _GemDialog extends StatelessWidget {
  final String icon, title, subtitle, confirmLabel;
  final Color confirmColor, confirmTextColor;
  final bool useGoldGradient;

  const _GemDialog({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.confirmColor,
    required this.confirmTextColor,
    this.useGoldGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF13131f),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2a2a3e))),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    color: Color(0xFFf0d080),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5a5a72),
                    height: 1.5)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1e1e2e),
                        border:
                            Border.all(color: const Color(0xFF2a2a3e)),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6b6b7e)))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: useGoldGradient ? null : confirmColor,
                      gradient: useGoldGradient
                          ? const LinearGradient(
                              colors: [
                                  Color(0xFFb8920e),
                                  Color(0xFFf0d080)
                                ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(confirmLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: confirmTextColor))),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}