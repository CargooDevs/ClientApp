import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../models/chat.dart';

/// Ecrã de conversa reutilizado pelos dois apps. `isDriver` diz de que lado
/// o utilizador atual está, para desenhar as bolhas de mensagem e gravar
/// sender_type/receiver_type corretamente na tabela `messages`.
class ChatScreen extends StatefulWidget {
  final String convId;
  final String otherPartyName;
  final bool isDriver;
  final String otherUserId;

  const ChatScreen({super.key, required this.convId, required this.otherPartyName, required this.isDriver, required this.otherUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    SupabaseService.client.from('messages').stream(primaryKey: ['message_id']).eq('conv_id', widget.convId).order('created_at').listen((rows) {
      if (!mounted) return;
      setState(() => _messages = rows.map((r) => ChatMessage.fromMap(r)).toList());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final myId = SupabaseService.uid;
    if (myId == null) return;
    await SupabaseService.client.from('messages').insert({
      'conv_id': widget.convId,
      'sender_type': widget.isDriver ? 'driver' : 'user',
      'receiver_type': widget.isDriver ? 'user' : 'driver',
      'sender_id': myId,
      'receiver_id': widget.otherUserId,
      'body': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = SupabaseService.uid;
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherPartyName)),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final mine = m.senderId == myId;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: mine ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: mine ? null : Border.all(color: AppColors.divider),
                    ),
                    child: Text(m.body, style: TextStyle(color: mine ? Colors.white : AppColors.textPrimary, fontSize: 14)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
            child: Row(children: [
              Expanded(
                child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Escreva uma mensagem...', isDense: true), onSubmitted: (_) => _send()),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _send, icon: const Icon(Icons.send, size: 18)),
            ]),
          ),
        ]),
      ),
    );
  }
}
