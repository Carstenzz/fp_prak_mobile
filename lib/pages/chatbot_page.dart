import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_endpoints.dart';
import '../services/user_service.dart';
import '../services/item_service.dart';
import '../services/category_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _memeMode = false;

  @override
  void initState() {
    super.initState();
    _initChatContext();
    // Tambahkan pesan pembuka bot
    _messages.add({
      'role': 'bot',
      'text':
          'Halo, aku adalah asisten khusus inventario🤌. Aku akan membantumu menjawab pertanyaan seputar barang atau kategori yang ada di inventarismu',
    });
  }

  Future<void> _initChatContext() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await UserService.getToken();
      if (token == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final items = await ItemService().getItems(token);
      final categories = await CategoryService().getCategories(token);
      final itemContext = items
          .map(
            (item) =>
                'id: ${item.id}, name: ${item.name}, qty: ${item.quantity}, category: ${item.categoryId}',
          )
          .join('; ');
      final categoryContext = categories
          .map((cat) => 'id: ${cat.id}, name: ${cat.name}')
          .join('; ');
      final contextText =
          _memeMode
              ? 'Context: Items: $itemContext | Categories: $categoryContext | Role: kamu adalah asisten khusus inventario🤌. kamu akan membantu user menjawab pertanyaan seputar barang atau kategori yang ada di inventarisnya. Jawab semua pertanyaan dengan nada bercanda dan penuh lelucon yang mengungkit ungkit dan mengkritik pemerintah, jajaran presiden, menteri, dan sekitarnya, seperti menambahkan lelucon lucu tentang gibran dan ai, jokowi, prabowo, luhut, tungtungtung sahur, dan meme tren lainnya, atau meme seperti "hidup jokowi!!", "we wok de tok", atau meme pemerintah lainnya'
              : 'Context: Items: $itemContext | Categories: $categoryContext | Role: kamu adalah asisten khusus inventario🤌. kamu akan membantu user menjawab pertanyaan seputar barang atau kategori yang ada di inventarisnya';
      // Simpan context di variabel, tapi JANGAN tampilkan di UI
      _contextMessage = {'role': 'user', 'text': contextText};
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data awal chatbot.')),
      );
    }
  }

  Map<String, String>? _contextMessage;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _contextMessage == null) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    final token = await UserService.getToken();
    // Kirim hanya context dan pesan user terakhir
    final userMessages = <Map<String, String>>[
      _contextMessage!,
      {'role': 'user', 'text': text},
    ];
    final response = await http.post(
      Uri.parse(ApiEndpoints.baseUrl + '/chat'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'messages': userMessages}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.add({'role': 'bot', 'text': data['response'] ?? ''});
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan.')));
    }
    _controller.clear();
  }

  void _toggleMemeMode() async {
    setState(() {
      _memeMode = !_memeMode;
    });
    await _initChatContext();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 60,
              vertical: 24,
            ),
            content: Text(
              _memeMode ? 'mode pinggir jurang' : 'mode normal',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot AI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - 1 - index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isUser ? Colors.blue[900] : Colors.black87,
                        fontWeight:
                            isUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Meme mode toggle icon
                IconButton(
                  icon: Text(
                    _memeMode ? '😋' : '🤌',
                    style: TextStyle(fontSize: 28),
                  ),
                  tooltip: 'Toggle Meme Mode',
                  onPressed: _toggleMemeMode,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed:
                      _isLoading ? null : () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
