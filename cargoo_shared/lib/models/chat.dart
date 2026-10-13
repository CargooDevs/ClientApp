enum ChatParticipant { user, driver }

ChatParticipant _participantFromDb(String? v) => v == 'driver' ? ChatParticipant.driver : ChatParticipant.user;

class ChatConversation {
  final String convId;
  final String userId;
  final String driverId;

  const ChatConversation({required this.convId, required this.userId, required this.driverId});

  factory ChatConversation.fromMap(Map<String, dynamic> map) => ChatConversation(
        convId: map['conv_id'] as String,
        userId: map['user_id'] as String,
        driverId: map['driver_id'] as String,
      );
}

class ChatMessage {
  final String messageId;
  final String convId;
  final ChatParticipant senderType;
  final ChatParticipant receiverType;
  final String senderId;
  final String receiverId;
  final String body;
  final DateTime? createdAt;

  const ChatMessage({
    required this.messageId,
    required this.convId,
    required this.senderType,
    required this.receiverType,
    required this.senderId,
    required this.receiverId,
    required this.body,
    this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        messageId: map['message_id'] as String,
        convId: map['conv_id'] as String,
        senderType: _participantFromDb(map['sender_type'] as String?),
        receiverType: _participantFromDb(map['receiver_type'] as String?),
        senderId: map['sender_id'] as String,
        receiverId: map['receiver_id'] as String,
        body: map['body'] as String? ?? '',
        createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      );
}
