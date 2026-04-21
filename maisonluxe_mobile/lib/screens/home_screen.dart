import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../theme.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_card.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.accessToken != null) {
        context.read<ProductProvider>().fetchProducts(auth.accessToken!);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.accessToken != null) {
      await context.read<ProductProvider>().fetchProducts(auth.accessToken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MAISONLUXE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final auth = context.read<AuthProvider>();
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductFormScreen(token: auth.accessToken!)));
          _refresh();
        },
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: context.read<ProductProvider>().setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
                suffixIcon: Consumer<ProductProvider>(
                  builder: (_, p, __) => p.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 18, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            p.setSearchQuery('');
                          })
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Category filter
          Consumer<ProductProvider>(
            builder: (_, p, __) {
              if (p.status == ProductStatus.loaded ||
                  p.categories.length > 1) {
                return Container(
                  color: AppColors.surface,
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: p.categories.length,
                    itemBuilder: (_, i) {
                      final cat = p.categories[i];
                      final isSelected = cat == p.selectedCategory;
                      return GestureDetector(
                        onTap: () => p.setCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontSize: 11,
                                    letterSpacing: 1,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Product list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (_, p, __) {
                // LOADING STATE
                if (p.status == ProductStatus.loading ||
                    p.status == ProductStatus.initial) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => const ShimmerCard(),
                  );
                }

                // ERROR STATE
                if (p.status == ProductStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('Gagal memuat produk',
                              style:
                                  Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(p.errorMessage ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('COBA LAGI'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // DATA STATE
                final products = p.filteredProducts;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('Produk tidak ditemukan',
                            style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.secondary,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      return ProductCard(
                        product: products[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                                productId: products[i].id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
