// api_server.dart
import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3000);
  print('🚀 Server Mock SUPER LENGKAP berjalan di http://localhost:3000');
  print('Siap melayani semua request termasuk API tambahan!\n');

  await for (HttpRequest request in server) {
    final path = request.uri.path;
    final method = request.method;
    request.response.headers.contentType = ContentType.json;

    print('👉 Request Masuk: $method $path');

    // 1. REGISTER (POST)
    if (path == '/api/v1/auth/register' && method == 'POST') {
      request.response
        ..statusCode = HttpStatus.created
        ..write(jsonEncode({
          "status": "success",
          "message": "Pendaftaran akun berhasil",
          "data": {"id": "USR-001", "name": "Ahmad Dani", "role": "User"}
        }));
    }
    // 2. LOGIN (POST)
    else if (path == '/api/v1/auth/login' && method == 'POST') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({
          "status": "success",
          "message": "Log masuk berhasil",
          "data": {
            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummyToken123...",
            "user": {"id": "USR-001", "name": "Pengguna Demo", "role": "User"}
          }
        }));
    }
    // 3. GET ALL TICKETS (GET)
    else if (path == '/api/v1/tickets' && method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({
          "status": "success",
          "data": [
            {
              "id": "1",
              "title": "Laptop Mati Total",
              "description": "Laptop saya tiba-tiba mati saat sedang dipakai.",
              "status": "Open",
              "date": "12 Apr 2026"
            }
          ]
        }));
    }
    // 4. [TAMBAHAN] GET TICKET DETAIL (GET)
    else if (path == '/api/v1/tickets/1' && method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({
          "status": "success",
          "data": {
            "id": "1",
            "title": "Laptop Mati Total",
            "description": "Laptop saya tiba-tiba mati saat sedang dipakai dan tidak bisa dicharge.",
            "status": "Open",
            "date": "12 Apr 2026",
            "created_by": "Ahmad Dani",
            "category": "Hardware"
          }
        }));
    }
    // 5. CREATE TICKET (POST)
    else if (path == '/api/v1/tickets' && method == 'POST') {
      request.response
        ..statusCode = HttpStatus.created
        ..write(jsonEncode({
          "status": "success",
          "message": "Tiket baru berhasil dibuat",
          "data": {"id": "1", "title": "Printer Error", "status": "Open"}
        }));
    }
    // 6. UPDATE STATUS (PUT)
    else if (path == '/api/v1/tickets/1/status' && method == 'PUT') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({
          "status": "success",
          "message": "Status tiket berhasil diperbarui",
          "data": {"id": "1", "status": "In Progress"}
        }));
    }
    // 7. [TAMBAHAN] GET DASHBOARD STATS (GET)
    else if (path == '/api/v1/dashboard/stats' && method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write(jsonEncode({
          "status": "success",
          "data": {
            "total_tickets": 15,
            "open_tickets": 5,
            "in_progress_tickets": 7,
            "resolved_tickets": 3
          }
        }));
    }
    // Jika tidak ditemukan
    else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write(jsonEncode({"status": "error", "message": "Endpoint tidak ditemukan"}));
    }

    await request.response.close();
  }
}