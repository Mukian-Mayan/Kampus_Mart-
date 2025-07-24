// utils/chat_utils.dart
import '../services/chat_debug_service.dart';

class ChatUtils {
  /// Force refresh all chat-related caches and debug user profiles
  static Future<void> refreshChatData() async {
    try {
      print('ChatUtils: Starting chat data refresh...');

      // Debug current user profile
      await ChatDebugService.debugCurrentUserProfile();

      // Clear caches
      // Note: You'll need to create a static ChatService instance or pass it in
      print('ChatUtils: Chat data refresh completed');
    } catch (e) {
      print('ChatUtils: Error refreshing chat data: $e');
    }
  }

  /// Get a safe display name for a user
  static String getSafeDisplayName(String? name, String userId) {
    if (name == null || name.isEmpty || name.startsWith('User ')) {
      return 'User';
    }
    return name;
  }

  /// Get initials from a name safely
  static String getSafeInitials(String? name) {
    if (name == null || name.isEmpty) {
      return '?';
    }

    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
  }
}
