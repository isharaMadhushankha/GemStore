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