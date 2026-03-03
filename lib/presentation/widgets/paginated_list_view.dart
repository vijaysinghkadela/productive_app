import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants.dart';

/// Reusable paginated list view with lazy-loading, skeleton placeholders,
/// and scroll-based pagination for memory-efficient list rendering.
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<List<T>> Function(int page)? onLoadMore;
  final int pageSize;
  final Widget? emptyWidget;
  final Widget? header;
  final EdgeInsets padding;
  final bool hasReachedEnd;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.pageSize = 20,
    this.emptyWidget,
    this.header,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.hasReachedEnd = false,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _scrollController = ScrollController();
  bool _loading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || widget.hasReachedEnd || widget.onLoadMore == null) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger load when 200px from bottom
    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading) return;
    setState(() => _loading = true);
    _currentPage++;
    await widget.onLoadMore?.call(_currentPage);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !_loading) {
      return widget.emptyWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Text(
                'No items yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length +
          (_loading ? 3 : 0) +
          (widget.header != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.header != null && index == 0) {
          return widget.header!;
        }
        final adjustedIndex = widget.header != null ? index - 1 : index;
        if (adjustedIndex < widget.items.length) {
          return widget.itemBuilder(
              context, widget.items[adjustedIndex], adjustedIndex);
        }
        // Skeleton loading placeholder
        return const _SkeletonItem();
      },
    );
  }
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF141A33) : const Color(0xFFE8EAF0),
        highlightColor:
            isDark ? const Color(0xFF1E2545) : const Color(0xFFF5F5F5),
        child: Container(
          height: AppSizes.cardMinHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}
