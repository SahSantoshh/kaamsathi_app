/// Shared Pagy pagination metadata (`GET …?page&items`).
class PagyMeta {
  const PagyMeta({
    required this.page,
    required this.items,
    required this.count,
    required this.pages,
  });

  final int page;
  final int items;
  final int count;
  final int pages;

  factory PagyMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PagyMeta(page: 1, items: 0, count: 0, pages: 1);
    }
    return PagyMeta(
      page: pagyAsInt(json['page'], fallback: 1),
      items: pagyAsInt(json['items']),
      count: pagyAsInt(json['count']),
      pages: pagyAsInt(json['pages'], fallback: 1),
    );
  }
}

int pagyAsInt(Object? v, {int fallback = 0}) {
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  return fallback;
}
