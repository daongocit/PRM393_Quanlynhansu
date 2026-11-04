import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/task_provider.dart';

class TaskCommentsScreen extends StatefulWidget {
  final TaskItem task;

  const TaskCommentsScreen({super.key, required this.task});

  @override
  State<TaskCommentsScreen> createState() => _TaskCommentsScreenState();
}

class _TaskCommentsScreenState extends State<TaskCommentsScreen> {
  final _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<TaskProvider>(context, listen: false)
            .loadComments(widget.task.id!);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final comments = taskProv.getComments(widget.task.id ?? 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Thảo Luận Nhiệm Vụ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner thông báo phòng ban (Business Rule đề bài)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.06),
            child: const Row(
              children: [
                Icon(Icons.lock_open_rounded, size: 14, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Không gian thảo luận nội bộ: Chỉ nhân sự cùng phòng IT có thể xem và trao đổi.',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Comments List
          Expanded(
            child: comments.isEmpty
                ? const Center(
                    child: Text(
                      'Chưa có trao đổi nào. Hãy để lại bình luận đầu tiên!',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final isMe = c.userId == user?.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: c.userAvatar != null
                                    ? NetworkImage(c.userAvatar!)
                                    : null,
                                child: c.userAvatar == null
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMe ? 'Bạn' : (c.userName ?? 'Đồng nghiệp'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isMe
                                          ? null
                                          : Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Text(
                                      c.content,
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.createdAt,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl)
                                    : null,
                                child: user?.avatarUrl == null
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung trao đổi hoặc ý kiến...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    onPressed: _isSending
                        ? null
                        : () async {
                            final text = _commentController.text.trim();
                            if (text.isEmpty || user == null || widget.task.id == null) return;

                            setState(() => _isSending = true);
                            await taskProv.addComment(
                              taskId: widget.task.id!,
                              userId: user.id,
                              content: text,
                            );
                            _commentController.clear();
                            setState(() => _isSending = false);
                            _scrollToBottom();
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
