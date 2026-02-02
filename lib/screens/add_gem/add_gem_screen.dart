import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../providers/gem_provider.dart';

class AddGemScreen extends StatefulWidget {
  const AddGemScreen({super.key});

  @override
  State<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends State<AddGemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  
  String? _selectedColor;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final List<String> _gemColors = [
    'Ruby',
    'Sapphire',
    'Emerald',
    'Diamond',
    'Topaz',
    'Amethyst',
    'Opal',
    'Pearl',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final gemProvider = Provider.of<GemProvider>(context, listen: false);
      
      final imageUrls = await gemProvider.uploadImages(_selectedImages);
      
      final success = await gemProvider.createGem(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        color: _selectedColor,
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.parse(_weightController.text.trim()),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        contactName: _contactNameController.text.trim().isEmpty
            ? null
            : _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim().isEmpty
            ? null
            : _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        imageUrls: imageUrls,
      );

      setState(() {
        _isUploading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gem added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _selectedImages = [];
          _selectedColor = null;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gemProvider.errorMessage ?? 'Failed to add gem'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Gem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImages.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Add Images',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter gem title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter gem description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  hintText: 'Enter price',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Color',
                ),
                items: _gemColors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (carats)',
                  hintText: 'Enter weight',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'Enter model',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Contact Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'Enter contact name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactEmailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'Enter email address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Add Gem',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
