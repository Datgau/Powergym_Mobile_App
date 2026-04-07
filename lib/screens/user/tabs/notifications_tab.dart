import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/gradient_container.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientContainer(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Thông báo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '3 thông báo mới',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Notifications List
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Today Section
                _buildSectionHeader('Hôm nay', 3),
                const SizedBox(height: 16),
                const NotificationCard(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppTheme.success,
                  iconBgColor: Color(0xFFE8F5E9),
                  title: 'Booking đã được xác nhận',
                  message: 'PT. Nguyễn Văn B đã xác nhận lịch tập của bạn vào 15/04/2026 lúc 09:00',
                  time: '10 phút trước',
                  isRead: false,
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppTheme.primaryBlue,
                  iconBgColor: Color(0xFFE3F2FD),
                  title: 'Nhắc nhở lịch tập',
                  message: 'Bạn có lịch tập với PT. Trần Thị C vào ngày mai lúc 14:00',
                  time: '2 giờ trước',
                  isRead: false,
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Color(0xFFFF6B35),
                  iconBgColor: Color(0xFFFFE8E0),
                  title: 'Streak 7 ngày! 🔥',
                  message: 'Tuyệt vời! Bạn đã duy trì tập luyện liên tục 7 ngày. Tiếp tục phát huy nhé!',
                  time: '5 giờ trước',
                  isRead: false,
                ),
                
                const SizedBox(height: 32),
                
                // Yesterday Section
                _buildSectionHeader('Hôm qua', 0),
                const SizedBox(height: 16),
                const NotificationCard(
                  icon: Icons.payment_rounded,
                  iconColor: AppTheme.success,
                  iconBgColor: Color(0xFFE8F5E9),
                  title: 'Thanh toán thành công',
                  message: 'Bạn đã thanh toán thành công gói tập Premium 3 tháng',
                  time: '1 ngày trước',
                  isRead: true,
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  icon: Icons.star_rounded,
                  iconColor: AppTheme.warning,
                  iconBgColor: Color(0xFFFFF8E1),
                  title: 'Đánh giá buổi tập',
                  message: 'Hãy đánh giá buổi tập với PT. Nguyễn Văn B để giúp chúng tôi cải thiện dịch vụ',
                  time: '1 ngày trước',
                  isRead: true,
                ),
                const SizedBox(height: 12),
                const NotificationCard(
                  icon: Icons.cancel_rounded,
                  iconColor: AppTheme.error,
                  iconBgColor: Color(0xFFFFEBEE),
                  title: 'Booking bị hủy',
                  message: 'PT. Lê Văn D đã hủy lịch tập vào 12/04/2026 do lý do cá nhân',
                  time: '2 ngày trước',
                  isRead: true,
                ),
                
                const SizedBox(height: 32),
                
                // Empty state or load more
                Center(
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tải thêm thông báo'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, int unreadCount) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (unreadCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  
  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : AppTheme.primaryBlue.withOpacity(0.15),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isRead 
                ? Colors.black.withOpacity(0.03)
                : AppTheme.primaryBlue.withOpacity(0.08),
            blurRadius: isRead ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container with gradient background
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
