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
}
