// lib/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? existingProduct;
  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _materialCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String _category = 'Athletic';
  String _gender = 'unisex';
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  bool _isLoading = false;

  static const List<String> _allSizes = ['34','35','36','37','38','39','40','41','42','43','44','45','46','47'];
  static const List<String> _allColors = ['Black','White','Red','Blue','Brown','Tan','Nude','Pink','Green','Yellow','Grey','Navy','Purple','Orange','Khaki'];
  static const List<String> _categories = ['Athletic','Formal','Casual','Outdoor','Kids','Sandals','Boots'];
  static const List<String> _genders = ['men','women','kids','unisex'];

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _nameCtrl.text = p.name;
      _skuCtrl.text = p.sku;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toString();
      _materialCtrl.text = p.material;
      _imageUrlCtrl.text = p.imageUrl;
      _category = p.category;
      _gender = p.gender;
      _selectedSizes = List.from(p.availableSizes);
      _selectedColors = List.from(p.availableColors);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _skuCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _materialCtrl.dispose(); _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSizes.isEmpty) {
      _showError('Select at least one size');
      return;
    }
    if (_selectedColors.isEmpty) {
      _showError('Select at least one color');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = DatabaseService();
      final product = ProductModel(
        id: widget.existingProduct?.id,
        name: _nameCtrl.text,
        sku: _skuCtrl.text,
        category: _category,
        description: _descCtrl.text,
        availableSizes: _selectedSizes,
        availableColors: _selectedColors,
        price: double.parse(_priceCtrl.text),
        imageUrl: _imageUrlCtrl.text,
        material: _materialCtrl.text,
        gender: _gender,
        createdAt: widget.existingProduct?.createdAt ?? DateTime.now(),
      );

      if (widget.existingProduct != null) {
        await db.updateProduct(product);
      } else {
        await db.addProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingProduct != null ? 'Product updated!' : 'Product added!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProduct != null ? 'Edit Product' : 'Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard('Basic Information', [
                _buildTextField(_nameCtrl, 'Product Name', Icons.shopping_bag_outlined),
                const SizedBox(height: 14),
                _buildTextField(_skuCtrl, 'SKU Code', Icons.qr_code_rounded,
                    hint: 'e.g. AWP-001'),
                const SizedBox(height: 14),
                _buildTextField(_descCtrl, 'Description', Icons.description_outlined, maxLines: 3),
                const SizedBox(height: 14),
                _buildTextField(_priceCtrl, 'Price (INR)', Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter valid price';
                      return null;
                    }),
                const SizedBox(height: 14),
                _buildTextField(_materialCtrl, 'Material', Icons.texture_rounded),
                const SizedBox(height: 14),
                _buildTextField(_imageUrlCtrl, 'Image URL', Icons.image_outlined, required: false),
              ]),

              const SizedBox(height: 16),
              _buildCard('Category & Target', [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown('Category', _category, _categories,
                          (v) => setState(() => _category = v!)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown('Gender', _gender, _genders,
                          (v) => setState(() => _gender = v!)),
                    ),
                  ],
                ),
              ]),

              const SizedBox(height: 16),
              _buildCard('Available Sizes', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSizes.map((size) {
                    final selected = _selectedSizes.contains(size);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedSizes.remove(size);
                        } else {
                          _selectedSizes.add(size);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 48,
                        height: 42,
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.mahogany : AppTheme.pillBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? AppTheme.mahogany : AppTheme.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          size,
                          style: TextStyle(
                            color: selected ? AppTheme.white : AppTheme.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),

              const SizedBox(height: 16),
              _buildCard('Available Colors', [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allColors.map((color) {
                    final selected = _selectedColors.contains(color);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedColors.remove(color);
                        } else {
                          _selectedColors.add(color);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.leather.withAlpha(30) : AppTheme.pillBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppTheme.leather : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          color,
                          style: TextStyle(
                            color: selected ? AppTheme.leather : AppTheme.textMuted,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: AppTheme.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(widget.existingProduct != null
                      ? 'Update Product' : 'Save Product'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(
          color: AppTheme.mahogany.withAlpha(8),
          blurRadius: 8,
          offset: const Offset(0, 2),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.espresso,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Divider(color: AppTheme.border, height: 20),
          ...children,
        ],
      ),
    );
  }

  TextFormField _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.espresso),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textFaint),
        prefixIcon: Icon(icon),
      ),
      validator: validator ?? (required ? (v) => v!.isEmpty ? '$label is required' : null : null),
    );
  }

  Widget _buildDropdown(String label, String selectedValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          dropdownColor: AppTheme.white,
          style: const TextStyle(color: AppTheme.espresso, fontSize: 14),
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(color: AppTheme.espresso)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
