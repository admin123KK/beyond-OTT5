// lib/core/helper/image_helper.dart

class ImageUrlHelper {
  // These are initialized from dashboard (for movies/series)
  static String portrait = "";
  static String landscape = "";
  static String television = ""; // ← Will be ignored for Live TV now

  static void init(String p, String l, String t) {
    portrait = "https://ott.beyondtechnepal.com/$p";
    landscape = "https://ott.beyondtechnepal.com/$l";
    television = "https://ott.beyondtechnepal.com/$t"; // fallback if needed
  }

  // BEST & MOST ACCURATE FOR LIVE TV (Use this!)
  static String tvFromApi(String? filename) {
    if (filename == null || filename.isEmpty || filename == 'null') {
      return "https://via.placeholder.com/300/222222/FFFFFF?text=TV";
    }
    if (filename.startsWith('http')) return filename;
    return "https://ott.beyondtechnepal.com/assets/images/television/$filename";
  }

  // Legacy fallback (if you still want to support old method)
  static String tv(String? path) {
    if (path == null || path.isEmpty) {
      return "https://via.placeholder.com/300/222222/FFFFFF?text=TV";
    }
    if (path.startsWith('http')) return path;
    if (television.isNotEmpty) {
      return "$television$path";
    }
    // Fallback to known correct path
    return "https://ott.beyondtechnepal.com/assets/images/television/$path";
  }
}
