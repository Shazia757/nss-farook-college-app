import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/view/authentication/login_screen.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/view/home_screen.dart';

class AccountController extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldpasswordController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  RxBool isObscure = true.obs;
  RxBool isOldPassObscure = true.obs;
  RxBool isNewPassObscure = true.obs;
  RxBool isConfirmPassObscure = true.obs;
  RxString reason = 'No longer needed'.obs;

  final api = Api();

  var isLoading = false.obs;
  var isChangePassLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  onInit() {
    if (kDebugMode) {
      userNameController.text = '2781';
      passwordController.text = '27812006';
    }

    super.onInit();
  }

  Future<void> login() async {
    errorMessage.value = '';

    final userName = userNameController.text;
    final password = passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill all fields!';
      CustomWidgets.showSnackBar('Error', 'Please fill all fields!');
      return;
    }
    isLoading.value = true;

    api.login({'admission_number': userName, 'password': password}).then((
      response,
    ) async {
      if (response?.status == true && response?.data?.admissionNo != null) {
        await LocalStorage().writeUser(response?.data ?? Users());
        await LocalStorage().writeToken(response?.token ?? '');

        Get.snackbar(
          'Welcome',
          '${response?.data?.name}',
          colorText: Colors.white,
          icon: const Icon(Icons.login, color: Colors.white),
        );
        Get.offAll(() => const HomeScreen());
      } else {
        errorMessage.value = response?.message ?? 'Failed to login!';
        Get.snackbar('Error', errorMessage.value);
      }
      isLoading.value = false;
    });
  }

  bool onChangePassValidation() {
    if (oldpasswordController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter old password.');
      return false;
    }
    if ((newPassController.text.trim().isEmpty)) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter new password.');
      return false;
    }
    if (confirmPassController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Please confirm password.');
      return false;
    }
    if (newPassController.text != confirmPassController.text) {
      CustomWidgets.showSnackBar('Invalid', 'Passwords do not match');
      return false;
    }

    return true;
  }

  bool onResetPassValidation() {
    if ((newPassController.text.trim().isEmpty)) {
      CustomWidgets.showSnackBar('Invalid', 'Please enter new password.');
      return false;
    } else if (confirmPassController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar('Invalid', 'Confirm password is empty.');
      return false;
    } else if (newPassController.text != confirmPassController.text) {
      CustomWidgets.showSnackBar('Invalid', 'Passwords do not match');
      return false;
    }
    return true;
  }

  Future<void> changePassword(String id) async {
    isChangePassLoading.value = true;
    api
        .changePassword({
          'old_password': oldpasswordController.text,
          'new_password': confirmPassController.text,
        })
        .then((value) {
          isChangePassLoading.value = false;
          if (value?.status ?? false) {
            Get.to(() => const LoginScreen());
            CustomWidgets.showSnackBar(
              'Success',
              value?.message ?? 'Password Changed.',
            );
          } else {
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Password not changed.',
            );
          }
        });
  }

  Future<void> resetPassword(String id) async {
    isChangePassLoading.value = true;
    api
        .resetPassword({
          'admission_number': id,
          'new_password': confirmPassController.text,
        })
        .then((value) {
          isChangePassLoading.value = false;
          if (value?.status ?? false) {
            Get.back();
            CustomWidgets.showSnackBar(
              'Success',
              value?.message ?? 'Password Changed.',
            );
          } else {
            Get.back();
            CustomWidgets.showSnackBar(
              'Error',
              value?.message ?? 'Password not changed.',
            );
          }
        });
  }

  void deleteAccount() {
    if (reasonController.text.trim().length >= 20) {
      isLoading.value = true;
      final data = {
        'subject': 'Account delete request',
        'description': reasonController.text,
        'assigned_to': 'sec',
      };
      Api().addIssue(data).then((value) {
        isLoading.value = false;
        if (value?.status ?? false) {
          Get.snackbar("Success", "Delete request sent successfully");
          Get.offAll(() => const LoginScreen());
        } else {
          Get.snackbar("Error", "Failed to send delete request");
        }
      });
    } else {
      CustomWidgets.showSnackBar(
        'Invalid',
        'Please specify reason to delete account.(Min 20 characters)',
      );
    }
  }

  void logout() {
    isLoading.value = true;
    api.logout().then((value) {
      isLoading.value = false;
      if (value?.status ?? false) {
        log(value!.status!.toString());
        LocalStorage().clearAll();
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  void showPassword() => isObscure.value = false;
  void hidePassword() => isObscure.value = true;

  void showOldPassword() => isOldPassObscure.value = false;
  void hideOldPassword() => isOldPassObscure.value = true;

  void showNewPassword() => isNewPassObscure.value = false;
  void hideNewPassword() => isNewPassObscure.value = true;

  void showConfirmPassword() => isConfirmPassObscure.value = false;
  void hideConfirmPassword() => isConfirmPassObscure.value = true;
}
