import 'package:dio/dio.dart';
import 'package:flutter_application_1/models/dealer.dart';
import '../models/car.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      print('Attempting login for email: $email');
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response
            .data['access_token']; // Changed from 'token' to 'access_token'

        if (userData != null && token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(userData));
          await prefs.setString('token', token);

          // Set the authorization header for future requests
          _dio.options.headers['Authorization'] = 'Bearer $token';

          print('Login successful. Token stored.');
          return {
            'success': true,
            'data': response.data,
            'message': 'Login successful',
          };
        } else {
          print('Login failed: Missing user data or token in response');
          return {
            'success': false,
            'message': 'Invalid server response',
          };
        }
      } else {
        print('Login failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      print('Dio Error during login: ${e.message}');
      print('Error type: ${e.type}');
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
      }
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    } catch (e) {
      print('Unexpected error during login: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
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
        'phone': phone,
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
