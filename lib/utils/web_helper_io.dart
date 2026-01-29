// IO implementation (does nothing, handled differently)
class WebHelper {
  static void downloadFile(String content, String filename) {
    // For non-web platforms, file download is handled via path_provider
    throw UnsupportedError(
        'Use ExportService.saveCsvToFile for non-web platforms');
  }
}
