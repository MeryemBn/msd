import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../providers/chatbot_provider.dart';

class ChatbotSheet extends ConsumerStatefulWidget {
  const ChatbotSheet({super.key});

  @override
  ConsumerState<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends ConsumerState<ChatbotSheet> {
  final TextEditingController _controller = TextEditingController();
  ScrollController? _activeScrollController;

  void _scrollToBottom() {
    final controller = _activeScrollController;
    if (controller == null || !controller.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    
    ref.listen(chatbotProvider, (previous, next) {
      final messagesChanged = next.messages.length > (previous?.messages.length ?? 0);
      final sessionSwitched = next.currentSessionId != previous?.currentSessionId;
      final historyClosed = (previous?.showingHistory ?? false) && !next.showingHistory;

      if (messagesChanged || sessionSwitched || historyClosed) {
        _scrollToBottom();
      }
    });

    final chatState = ref.watch(chatbotProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        _activeScrollController = scrollController;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildDragHandle(isDark),
              _buildHeader(context, ref, chatState, l10n),
              Expanded(
                child: chatState.showingHistory
                    ? _buildHistoryList(ref, chatState, isDark, l10n, locale)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) => _MessageBubble(message: chatState.messages[index]),
                      ),
              ),
              if (!chatState.showingHistory) ...[
                if (chatState.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                _buildInput(isDark, l10n),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40, height: 4,
        decoration: BoxDecoration(
          color: isDark ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ChatbotState state, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(chatbotProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          if (state.showingHistory)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => notifier.toggleHistory(),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: AppTheme.primary, size: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.showingHistory ? l10n.chatbotHistory : l10n.chatbotTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          if (!state.showingHistory) ...[
            IconButton(
              tooltip: l10n.chatbotHistory,
              icon: const Icon(Icons.forum_outlined, size: 22),
              onPressed: () => notifier.toggleHistory(),
            ),
            IconButton(
              tooltip: l10n.chatbotNewChat,
              icon: const Icon(Icons.add_comment_rounded, size: 22),
              onPressed: () => notifier.newChat(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(WidgetRef ref, ChatbotState state, bool isDark, AppLocalizations l10n, String locale) {
    final notifier = ref.read(chatbotProvider.notifier);

    if (state.history.isEmpty) {
      return Center(child: Text(l10n.chatbotNoHistory));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final session = state.history[index];
        final isSelected = session.id == state.currentSessionId;
        final timeStr = DateFormat.MMMd(locale).add_Hm().format(session.updatedAt);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : (isDark ? AppTheme.fieldBgDark : Colors.grey.shade50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
              onPressed: () => notifier.deleteSession(session.id),
            ),
            onTap: () => notifier.loadSession(session),
          ),
        );
      },
    );
  }

  Widget _buildInput(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: l10n.chatbotHint,
                filled: true,
                fillColor: isDark ? AppTheme.fieldBgDark : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (val) => _send(val),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primary,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _send(_controller.text),
            ),
          ),
        ],
      ),
    );
  }

  void _send(String val) {
    if (val.trim().isNotEmpty) {
      ref.read(chatbotProvider.notifier).sendMessage(val.trim());
      _controller.clear();
      _scrollToBottom();
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final timeStr = DateFormat.Hm(locale).format(message.timestamp);

    return Align(
      alignment: message.isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isUser) _buildCopyButton(context, l10n),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppTheme.primary : (isDark ? AppTheme.fieldBgDark : Colors.grey.shade100),
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: const Radius.circular(20),
                      topEnd: const Radius.circular(20),
                      bottomStart: Radius.circular(message.isUser ? 20 : 0),
                      bottomEnd: Radius.circular(message.isUser ? 0 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 10,
                          color: message.isUser ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!message.isUser) _buildCopyButton(context, l10n),
            ],
          ),
          if (!message.isUser && message.route != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TextButton.icon(
                onPressed: () {
                  final route = message.route!;
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push(route);
                },
                icon: const Icon(Icons.explore_outlined, size: 16),
                label: Text(l10n.chatbotConsult, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, AppLocalizations l10n) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.copy_all_rounded, size: 18, color: Colors.grey),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: message.text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chatbotCopied), duration: const Duration(seconds: 1)),
        );
      },
    );
  }
}
