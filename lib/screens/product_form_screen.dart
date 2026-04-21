import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../theme.dart';

class ProductFormScreen extends StatefulWidget {
  final String token;
  final Product? product; // null = create, non-null = edit

  const ProductFormScreen({super.key, required this.token, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _stockCtrl;
  bool _loading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _categoryCtrl = TextEditingController(text: p?.category ?? '');
    _imageCtrl = TextEditingController(text: p?.image ?? '');
    _stockCtrl =
        TextEditingController(text: p != null ? p.stock.toString() : '0');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _imageCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'category': _categoryCtrl.text.trim(),
      'image': _imageCtrl.text.trim(),
      'stock': int.parse(_stockCtrl.text),
    };

    final provider = context.read<ProductProvider>();
    bool success;

    if (_isEditing) {
      success = await provider.updateProduct(
          widget.token, widget.product!.id, data);
    } else {
      success = await provider.createProduct(widget.token, data);
    }

    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? 'Terjadi kesalahan'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'EDIT PRODUK' : 'TAMBAH PRODUK'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nama Produk',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama produk wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _categoryCtrl,
                  label: 'Kategori',
                  hint: 'Contoh: skincare, fragrance, makeup',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Kategori wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _priceCtrl,
                  label: 'Harga (Rp)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Harga wajib diisi';
                    if (double.tryParse(v) == null) return 'Harga tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _stockCtrl,
                  label: 'Stok',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Stok wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _imageCtrl,
                  label: 'URL Gambar (opsional)',
                  hint: 'https://...',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH PRODUK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }
}
