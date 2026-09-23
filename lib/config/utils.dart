import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/no_connection_page.dart';
import 'package:nss_new/common_pages/splash_screen.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/authentication/token_expired_screen.dart';
import 'package:nss_new/config/urls.dart';

import 'dart:convert';

bool checkValidations(String responseBody, {int? statusCode}) {
  if (responseBody.isEmpty) return true;

  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail']?.toString() ?? '';
      final message = decoded['message']?.toString() ?? '';

      // Only genuinely invalid / expired tokens should trigger session expired
      if (statusCode == 401 ||
          (statusCode == 403 &&
              (detail == 'Invalid token' ||
                  detail.toLowerCase().contains('token expired') ||
                  message == 'Invalid token.'))) {
        if (LocalStorage.isLoggedIn) {
          Get.offAll(() => const TokenExpiredScreen());
        }
        return false;
      }

      if (detail.contains('updation required') ||
          message.contains('updation required') ||
          message.contains('Unsupported OS or app version.')) {
        Get.offAll(() => const AppUpdateScreen(status: false));
        return false;
      }
    }
  } catch (_) {
    // Non-JSON response (e.g. HTML 502/503) should not trigger logout
  }

  return true;
}

Future<void> checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    Get.to(() => const NoInternetScreen());
  }
}

Future<Map<String, String>> getHeader() async {
  String token =
      LocalStorage().currentToken ?? await LocalStorage().readToken() ?? '';
  if (token.isNotEmpty &&
      !token.startsWith('Bearer ') &&
      !token.startsWith('JWT ')) {
    token = 'Bearer $token';
  }
  // Backend strictly expects 'ios' or 'android'. Use 'ios' on iOS, 'android' everywhere else.
  final os = Platform.isIOS ? 'ios' : 'android';
  final headers = <String, String>{
    "Content-Type": "application/json",
    "OS": os,
    "App-Version": Details.appVersion,
  };
  if (token.isNotEmpty) {
    headers["Authorization"] = token;
  }
  return headers;
}

String formatKey(String key) {
  String formattedKey = key.replaceAllMapped(
    RegExp(r'(?<!^)([A-Z])'),
    (Match match) => ' ${match.group(0)}',
  );
  formattedKey = formattedKey.replaceFirst(
    formattedKey[0],
    formattedKey[0].toUpperCase(),
  );
  //formattedKey = formattedKey.replaceAll("from", "replace");
  return formattedKey;
}
