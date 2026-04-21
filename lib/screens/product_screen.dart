// lib/screens/product_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<ProductModel> _products = [];
  List<ProductModel> _filtered = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedGender = 'All';
  bool _isGridView = true;

  static const List<String> _categories = [
    'All', 'Athletic', 'Formal', 'Casual', 'Outdoor', 'Kids', 'Sandals', 'Boots'
  ];
  static const List<String> _genders = [
    'All', 'men', 'women', 'kids', 'unisex'
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await DatabaseService().getProducts();
    setState(() {
      _products = products;
      _filtered = products;
      _loading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filtered = _products.where((p) {
        final matchesSearch = _searchQuery.isEmpty ||
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'All' || p.category == _selectedCategory;
        final matchesGender =
            _selectedGender == 'All' || p.gender == _selectedGender;
        return matchesSearch && matchesCategory && matchesGender;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppTheme.white,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.white),
            onPressed: _loadProducts,
          ),
          // Compact "+Add" button — no text overflow risk
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              ).then((_) => _loadProducts()),
              icon: const Icon(Icons.add, size: 15),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.white,
                foregroundColor: AppTheme.mahogany,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Bar ─────────────────────────────────────────
          Container(
            color: AppTheme.mahogany,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) {
                    _searchQuery = v;
                    _applyFilters();
                  },
                  style: const TextStyle(color: AppTheme.espresso, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search products by name or SKU...',
                    hintStyle: const TextStyle(
                        color: AppTheme.textFaint, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.leather, size: 20),
                    filled: true,
                    fillColor: AppTheme.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._categories.map((cat) => _FilterChip(
                            label: cat,
                            selected: _selectedCategory == cat,
                            onTap: () {
                              _selectedCategory = cat;
                              _applyFilters();
                            },
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Gender chips on separate row — prevents single row overflow
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._genders.map((g) => _FilterChip(
                            label: g == 'All'
                                ? 'All Genders'
                                : g[0].toUpperCase() + g.substring(1),
                            selected: _selectedGender == g,
                            onTap: () {
                              _selectedGender = g;
                              _applyFilters();
                            },
                            color: AppTheme.parchment,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results count ───────────────────────────────────────────────
          Container(
            color: AppTheme.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} products found',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),

          // ── Product grid / list ─────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.leather))
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48, color: AppTheme.border),
                            SizedBox(height: 12),
                            Text('No products found',
                                style: TextStyle(
                                    color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : _isGridView
                        ? _buildGrid(isWide)
                        : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(bool isWide) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    // Compute dynamic aspect ratio based on screen width so cards never overflow
    // Card content: image(flexible) + padding + name + sku + price row +
    //               sizes text + button row ≈ ~170px of non-image content
    // We allocate ~45% of card height to image, rest to content
    final cardWidth = (screenWidth - 32 - (crossCount - 1) * 14) / crossCount;
    // Image height ≈ cardWidth * 0.55, content ≈ 170px
    final cardHeight = cardWidth * 0.55 + 168.0;
    final aspectRatio = cardWidth / cardHeight;

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: aspectRatio,
      ),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) => _ProductGridCard(
        product: _filtered[i],
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  AddProductScreen(existingProduct: _filtered[i])),
        ).then((_) => _loadProducts()),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) => _ProductListCard(
        product: _filtered[i],
        onEdit: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  AddProductScreen(existingProduct: _filtered[i])),
        ).then((_) => _loadProducts()),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppTheme.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? color.withAlpha(230)
              : AppTheme.white.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? color
                  : AppTheme.beige.withAlpha(120)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.mahogany : AppTheme.white,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Product Grid Card ─────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;

  const _ProductGridCard(
      {required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(symbol: '\₹');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mahogany.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image — use Expanded so it fills remaining space proportionally
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14)),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.mahogany, AppTheme.leather],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _PlaceholderIcon(product.category),
                      )
                    : _PlaceholderIcon(product.category),
              ),
            ),
          ),

          // Content — fixed content area
          Expanded(
            flex: 6,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name + SKU
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            color: AppTheme.espresso,
                            fontWeight: FontWeight.w700,
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.sku,
                        style: const TextStyle(
                            color: AppTheme.textFaint,
                            fontSize: 9),
                      ),
                    ],
                  ),

                  // Price + category badge
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            priceFormatter.format(product.price),
                            style: const TextStyle(
                                color: AppTheme.mahogany,
                                fontWeight: FontWeight.w800,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.pillBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                              color: AppTheme.leather,
                              fontSize: 8),
                        ),
                      ),
                    ],
                  ),

                  // Sizes/colors
                  Text(
                    '${product.availableSizes.length} sizes • ${product.availableColors.length} colors',
                    style: const TextStyle(
                        color: AppTheme.textFaint, fontSize: 9),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showDetailSheet(context, product),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.mahogany,
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                            child: const Center(
                              child: Text(
                                'Details',
                                style: TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.pillBg,
                            borderRadius: BorderRadius.circular(7),
                            border:
                                Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              size: 12, color: AppTheme.leather),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, controller) =>
            ProductDetailSheet(product: product, scrollController: controller),
      ),
    );
  }
}

// ── Placeholder Icon ──────────────────────────────────────────────────────────
class _PlaceholderIcon extends StatelessWidget {
  final String category;
  const _PlaceholderIcon(this.category);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_rounded,
              size: 32, color: AppTheme.white.withAlpha(120)),
          const SizedBox(height: 4),
          Text(category,
              style: TextStyle(
                  color: AppTheme.white.withAlpha(100), fontSize: 9)),
        ],
      ),
    );
  }
}

// ── Product Detail Sheet ──────────────────────────────────────────────────────
class ProductDetailSheet extends StatelessWidget {
  final ProductModel product;
  final ScrollController? scrollController;
  const ProductDetailSheet(
      {super.key, required this.product, this.scrollController});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(symbol: '\₹');

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            color: AppTheme.espresso,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('SKU: ${product.sku}',
                        style: const TextStyle(
                            color: AppTheme.textFaint, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  priceFormatter.format(product.price),
                  style: const TextStyle(
                      color: AppTheme.mahogany,
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(
              icon: Icons.category_rounded,
              label: 'Category',
              value: product.category),
          _DetailRow(
              icon: Icons.people_rounded,
              label: 'Gender',
              value: product.gender),
          _DetailRow(
              icon: Icons.texture_rounded,
              label: 'Material',
              value: product.material),
          const SizedBox(height: 16),
          const Text('Description',
              style:
                  TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Text(product.description,
              style: const TextStyle(
                  color: AppTheme.espresso, fontSize: 14)),
          const SizedBox(height: 20),
          const Text('Available Sizes',
              style:
                  TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.availableSizes
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.pillBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(s,
                          style: const TextStyle(
                              color: AppTheme.espresso,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text('Available Colors',
              style:
                  TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.availableColors
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.leather.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.leather.withAlpha(70)),
                      ),
                      child: Text(c,
                          style: const TextStyle(
                              color: AppTheme.leather,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textFaint, size: 16),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.espresso,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Product List Card ─────────────────────────────────────────────────────────
class _ProductListCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;

  const _ProductListCard(
      {required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(symbol: '\₹');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mahogany.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.mahogany, AppTheme.leather]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.checkroom_rounded,
                color: AppTheme.white.withAlpha(180), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        color: AppTheme.espresso,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${product.category} • ${product.gender} • ${product.sku}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.availableSizes.length} sizes, ${product.availableColors.length} colors',
                  style: const TextStyle(
                      color: AppTheme.textFaint, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  priceFormatter.format(product.price),
                  style: const TextStyle(
                      color: AppTheme.mahogany,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.pillBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      size: 13, color: AppTheme.leather),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
