/// Thrown by data sources. Converted to a [Failure] in the repository layer.
class DataSourceException implements Exception {
  final String message;

  const DataSourceException(this.message);

  @override
  String toString() => 'DataSourceException: $message';
}
