class FilterModel {
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterModel({this.searchQuery = '', this.startDate, this.endDate});

  FilterModel copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return FilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}
