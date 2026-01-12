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
    dynamic json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Defensive parsing: backend (or proxy) might return an array or plain string
    // in error scenarios. Avoid runtime type crashes like:
    // "type 'List<Object?>' is not a subtype of type 'Map<String, dynamic>'".
    if (json is! Map<String, dynamic>) {
      return ApiResponse(
        status: 'fail',
        message:
            'Invalid server response (expected object, got ${json.runtimeType}).',
        data: null,
      );
    }

    return ApiResponse(
      status: json['status'] ?? 'fail',
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      results: json['results'],
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
