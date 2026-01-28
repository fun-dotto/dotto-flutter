enum SearchCourseDomainError implements Exception {
  overSelected(message: '3科目以上選択することはできません')
  ;

  const SearchCourseDomainError({required this.message});

  final String message;

  @override
  String toString() => 'SearchCourseDomainError: $message';
}
