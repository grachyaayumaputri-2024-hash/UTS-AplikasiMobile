import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException({this.statusCode, required this.message});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  // Ganti dengan IP komputer kamu jika jalankan di HP fisik
  // Contoh: 'http://192.168.1.5:8000/api'
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const int timeoutSeconds = 30;

  String? _token;

  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;
  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers {
    final h = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
  }

  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final message = body['message'] ?? 'Terjadi kesalahan pada server';
    throw ApiException(statusCode: response.statusCode, message: message);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await http.get(_buildUri(path, queryParams), headers: _headers)
          .timeout(const Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    } on HttpException {
      throw ApiException(message: 'Gagal terhubung ke server');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(_buildUri(path), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(_buildUri(path), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.patch(_buildUri(path), headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(_buildUri(path), headers: _headers)
          .timeout(const Duration(seconds: timeoutSeconds));
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    }
  }

  Future<dynamic> uploadFile(String path, {required File file, required String fieldName, Map<String, String>? fields}) async {
    try {
      final request = http.MultipartRequest('POST', _buildUri(path));
      if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      if (fields != null) request.fields.addAll(fields);
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'Tidak ada koneksi internet');
    }
  }

  void restoreToken(String token) => _token = token;
}