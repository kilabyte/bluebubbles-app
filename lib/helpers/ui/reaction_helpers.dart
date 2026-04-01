import 'package:bluebubbles/database/models.dart' hide Entity;
import 'package:emojis/emojis.dart';
import 'package:flutter/foundation.dart';

class ReactionTypes {
  // ignore: non_constant_identifier_names
  static const String LOVE = "love";
  // ignore: non_constant_identifier_names
  static const String LIKE = "like";
  // ignore: non_constant_identifier_names
  static const String DISLIKE = "dislike";
  // ignore: non_constant_identifier_names
  static const String LAUGH = "laugh";
  // ignore: non_constant_identifier_names
  static const String EMPHASIZE = "emphasize";
  // ignore: non_constant_identifier_names
  static const String QUESTION = "question";

  static List<String> toList() {
    return [
      LOVE,
      LIKE,
      DISLIKE,
      LAUGH,
      EMPHASIZE,
      QUESTION,
    ];
  }

  static final Map<String, String> reactionToVerb = {
    LOVE: "loved",
    LIKE: "liked",
    DISLIKE: "disliked",
    LAUGH: "laughed at",
    EMPHASIZE: "emphasized",
    QUESTION: "questioned",
    "-$LOVE": "removed a heart from",
    "-$LIKE": "removed a like from",
    "-$DISLIKE": "removed a dislike from",
    "-$LAUGH": "removed a laugh from",
    "-$EMPHASIZE": "removed an exclamation from",
    "-$QUESTION": "removed a question mark from",
  };

  static final Map<String, String> reactionToEmoji = {
    LOVE: Emojis.redHeart,
    LIKE: Emojis.thumbsUp,
    DISLIKE: Emojis.thumbsDown,
    LAUGH: Emojis.faceWithTearsOfJoy,
    EMPHASIZE: Emojis.redExclamationMark,
    QUESTION: Emojis.redQuestionMark,
  };

  static final Map<String, String> emojiToReaction = {
    Emojis.redHeart: LOVE,
    Emojis.thumbsUp: LIKE,
    Emojis.thumbsDown: DISLIKE,
    Emojis.faceWithTearsOfJoy: LAUGH,
    Emojis.redExclamationMark: EMPHASIZE,
    Emojis.redQuestionMark: QUESTION,
  };

  /// Returns true if [type] is a classic tapback or an emoji reaction.
  static bool isValidReaction(String? type) {
    if (type == null || type.isEmpty) return false;
    final cleaned = type.replaceAll("-", "");
    return toList().contains(cleaned) || isEmojiReaction(cleaned);
  }

  /// Returns true if [type] is an emoji reaction (not a classic tapback or sticker).
  static bool isEmojiReaction(String? type) {
    if (type == null || type.isEmpty) return false;
    final cleaned = type.replaceAll("-", "");
    return !toList().contains(cleaned) && cleaned != "sticker";
  }

  /// Returns the emoji to display for a reaction type.
  /// Classic tapbacks map to their emoji; emoji reactions ARE the emoji.
  static String getReactionEmoji(String type) {
    return reactionToEmoji[type] ?? type;
  }

  /// Returns a verb phrase for notification text.
  /// Classic tapbacks use the verb map; emoji reactions use "reacted [emoji] to".
  static String getReactionVerb(String type) {
    if (reactionToVerb.containsKey(type)) return reactionToVerb[type]!;
    if (type.startsWith("-")) return "removed a ${ type.substring(1)} reaction from";
    return "reacted $type to";
  }
}

List<Message> getUniqueReactionMessages(List<Message> messages) {
  List<int> handleCache = [];
  List<Message> output = [];
  // Sort the messages, putting the latest at the top
  final ids = messages.map((e) => e.guid).toSet();
  messages.retainWhere((element) => ids.remove(element.guid));
  messages.sort(Message.sort);
  // Iterate over the messages and insert the latest reaction for each user
  for (Message msg in messages) {
    int cache = msg.isFromMe! ? 0 : msg.handleId ?? 0;
    if (!handleCache.contains(cache) && !kIsWeb) {
      handleCache.add(cache);
      // Only add the reaction if it's not a "negative"
      if (!msg.associatedMessageType!.startsWith("-")) {
        output.add(msg);
      }
    } else if (kIsWeb && !msg.associatedMessageType!.startsWith("-")) {
      output.add(msg);
    }
  }

  return output;
}