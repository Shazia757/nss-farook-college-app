import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/database/local_storage.dart';
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
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    oldpasswordController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (isClosed) return;
    errorMessage.value = '';

    final userName = userNameController.text.trim();
    final password = passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill all fields!';
      CustomWidgets.showSnackBar('Error', 'Please fill all fields!');
      return;
    }
    isLoading.value = true;

    try {
      final response = await api.login({
        'admission_number': userName,
        'password': password,
      });
      if (isClosed) return;
      if (response?.status == true && response?.data?.admissionNo != null) {
        final user = response!.data!;
        final token = response.token ?? '';
        final role = user.role ?? response.role ?? 'vol';

        LocalStorage().writeSession(user: user, token: token, role: role);

        userNameController.clear();
        passwordController.clear();

        Get.snackbar(
          'Welcome',
          '${user.name}',
          colorText: Colors.white,
          icon: const Icon(Icons.login, color: Colors.white),
        );
        Get.offAll(() => const HomeScreen());
      } else {
        errorMessage.value = response?.message ?? 'Failed to login!';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      if (!isClosed) {
        errorMessage.value = 'Login error: $e';
        Get.snackbar('Error', errorMessage.value);
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
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
    if (isClosed) return;
    isChangePassLoading.value = true;
    api
        .changePassword({
          'old_password': oldpasswordController.text,
          'new_password': confirmPassController.text,
        })
        .then((value) {
          if (isClosed) return;
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
        })
        .catchError((_) {
          if (!isClosed) isChangePassLoading.value = false;
        });
  }

  Future<void> resetPassword(String id) async {
    if (isClosed) return;
    isChangePassLoading.value = true;
    api
        .resetPassword({
          'admission_number': id,
          'new_password': confirmPassController.text,
        })
        .then((value) {
          if (isClosed) return;
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
        })
        .catchError((_) {
          if (!isClosed) isChangePassLoading.value = false;
        });
  }

  void deleteAccount() {
    if (reasonController.text.trim().length >= 20) {
      if (isClosed) return;
      isLoading.value = true;
      final data = {
        'subject': 'Account delete request',
        'description': reasonController.text,
        'assigned_to': 'sec',
      };
      Api()
          .addIssue(data)
          .then((value) {
            if (isClosed) return;
            isLoading.value = false;
            if (value?.status ?? false) {
              Get.snackbar("Success", "Delete request sent successfully");
              Get.offAll(() => const LoginScreen());
            } else {
              Get.snackbar("Error", "Failed to send delete request");
            }
          })
          .catchError((_) {
            if (!isClosed) isLoading.value = false;
          });
    } else {
      CustomWidgets.showSnackBar(
        'Invalid',
        'Please specify reason to delete account.(Min 20 characters)',
      );
    }
  }

  void logout() async {
    if (!isClosed) isLoading.value = true;
    try {
      await api.logout();
    } catch (e) {
      log('Logout api error: $e');
    } finally {
      if (!isClosed) isLoading.value = false;
      LocalStorage().clearAll();
      Get.deleteAll(force: true);
      Get.offAll(() => const LoginScreen());
    }
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
