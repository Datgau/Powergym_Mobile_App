import '../models/membership_package.dart';
import '../config/constants.dart';
import 'api_client.dart';

class PackagesService {
  final ApiClient _apiClient = ApiClient();

  // 1. Lấy danh sách các gói tập đang hoạt động (Hiển thị cho User mua)
  Future<List<MembershipPackage>> getAvailablePackages() async {
    try {
      // Gọi API sử dụng endpoint '/membership-packages/active' từ AppConstants
      final response = await _apiClient.get(AppConstants.membershipPackagesEndpoint);

      // Spring Boot Backend trả về class ApiResponse chứa trường 'data'
      final List<dynamic> dataList = response.data['data'] ?? [];

      // Chuyển đổi JSON list sang List<MembershipPackage>
      return dataList.map((json) => MembershipPackage.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách gói tập: $e');
    }
  }

  // 2. Lấy danh sách các gói tập mà User đang sở hữu (Đã mua)
  Future<List<Map<String, dynamic>>> getUserPackages(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/packages');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw Exception('Error fetching user packages: $e');
    }
  }

  // 3. Mua gói tập
  Future<Map<String, dynamic>> purchasePackage({
    required String userId,
    required String packageId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        '/packages/purchase',
        data: {
          'userId': userId,
          'packageId': packageId,
          'paymentMethod': paymentMethod,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error purchasing package: $e');
    }
  }

  // 4. Lịch sử mua gói
  Future<List<Map<String, dynamic>>> getPackageHistory(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/packages/history');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw Exception('Error fetching package history: $e');
    }
  }

  // 5. Gia hạn gói
  Future<Map<String, dynamic>> renewPackage({
    required String userId,
    required String packageId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/packages/renew',
        data: {
          'userId': userId,
          'packageId': packageId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error renewing package: $e');
    }
  }
}