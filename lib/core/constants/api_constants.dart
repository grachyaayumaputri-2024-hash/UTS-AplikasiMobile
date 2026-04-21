// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Endpoint spesifik sesuai functional requirement
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String tickets = '$baseUrl/tickets';
}