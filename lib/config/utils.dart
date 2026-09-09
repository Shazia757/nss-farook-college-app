import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/no_connection_page.dart';
import 'package:nss_new/common_pages/splash_screen.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/authentication/token_expired_screen.dart';
import 'package:nss_new/config/urls.dart';

bool checkValidations(String response) {
  if (response.contains('Invalid token')) {
    Get.offAll(() => TokenExpiredScreen());
    return false;
  } else if (response.contains('updation required') ||
      response.contains('Unsupported OS or app version.')) {
    Get.offAll(() => AppUpdateScreen(status: false));

    return false;
  }
  return true;
}

checkConnectivity() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    Get.to(() => NoInternetScreen());
  }
}

Future<Map<String, String>> getHeader() async {
  String token = await LocalStorage().readToken() ?? '';
  if (token.isNotEmpty && !token.startsWith('Bearer ') && !token.startsWith('JWT ')) {
    token = 'Bearer $token';
  }
  return {
    "Content-Type": "application/json",
    "OS": Platform.operatingSystem,
    "App-Version": Details.appVersion,
    "Authorization": token,
  };
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
