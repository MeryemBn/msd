import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:uuid/uuid.dart';
import '../services/chatbot_service.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import './settings_provider.dart';

class Message {
  final String text;
  final bool isUser;
  final String? route;
  final DateTime timestamp;

  Message({
    required this.text, 
    required this.isUser, 
    this.route,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'route': route,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<dynamic, dynamic> map) {
    return Message(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      route: map['route'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Message copyWith({String? text, String? route}) {
    return Message(
      text: text ?? this.text,
      isUser: isUser,
      route: route ?? this.route,
      timestamp: timestamp,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime updatedAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toMap()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatSession.fromMap(Map<dynamic, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      messages: (map['messages'] as List).map((m) => Message.fromMap(m)).toList(),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ChatSession copyWith({List<Message>? messages, String? title, DateTime? updatedAt}) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ChatbotState {
  final List<Message> messages;
  final List<ChatSession> history;
  final String? currentSessionId;
  final bool isLoading;
  final bool showingHistory;

  ChatbotState({
    this.messages = const [],
    this.history = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.showingHistory = false,
  });

  ChatbotState copyWith({
    List<Message>? messages,
    List<ChatSession>? history,
    String? currentSessionId,
    bool? isLoading,
    bool? showingHistory,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      history: history ?? this.history,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      showingHistory: showingHistory ?? this.showingHistory,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final ChatbotService _chatbotService;
  final Ref _ref;
  final String _userId;
  Box? _historyBox;
  final _uuid = const Uuid();

  ChatbotNotifier(this._chatbotService, this._ref, this._userId) : super(ChatbotState()) {
    _initHive();
  }

  Future<void> _initHive() async {
    _historyBox = await Hive.openBox('chatbot_multi_history_box');
    _loadAllHistory();
  }

  void _loadAllHistory() {
    final List<dynamic>? savedHistory = _historyBox?.get('sessions_$_userId');
    List<ChatSession> sessions = [];
    if (savedHistory != null) {
      sessions = savedHistory.map((s) => ChatSession.fromMap(s)).toList();
      sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    if (sessions.isNotEmpty) {
      state = state.copyWith(
        history: sessions,
        messages: sessions.first.messages,
        currentSessionId: sessions.first.id,
      );
    } else {
      _startNewSession();
    }
  }

  void _startNewSession() {
    final newId = _uuid.v4();
    final lang = _ref.read(settingsProvider).locale.languageCode;
    String welcome = _getWelcomeMessage(lang);
    
    final initialMessage = Message(text: welcome, isUser: false);
    final newSession = ChatSession(
      id: newId,
      title: lang == 'ar' ? "محادثة جديدة" : (lang == 'en' ? "New Chat" : "Nouvelle discussion"),
      messages: [initialMessage],
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [initialMessage],
      currentSessionId: newId,
      history: [newSession, ...state.history],
      showingHistory: false,
    );
    _saveAllToHive();
  }

  String _getWelcomeMessage(String lang) {
    if (lang == 'ar') {
      return "مرحباً! أنا مساعد **MSD** الذكي. يمكنني مساعدتك في فهم أعراضك، اختيار الطبيب المناسب، أو إرشادك في استخدام التطبيق.\n\n⚠️ **تنبيه**: نصائحي لا تعوض الطبيب. في حالات الطوارئ اتصل بـ 15.";
    } else if (lang == 'en') {
      return "Hello! I am your **MSD** AI Assistant. I can help you with symptoms, finding the right specialist, or guiding you through the app.\n\n⚠️ **Note**: My advice does not replace a doctor. In case of emergency, call 112.";
    } else {
      return "Bonjour ! Je suis l'assistant intelligent de **MSD**.\n\nJe suis là pour vous aider à analyser vos symptômes, vous orienter vers le bon spécialiste (Généraliste, Gastro, etc.) ou vous guider dans l'utilisation de l'application (planning, paiements, suivi GPS).\n\n⚠️ **Note importante** : Je suis un assistant virtuel. En cas d'urgence vitale, appelez immédiatement le **15** ou le **112**.";
    }
  }

  Future<void> sendMessage(String text) async {
    if (state.currentSessionId == null) _startNewSession();

    final userMessage = Message(text: text, isUser: true);
    
    String? newTitle;
    if (state.messages.where((m) => m.isUser).isEmpty) {
      newTitle = text.length > 30 ? "${text.substring(0, 27)}..." : text;
    }

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      final language = _ref.read(settingsProvider).locale.languageCode;
      final response = await _chatbotService.askChatbot(text, language);
      
      final aiText = response['text'] ?? "Désolé, je n'ai pas pu générer de réponse.";
      final aiRoute = response['route'];

      final aiMessage = Message(
        text: aiText,
        isUser: false,
        route: aiRoute,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
      
      _updateCurrentSession(state.messages, newTitle);
      
    } catch (e) {
      state = state.copyWith(
        messages: [...state.messages, Message(text: "Désolé, une erreur est survenue lors de la communication avec le serveur.", isUser: false)],
        isLoading: false,
      );
    }
  }

  void _updateCurrentSession(List<Message> messages, String? title) {
    final updatedHistory = state.history.map((session) {
      if (session.id == state.currentSessionId) {
        return session.copyWith(
          messages: messages,
          title: title ?? session.title,
          updatedAt: DateTime.now(),
        );
      }
      return session;
    }).toList();

    updatedHistory.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    state = state.copyWith(history: updatedHistory);
    _saveAllToHive();
  }

  void _saveAllToHive() {
    final List<Map<String, dynamic>> data = state.history.map((s) => s.toMap()).toList();
    _historyBox?.put('sessions_$_userId', data);
  }

  void newChat() {
    _startNewSession();
  }

  void toggleHistory() {
    state = state.copyWith(showingHistory: !state.showingHistory);
  }

  void loadSession(ChatSession session) {
    state = state.copyWith(
      messages: session.messages,
      currentSessionId: session.id,
      showingHistory: false,
    );
  }

  void deleteSession(String id) {
    final updatedHistory = state.history.where((s) => s.id != id).toList();
    
    if (state.currentSessionId == id) {
      if (updatedHistory.isNotEmpty) {
        final nextSession = updatedHistory.first;
        state = state.copyWith(
          history: updatedHistory,
          messages: nextSession.messages,
          currentSessionId: nextSession.id,
          showingHistory: true,
        );
      } else {
        _startNewSession();
        state = state.copyWith(showingHistory: true);
      }
    } else {
      state = state.copyWith(
        history: updatedHistory,
        showingHistory: true,
      );
    }
    _saveAllToHive();
  }
}

final chatbotServiceProvider = Provider((ref) => ChatbotService(ref.read(apiClientProvider)));

/// Provider du Chatbot avec autoDispose pour garantir la fraîcheur de l'état
/// Il se recrée automatiquement à chaque changement d'utilisateur (login/logout)
final chatbotProvider = StateNotifierProvider.autoDispose<ChatbotNotifier, ChatbotState>((ref) {
  // On surveille uniquement l'accessToken pour détecter les changements d'identité
  final accessToken = ref.watch(authProvider.select((s) => s.accessToken));
  
  String userId = "guest";
  if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
      userId = decodedToken['sub'] ?? "guest";
    } catch (e) {
      userId = "guest";
    }
  }

  // Création d'une nouvelle instance isolée pour cet utilisateur spécifique
  return ChatbotNotifier(ref.read(chatbotServiceProvider), ref, userId);
});
