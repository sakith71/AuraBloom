import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/models/notification.dart';
import 'package:frontend/screens/community/post-detail-screen.dart';
import 'package:frontend/services/community-service.dart';
import 'package:frontend/services/notification-service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final CommunityService _communityService = CommunityService();
  List<UserNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _needsIndex = false;
  String? _indexUrl;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (kDebugMode) {
      print('Loading notifications...');
      print('Current user: ${_notificationService.currentUser?.uid}');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _needsIndex = false;
      _indexUrl = null;
    });

    try {
      // First try to get notifications
      final result = await _notificationService.getNotificationsWithIndexInfo();

      if (result['success'] == true) {
        // Success
        if (mounted) {
          setState(() {
            _notifications = result['notifications'];
            _isLoading = false;
          });
        }
      } else if (result['needsIndex'] == true) {
        // Index needed
        if (mounted) {
          setState(() {
            _isLoading = false;
            _needsIndex = true;
            _indexUrl = result['indexUrl'];
            _errorMessage = result['error'];
          });
        }
      } else {
        // Other error
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = result['error'];
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in _loadNotifications: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _copyIndexUrl() async {
    if (_indexUrl != null) {
      await Clipboard.setData(ClipboardData(text: _indexUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Index URL copied to clipboard')),
      );
    }
  }

  Future<void> _openIndexUrl() async {
    if (_indexUrl != null) {
      try {
        final uri = Uri.parse(_indexUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the URL')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _navigateToPost(UserNotification notification) async {
    try {
      // Mark notification as read
      await _notificationService.markAsRead(notification.id);

      // For non-community notifications, just show the content
      if (notification.type == NotificationType.healthTip ||
          notification.type == NotificationType.periodReminder ||
          notification.type == NotificationType.cycleUpdate ||
          notification.type == NotificationType.appUpdate) {
        if (notification.content != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notification.content!),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // For community notifications, navigate to the post
      if (notification.postId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post information not available')),
        );
        return;
      }

      // Get the post
      final post = await _communityService.getPost(notification.postId!);
      if (post == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post not found')));
        return;
      }

      // Navigate to the post
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error navigating to post: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Update the _getNotificationText method
  String _getNotificationText(UserNotification notification) {
    switch (notification.type) {
      case NotificationType.like:
        return '${notification.triggerUserName} liked your post';
      case NotificationType.comment:
        return '${notification.triggerUserName} commented on your post';
      case NotificationType.reply:
        return '${notification.triggerUserName} replied to your comment';
      case NotificationType.healthTip:
        return 'Health Tip';
      case NotificationType.periodReminder:
        return 'Period Reminder';
      case NotificationType.cycleUpdate:
        return 'Cycle Update';
      case NotificationType.appUpdate:
        return 'App Update';
    }
  }

  // Update the _getNotificationIcon method
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.reply:
        return Icons.reply;
      case NotificationType.healthTip:
        return Icons.health_and_safety;
      case NotificationType.periodReminder:
        return Icons.calendar_today;
      case NotificationType.cycleUpdate:
        return Icons.loop;
      case NotificationType.appUpdate:
        return Icons.system_update;
    }
  }

  // Update the _getNotificationColor method
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Colors.red;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.reply:
        return Colors.green;
      case NotificationType.healthTip:
        return Colors.teal;
      case NotificationType.periodReminder:
        return Colors.purple;
      case NotificationType.cycleUpdate:
        return Colors.amber;
      case NotificationType.appUpdate:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the global color instead of a local pink/purple color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 255, 115, 166),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Loading notifications...'),
                  ],
                ),
              )
              : _needsIndex
              ? _buildIndexNeededUI()
              : _errorMessage != null && !_needsIndex
              ? _buildErrorUI()
              : _notifications.isEmpty
              ? _buildEmptyUI()
              : _buildNotificationsList(),
    );
  }

  Widget _buildIndexNeededUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build_circle_outlined, size: 80, color: Colors.amber[400]),
          const SizedBox(height: 16),
          Text(
            'First-time setup needed',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'The notification system needs to be set up. This is a one-time process that requires creating an index in Firebase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'To create the index:',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. Click the "Open Firebase Console" button below',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  '2. Click "Create Index" on the page that opens',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  '3. Wait for the index to be created (may take a few minutes)',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  '4. Come back here and click "Try Again"',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _openIndexUrl,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Firebase Console'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _copyIndexUrl,
                icon: const Icon(Icons.copy),
                tooltip: 'Copy URL to clipboard',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 115, 166),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 70, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading notifications',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 115, 166),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'When someone likes or comments on your posts, you\'ll see notifications here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color:
              notification.isRead
                  ? Colors.white
                  : Colors.white.withOpacity(0.9),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationColor(
                notification.type,
              ).withOpacity(0.2),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
              ),
            ),
            title: Text(
              _getNotificationText(notification),
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle:
                notification.content != null
                    ? Text(
                      notification.content!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    )
                    : Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
            trailing: Text(
              _formatDate(notification.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            onTap: () => _navigateToPost(notification),
          ),
        );
      },
    );
  }
}
