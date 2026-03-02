/// A paginated response containing a list of items.
class PaginatedResponse<T> {
  /// Creates a new [PaginatedResponse].
  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  /// Creates a [PaginatedResponse] from a JSON map.
  ///
  /// The [fromJsonT] function is used to convert each item in the list.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsList = json['items'] as List<dynamic>;
    return PaginatedResponse<T>(
      items: itemsList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  /// The list of items in this page.
  final List<T> items;

  /// Total number of items across all pages.
  final int totalCount;

  /// Current page number (1-indexed).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Whether there is a next page.
  bool get hasNextPage => page < totalPages;

  /// Whether there is a previous page.
  bool get hasPreviousPage => page > 1;

  /// Converts this [PaginatedResponse] to a JSON map.
  ///
  /// The [toJsonT] function is used to convert each item in the list.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'totalCount': totalCount,
      'page': page,
      'pageSize': pageSize,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse(page: $page/$totalPages, items: ${items.length}, total: $totalCount)';
  }
}
