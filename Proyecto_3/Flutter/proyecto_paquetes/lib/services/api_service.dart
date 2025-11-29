import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // IMPORTANTE → en Chrome usa 127.0.0.1, no localhost
  static const String BASE_URL = "http://127.0.0.1:8000";

  // =====================================================
  // LOGIN → AHORA SÍ EN JSON (FORMATO QUE FASTAPI ESPERA)
  // =====================================================
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final uri = Uri.parse("$BASE_URL/login/");

    final resp = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception("Login failed: ${resp.body}");
    }
  }

  // =====================================================
  // OBTENER PAQUETES
  // =====================================================
  static Future<List<dynamic>> fetchPackages(int userId) async {
    final uri = Uri.parse("$BASE_URL/packages/$userId");
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error fetching packages: ${resp.body}');
    }
  }

  // =====================================================
  // ENTREGAR PAQUETE (multipart)
  // =====================================================
  static Future<Map<String, dynamic>> deliverPackage({
    required int packageId,
    required int userId,
    required double latitude,
    required double longitude,
    String? filename,
    Uint8List? photoBytes,
    File? photoFile,
  }) async {
    final uri = Uri.parse("$BASE_URL/deliver/");
    final request = http.MultipartRequest('POST', uri);

    request.fields['package_id'] = packageId.toString();
    request.fields['user_id'] = userId.toString();
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    // ---------------- WEB ----------------
    if (kIsWeb) {
      if (photoBytes == null || filename == null) {
        throw Exception('En web se requieren photoBytes y filename');
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // ---------------- MOBILE / WINDOWS ----------------
    else {
      if (photoFile == null) {
        throw Exception('En mobile/desktop se requiere photoFile');
      }

      final fileStream = http.ByteStream(photoFile.openRead());
      final length = await photoFile.length();

      final multipartFile = http.MultipartFile(
        'photo',
        fileStream,
        length,
        filename: path.basename(photoFile.path),
      );

      request.files.add(multipartFile);
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Deliver failed: ${resp.statusCode} ${resp.body}');
    }
  }
}
