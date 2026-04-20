# Notification System Documentation

## Overview
The PowerGym mobile app has a complete notification system that:
- ✅ Loads old notifications from database on startup
- ✅ Receives new notifications via WebSocket in real-time
- ✅ Displays new notifications at the top of the list
- ✅ Shows snackbar when new notification arrives
- ✅ All text in English

## Architecture

### Backend (Java Spring Boot)

#### 1. Entity: `GymNotification`
```java
- id: Long
- user: User
- title: String
- content: String
- type: String (SERVICE_REGISTERED, BOOKING_CONFIRMED, etc.)
- relatedId: Long
- actorName: String
- isRead: Boolean
- createdAt: LocalDateTime
```

#### 2. REST API Endpoints
- `GET /api/gym-notifications` - Get all notifications for current user
- `GET /api/gym-notifications/unread-count` - Get unread count
- `PUT /api/gym-notifications/{id}/read` - Mark as read
- `PUT /api/gym-notifications/read-all` - Mark all as read
- `DELETE /api/gym-notifications/{id}` - Delete notification

#### 3. WebSocket Topic
- `/topic/user/{userId}/notifications` - Real-time notifications

#### 4. Notification Types
- `SERVICE_REGISTERED` - When user registers for a service
- `BOOKING_CONFIRMED` - When trainer confirms a booking
- `BOOKING_REJECTED` - When trainer rejects a booking
- `BOOKING_CANCELLED` - When booking is cancelled
- `MEMBERSHIP_ACTIVATED` - When membership is activated
- `MEMBERSHIP_EXPIRING` - When membership is about to expire
- `MEMBERSHIP_EXPIRED` - When membership expires
- `PAYMENT_SUCCESS` - When payment is successful
- `TRAINER_ASSIGNED` - When trainer is assigned

### Mobile App (Flutter)

#### 1. Models
**`AppNotification`** (`notification_model.dart`)
```dart
- id: int
- title: String
- message: String
- type: String
- isRead: bool
- createdAt: String
- relatedId: int?
- actorName: String?
- actorAvatar: String?
```

#### 2. Services

**`NotificationsService`** (`notifications_service.dart`)
- REST API calls to backend
- `getNotifications()` - Load all notifications
- `getUnreadCount()` - Get unread count
- `markAsRead(id)` - Mark single notification as read
- `markAllAsRead()` - Mark all as read
- `deleteNotification(id)` - Delete notification

**`UserWebSocketService`** (`user_websocket_service.dart`)
- WebSocket connection using STOMP protocol
- Subscribes to `/topic/user/{userId}/notifications`
- Callbacks: `onNotification`, `onConnected`, `onDisconnected`

#### 3. UI Screen

**`NotificationsTab`** (`notifications_tab.dart`)

**Features:**
- Load old notifications from database on init
- Connect to WebSocket for real-time updates
- Display notifications in list (newest first)
- Show unread count badge
- Mark as read on tap
- Swipe to delete
- Show snackbar for new notifications
- WebSocket connection status indicator (green dot)

**UI Components:**
- Gradient header with title and actions
- Unread count badge
- WebSocket status indicator
- Notification cards with:
  - Type-specific icon and colors
  - Title and message
  - Timestamp (relative: "2m ago", "3h ago", etc.)
  - Unread indicator (blue dot)
- Empty state
- Error state with retry button

## Flow Diagram

### 1. Initial Load (Old Notifications)
```
App Start
  ↓
NotificationsTab.initState()
  ↓
_load() → NotificationsService.getNotifications()
  ↓
GET /api/gym-notifications
  ↓
Backend returns List<GymNotification> from database
  ↓
Display in UI (sorted by createdAt DESC)
```

### 2. Real-time Updates (New Notifications)
```
User Action (e.g., Trainer confirms booking)
  ↓
Backend: TrainerBookingService.confirmBooking()
  ↓
GymNotificationService.notifyBookingConfirmed()
  ↓
1. Save to database
2. Push via WebSocket to /topic/user/{userId}/notifications
  ↓
Mobile: UserWebSocketService receives message
  ↓
onNotification callback
  ↓
1. Add to top of list: [newNotif, ...oldNotifs]
2. Show snackbar
  ↓
UI updates automatically
```

## Usage Example

### Backend - Sending Notification
```java
@Service
public class SomeService {
    @Autowired
    private GymNotificationService gymNotificationService;
    
    public void someAction(User user) {
        // Your business logic...
        
        // Send notification
        gymNotificationService.notifyServiceRegistered(registration);
    }
}
```

### Mobile - Receiving Notification
The notification system is already integrated in `NotificationsTab`. No additional code needed!

## Testing

### 1. Test Old Notifications
1. Create some notifications in database
2. Open app and go to Notifications tab
3. Should see all notifications loaded from database

### 2. Test Real-time Notifications
1. Open app and go to Notifications tab
2. Check green dot (WebSocket connected)
3. Trigger an action (e.g., register for service, confirm booking)
4. Should see:
   - New notification appears at top of list
   - Snackbar shows notification
   - Unread count increases

### 3. Test Mark as Read
1. Tap on unread notification (has blue dot)
2. Blue dot should disappear
3. Unread count should decrease

### 4. Test Delete
1. Swipe notification left
2. Red delete background appears
3. Notification is removed from list

## Configuration

### Backend WebSocket Config
- Endpoint: `/ws`
- STOMP over SockJS
- Authentication: JWT token in headers

### Mobile WebSocket Config
- URL: `http://10.0.2.2:8080/ws` (Android emulator)
- URL: `http://localhost:8080/ws` (Web)
- Reconnect delay: 5 seconds
- Connection timeout: 10 seconds

## Troubleshooting

### Notifications not loading
- Check backend is running
- Check JWT token is valid
- Check API endpoint `/api/gym-notifications` returns data

### WebSocket not connecting
- Check backend WebSocket config
- Check JWT token in headers
- Check network connectivity
- Look for green dot in UI (should be visible when connected)

### New notifications not appearing
- Check WebSocket is connected (green dot)
- Check backend is calling `gymNotificationService.notify*()` methods
- Check WebSocket topic: `/topic/user/{userId}/notifications`
- Check browser/app console for WebSocket messages

## Future Enhancements
- [ ] Push notifications (FCM)
- [ ] Notification preferences/settings
- [ ] Group notifications by date
- [ ] Notification actions (e.g., "View booking", "Reply")
- [ ] Rich notifications with images
- [ ] Sound/vibration for new notifications
