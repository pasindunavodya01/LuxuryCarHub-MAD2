import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/dealer.dart';
import '../models/car.dart';

class ApiService {
  static const String baseUrl =
      'https://skyblue-goshawk-195189.hostingersite.com/api';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    validateStatus: (status) => status! < 500,
  ));

  // Fetch all vehicles
  static Future<List<Car>> fetchVehicles() async {
    try {
      final response = await _dio.get('/vehicles');

      if (response.statusCode == 200) {
        final List jsonList = response.data;
        return jsonList.map((json) => Car.fromJson(json)).toList();
      } else {
        print('API Error - Status Code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Error type: ${e.type}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Fetch all dealers
  static Future<List<Dealer>> fetchDealers() async {
    try {
      final response = await _dio.get('/dealers');

      if (response.statusCode == 200) {
        final List jsonList = response.data;
        return jsonList.map((json) => Dealer.fromJson(json)).toList();
      } else {
        print('API Error - Status Code: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to load dealers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.message}');
      print('Error type: ${e.type}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Success - return the data (e.g., token and user info)
        return {'success': true, 'data': response.data};
      } else {
        // Login failed, return message from API or generic
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed'
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? e.message
      };
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phone,
    String role,
  ) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone_number': phone,
        'role': role,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
        };
      }
    } on DioException catch (e) {
      print('Registration Error: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registration failed',
      };
    }
  }
}
