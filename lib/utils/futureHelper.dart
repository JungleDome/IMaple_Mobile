class FutureHelper {
  static Future<T> retry<T>(int retries, Future aFuture,
      {Duration delay = const Duration(seconds: 2)}) async {
    try {
      return await aFuture;
    } catch (e) {
      if (retries > 1) {
        if (delay != null) {
          await Future.delayed(delay);
        }
        return retry(retries - 1, aFuture);
      }
      rethrow;
    }
  }
}
