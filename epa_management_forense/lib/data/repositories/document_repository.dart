abstract interface class DocumentRepository {
  Future<void> ingest(String sourcePath, String sourceType);
  Future<List<Map<String, dynamic>>> listDocuments();
}
