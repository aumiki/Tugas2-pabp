import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context
          .read<ProductProvider>()
          .fetchProductById(auth.accessToken!, widget.productId);
    });
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(price);
  }

  Future<void> _confirmDelete(
      BuildContext context, String token, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Produk',
            style: Theme.of(context).textTheme.titleLarge),
        content: Text('Apakah Anda yakin ingin menghapus produk ini?',
            style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<ProductProvider>().deleteProduct(token, id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Produk berhasil dihapus'),
            backgroundColor: AppColors.success));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProductProvider>(
        builder: (_, p, __) {
          final product = p.selectedProduct;

          if (product == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: AppColors.primary),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.edit_outlined,
                          size: 20, color: AppColors.primary),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductFormScreen(
                                  token: auth.accessToken!,
                                  product: product)));
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline,
                          size: 20, color: AppColors.error),
                    ),
                    onPressed: () => _confirmDelete(
                        context, auth.accessToken!, product.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProductImage(imageUrl: product.image),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          border:
                              Border.all(color: AppColors.secondary, width: 1),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 10,
                                  letterSpacing: 1.5),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(product.name,
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 8),

                      Text(
                        _formatPrice(product.price),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: AppColors.secondary),
                      ),
                      const SizedBox(height: 4),

                      // Stock indicator
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: product.stock > 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.stock > 0
                                ? 'Tersedia (${product.stock} unit)'
                                : 'Stok habis',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: product.stock > 0
                                        ? AppColors.success
                                        : AppColors.error),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Divider(color: AppColors.cardBorder),
                      const SizedBox(height: 24),

                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        Text('Deskripsi',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Text(
                          product.description!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  height: 1.8,
                                  color: AppColors.textSecondary),
                        ),
                      ],

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: AppColors.accent,
        child: const Center(
          child: Icon(Icons.diamond_outlined,
              size: 80, color: AppColors.secondary),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.accent,
        child: const Center(
          child: Icon(Icons.diamond_outlined,
              size: 80, color: AppColors.secondary),
        ),
      ),
    );
  }
}
