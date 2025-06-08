import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_application_1/models/dealer.dart';
import '../models/car.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dealer_location.dart';

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
        final List dealersJson = response.data;
        return dealersJson
            .where((json) => json['role'] == 'dealer')
            .map((json) => Dealer.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load dealers');
      }
    } catch (e) {
      print('Error fetching dealers: $e');
      throw Exception('Failed to load dealers');
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
        final token = response.data['access_token'];

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

  // Add a new vehicle
  static Future<Map<String, dynamic>> addVehicle({
    required String make,
    required String model,
    required int year,
    required double price,
    required String fuel,
    required String description,
    required File imageFile,
    required String token,
  }) async {
    try {
      final formData = FormData.fromMap({
        'make': make,
        'model': model,
        'year': year.toString(),
        'price': price.toString(),
        'fuel': fuel,
        'description': description,
        'images': await MultipartFile.fromFile(
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        '/vehicles',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Vehicle added successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to add vehicle',
        };
      }
    } on DioException catch (e) {
      print('Error adding vehicle: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error occurred',
      };
    }
  }

  // Fetch dealer locations
  static Future<List<DealerLocation>> fetchDealerLocations() async {
    try {
      final response = await _dio.get('/dealers/map');

      if (response.statusCode == 200) {
        // Check if response.data is Map or List
        if (response.data is Map) {
          // If it's a Map, check if it has a data field containing the list
          final List<dynamic> locationsJson = response.data['dealers'] ?? [];
          return locationsJson
              .map((json) =>
                  DealerLocation.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (response.data is List) {
          // If it's already a List, use it directly
          final List<dynamic> locationsJson = response.data;
          return locationsJson
              .map((json) =>
                  DealerLocation.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        print('Unexpected response format: ${response.data}');
        return [];
      } else {
        print('Error response: ${response.statusCode} - ${response.data}');
        return [];
      }
    } catch (e) {
      print('Error fetching dealer locations: $e');
      return [];
    }
  }
}
