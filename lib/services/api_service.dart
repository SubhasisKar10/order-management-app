import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) async {
    final uri = Uri.parse(AppConstants.apiUrl).replace(
      queryParameters: {
        'action': 'login',
        'userId': userId,
        'password': password,
      },
    );

    final response = await http.get(uri);

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
Future<Map<String, dynamic>> getOrders({
  required String userId,
  required String orderType,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getOrders',
      'userId': userId,
      'orderType': orderType,
    },
  );

  final response = await http.get(uri);

  print("ORDERS STATUS: ${response.statusCode}");
  print("ORDERS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getDocuments({
  required String userId,
  required String purchaseOrder,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getDocuments',
      'userId': userId,
      'purchaseOrder': purchaseOrder,
    },
  );

  final response = await http.get(uri);

  print("DOCUMENTS STATUS: ${response.statusCode}");
  print("DOCUMENTS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getUsers({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getUsers',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print("USERS STATUS: ${response.statusCode}");
  print("USERS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getVendors({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getVendors',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print("VENDORS STATUS: ${response.statusCode}");
  print("VENDORS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getAllDocuments({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getAllDocuments',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print("ALL DOCUMENTS STATUS: ${response.statusCode}");
  print("ALL DOCUMENTS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
}