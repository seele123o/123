// services/http_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/domain_service.dart';
import 'package:http/http.dart' as http;
import 'package:hiddify/features/panel/xboard/services/http_service/exceptions.dart'; // 新增

class HttpService {
  static String baseUrl = 'https://byegirls.com';

  // 重构初始化方法以包含更好的错误处理
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('正在初始化 HTTP 服务...');
      }

      baseUrl = await DomainService.fetchValidDomain();

      // 验证域名连接是否可用
      final testUrl = Uri.parse('$baseUrl/ping');
      final response = await http.get(testUrl).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ConnectionException(
          '服务器响应异常: ${response.statusCode}',
          response.body,
        );
      }

      if (kDebugMode) {
        print('HTTP 服务初始化成功: $baseUrl');
      }
    } on http.ClientException catch (e) {
      throw ConnectionException('网络连接失败', e);
    } on TimeoutException catch (e) {
      throw ConnectionException('连接超时', e);
    } catch (e) {
      if (kDebugMode) {
        print('HTTP 服务初始化失败: $e');
      }
      throw ConnectionException('无法连接到服务器', e);
    }
  }

  // 优化 GET 请求方法，添加更好的错误处理
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    if (baseUrl.isEmpty) {
      throw ConnectionException('HTTP 服务尚未初始化');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    try {
      if (kDebugMode) {
        print('发送 GET 请求到: $url');
      }

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print("GET 响应: ${response.statusCode} - ${response.body}");
      }

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('认证失败');
      } else if (response.statusCode >= 500) {
        throw ServerException('服务器错误: ${response.statusCode}');
      } else {
        throw RequestException(
          "请求失败: ${response.statusCode}",
          response.body,
        );
      }
    } on TimeoutException catch (e) {
      throw ConnectionException('请求超时', e);
    } on http.ClientException catch (e) {
      throw ConnectionException('网络请求失败', e);
    } catch (e) {
      rethrow;
    }
  }

  // 优化 POST 请求方法，添加更好的错误处理
  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    if (baseUrl.isEmpty) {
      throw ConnectionException('HTTP 服务尚未初始化');
    }

    final url = Uri.parse('$baseUrl$endpoint');

    try {
      if (kDebugMode) {
        print('发送 POST 请求到: $url');
        print('请求体: $body');
      }

      final response = await http
          .post(
            url,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print("POST 响应: ${response.statusCode} - ${response.body}");
      }

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('认证失败');
      } else if (response.statusCode >= 500) {
        throw ServerException('服务器错误: ${response.statusCode}');
      } else {
        throw RequestException(
          "请求失败: ${response.statusCode}",
          response.body,
        );
      }
    } on TimeoutException catch (e) {
      throw ConnectionException('请求超时', e);
    } on http.ClientException catch (e) {
      throw ConnectionException('网络请求失败', e);
    } catch (e) {
      rethrow;
    }
  }
}
