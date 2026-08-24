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
Future<Map<String, dynamic>> checkAppUpdate({
  required int currentBuild,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'checkAppUpdate',
      'buildNumber': currentBuild.toString(),
    },
  );

  final response = await http.get(uri);

  print("APP UPDATE STATUS: ${response.statusCode}");
  print("APP UPDATE RESPONSE: ${response.body}");

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
Future<Map<String,dynamic>> addUser({
  required String adminUserId,
  required String userId,
  required String name,
  required String password,
  required String role,
  required String vendor,
  required String email,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
  "action": "addUser",
  "adminUserId": adminUserId,
  "userId": userId,
  "name": name,
  "password": password,
  "vendor": vendor,
  "role": role,
  "email": email,
}
  );
print(uri.toString());
 print("REQUEST URL:");
print(uri.toString());

final response = await http.get(uri);

print("STATUS CODE: ${response.statusCode}");
print("RESPONSE BODY: ${response.body}");


  print("ADD USER STATUS: ${response.statusCode}");
  print("ADD USER RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getVendorMaster({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getVendorMaster',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print("VENDOR MASTER STATUS: ${response.statusCode}");
  print("VENDOR MASTER RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> addVendor({
  required String userId,
  required String vendorCode,
  required String vendorName,
  required String vendor,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "addVendor",
      "userId": userId,
      "vendorCode": vendorCode,
      "vendorName": vendorName,
      "vendor": vendor,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      "Server error: ${response.statusCode}",
    );
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> updateUser({
  required String adminUserId,
  required String editUserId,
  required String password,
  required String vendor,
  required String role,
  required String active,
  required String email,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "updateUser",
      "userId": adminUserId,
      "editUserId": editUserId,
      "password": password,
      "vendor": vendor,
      "role": role,
      "active": active,
      "email": email,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception(
      "Server error ${response.statusCode}",
    );
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> changePassword({
  required String userId,
  required String currentPassword,
  required String newPassword,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "changePassword",
      "userId": userId,
      "currentPassword": currentPassword,
      "newPassword": newPassword,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception("Server Error");
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> registerDevice({
  required String userId,
  required String deviceId,
  required String deviceName,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "registerDevice",
      "userId": userId,
      "deviceId": deviceId,
      "deviceName": deviceName,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception("Server error ${response.statusCode}");
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> getPendingDevices({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "getPendingDevices",
      "userId": userId,
    },
  );

  final response = await http.get(uri);

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> approveDevice({
  required String adminUserId,
  required String editUserId,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "approveDevice",
      "userId": adminUserId,
      "editUserId": editUserId,
    },
  );

  final response = await http.get(uri);

  return jsonDecode(response.body);

}
Future<Map<String, dynamic>> rejectDevice({
  required String adminUserId,
  required String editUserId,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "rejectDevice",
      "userId": adminUserId,
      "editUserId": editUserId,
    },
  );

  final response = await http.get(uri);

  return jsonDecode(response.body);

}
Future<Map<String, dynamic>> resetPassword({
  required String adminUserId,
  required String editUserId,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "resetPassword",
      "userId": adminUserId,
      "editUserId": editUserId,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception("Server Error");
  }

  return jsonDecode(response.body);

}
Future<Map<String, dynamic>> getAuditLogs({
  required String userId,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "getAuditLogs",
      "userId": userId,
    },
  );

  final response = await http.get(uri);

  if (response.statusCode != 200) {
    throw Exception("Server Error");
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> requestPasswordReset({
  required String userId,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "requestPasswordReset",
      "userId": userId,
    },
  );

  final response = await http.get(uri);

  print(
    "PASSWORD RESET REQUEST STATUS: "
    "${response.statusCode}",
  );

  print(
    "PASSWORD RESET REQUEST RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Server error: ${response.statusCode}",
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getPasswordResetRequests({
  required String adminUserId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "getPasswordResetRequests",
      "userId": adminUserId,
    },
  );

  final response = await http.get(uri);

  print(
    "PASSWORD RESET REQUESTS STATUS: "
    "${response.statusCode}",
  );

  print(
    "PASSWORD RESET REQUESTS RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Server Error ${response.statusCode}",
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getOrderDocuments({
  required String userId,
  required String purchaseOrder,
  required String materialReq,
  required String workOrder,
}) async {

  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "getOrderDocuments",
      "userId": userId,
      "purchaseOrder": purchaseOrder,
      "materialReq": materialReq,
      "workOrder": workOrder,
    },
  );

  final response = await http.get(uri);

  print("DOCUMENT API : ${response.body}");

  if (response.statusCode != 200) {
    throw Exception("Server Error");
  }

  return jsonDecode(response.body);
}
Future<Map<String, dynamic>> createLoginSupportTicket({
  required String userId,
  required String vendor,
  required String category,
  required String description,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'createLoginSupportTicket',
      'userId': userId,
      'vendor': vendor,
      'category': category,
      'description': description,
    },
  );

  final response = await http.get(uri);

  print(
    "LOGIN SUPPORT STATUS: ${response.statusCode}",
  );

  print(
    "LOGIN SUPPORT RESPONSE: ${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getSupportTickets({
  required String userId,
}) async {
  final uri = Uri.parse(
    AppConstants.apiUrl,
  ).replace(
    queryParameters: {
      'action': 'getSupportTickets',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print(
    "SUPPORT TICKETS STATUS: "
    "${response.statusCode}",
  );

  print(
    "SUPPORT TICKETS RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> updateSupportTicketStatus({
  required String userId,
  required String ticketId,
  required String status,
}) async {
  final uri = Uri.parse(
    AppConstants.apiUrl,
  ).replace(
    queryParameters: {
      'action': 'updateSupportTicketStatus',
      'userId': userId,
      'ticketId': ticketId,
      'status': status,
    },
  );

  final response = await http.get(uri);

  print(
    "UPDATE SUPPORT STATUS: "
    "${response.statusCode}",
  );

  print(
    "UPDATE SUPPORT RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> updateUserSupportTicketStatus({
  required String userId,
  required String ticketId,
  required String status,
}) async {
  final uri = Uri.parse(
    AppConstants.apiUrl,
  ).replace(
    queryParameters: {
      'action': 'updateUserSupportTicketStatus',
      'userId': userId,
      'ticketId': ticketId,
      'status': status,
    },
  );

  final response = await http.get(uri);

  print(
    "USER SUPPORT STATUS: ${response.statusCode}",
  );

  print(
    "USER SUPPORT RESPONSE: ${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> getNotifications({
  required String userId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'getNotifications',
      'userId': userId,
    },
  );

  final response = await http.get(uri);

  print("NOTIFICATIONS STATUS: ${response.statusCode}");
  print("NOTIFICATIONS RESPONSE: ${response.body}");

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> markNotificationRead({
  required String userId,
  required String notificationId,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      'action': 'markNotificationRead',
      'userId': userId,
      'notificationId': notificationId,
    },
  );

  final response = await http.get(uri);

  print(
    "MARK NOTIFICATION STATUS: "
    "${response.statusCode}",
  );

  print(
    "MARK NOTIFICATION RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Server error: ${response.statusCode}',
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> createSupportTicket({
  required String userId,
  required String category,
  required String description,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "createSupportTicket",
      "userId": userId,
      "category": category,
      "description": description,
    },
  );

  final response = await http.get(uri);

  print(
    "CREATE SUPPORT TICKET STATUS: "
    "${response.statusCode}",
  );

  print(
    "CREATE SUPPORT TICKET RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Server Error ${response.statusCode}",
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
Future<Map<String, dynamic>> sendAdminNotification({
  required String adminUserId,
  required String title,
  required String message,
}) async {
  final uri = Uri.parse(AppConstants.apiUrl).replace(
    queryParameters: {
      "action": "sendAdminNotification",
      "userId": adminUserId,
      "title": title,
      "message": message,
    },
  );

  final response = await http.get(uri);

  print(
    "SEND ADMIN NOTIFICATION STATUS: "
    "${response.statusCode}",
  );

  print(
    "SEND ADMIN NOTIFICATION RESPONSE: "
    "${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Server Error ${response.statusCode}",
    );
  }

  return jsonDecode(response.body)
      as Map<String, dynamic>;
}
}