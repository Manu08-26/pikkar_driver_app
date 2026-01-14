class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final int? results;
  final PaginationData? pagination;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.results,
    this.pagination,
  });

  bool get isSuccess => status == 'success';
  bool get isFail => status == 'fail' || status == 'error';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Backend compatibility:
    // Some endpoints return { status: 'success' } while others return { success: true }.
    final bool? successFlag = json['success'] is bool ? (json['success'] as bool) : null;
    final String resolvedStatus = (json['status'] as String?) ??
        (successFlag == true ? 'success' : 'fail');

    // Support both `results` and `count` fields.
    final int? resolvedResults = (json['results'] as int?) ??
        (json['count'] is int ? (json['count'] as int) : null);

    return ApiResponse(
      status: resolvedStatus,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      results: resolvedResults,
      pagination: json['pagination'] != null
          ? PaginationData.fromJson(json['pagination'])
          : json['data']?['pagination'] != null
              ? PaginationData.fromJson(json['data']['pagination'])
              : null,
    );
  }
}

class PaginationData {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationData({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
    );
  }

  bool get hasMore => page < pages;
}
