import 'package:sociord/models/chat_message_model.dart';

class ChatMockData {
  static List<ChatMessage> getMessages() {
    final now = DateTime.now();

    return [
      // Today's messages
      ChatMessage(
        id: '1',
        text:
            "Arjun! I was just thinking about you yesterday. I'm doing alright—mostly juggling work and way too many Netflix recommendations. You?",
        timestamp: now.subtract(const Duration(hours: 2, minutes: 22)),
        isFromMe: false,
        isRead: true,
      ),
      ChatMessage(
        id: '2',
        text:
            "Pretty much the same. My job's slowly draining my soul but hey, still breathing for now.",
        timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
        isFromMe: true,
        isRead: true,
      ),
      ChatMessage(
        id: '3',
        text:
            "Remember when we thought the biggest responsibility was deciding where to eat after class?",
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        isFromMe: false,
        isRead: true,
      ),
      ChatMessage(
        id: '4',
        text: "YES! 😄",
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        isFromMe: true,
        isRead: true,
        reactions: ['❤️'],
      ),
      ChatMessage(
        id: '5',
        text: "Anyway, let's catch up properly. How about coffee this weekend?",
        timestamp: now.subtract(const Duration(hours: 1, minutes: 53)),
        isFromMe: false,
        isRead: true,
        reactions: ['❤️'],
      ),
      ChatMessage(
        id: '6',
        text:
            "Yes, please! I've been meaning to escape my four walls. Saturday afternoon? If nothing else, we can complain about being responsible adults together. 😊",
        timestamp: now.subtract(const Duration(hours: 1, minutes: 51)),
        isFromMe: true,
        isRead: true,
        replyToMessage: ChatMessage(
          id: '5',
          text:
              "Anyway, let's catch up properly. How about coffee this weekend?",
          timestamp: now.subtract(const Duration(hours: 1, minutes: 53)),
          isFromMe: false,
          isRead: true,
        ),
      ),
      ChatMessage(
        id: '7',
        text: "Sounds like a plan",
        timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        isFromMe: false,
        isRead: true,
      ),
      ChatMessage(
        id: '8',
        text:
            "Perfect! Let's meet at that coffee shop near the park. I'll be there around 2 PM. Can't wait to catch up!",
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isFromMe: false,
        isRead: true,
        replyToMessage: ChatMessage(
          id: '6',
          text:
              "Yes, please! I've been meaning to escape my four walls. Saturday afternoon? If nothing else, we can complain about being responsible adults together. 😊",
          timestamp: now.subtract(const Duration(hours: 1, minutes: 51)),
          isFromMe: true,
          isRead: true,
        ),
      ),
    ];
  }
}
