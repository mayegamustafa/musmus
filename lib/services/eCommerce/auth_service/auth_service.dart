import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/sign_up.dart';
import 'package:ready_ecommerce/models/eCommerce/authentication/user.dart';
import 'package:ready_ecommerce/services/base/eCommerce/auth_provider_base.dart';
import 'package:ready_ecommerce/utils/api_client.dart';

final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService implements AuthProviderBase {
  // Google login
  Future<Response> loginWithGoogle({required String idToken}) async {
    final response = await Dio().post(
      AppConstants.googleLogin,
      data: {
        'id_token': idToken,
      },
    );
    return response;
  }

  // Driver location update (for driver app)
  Future<Response> updateDriverLocation({required int driverId, required double lat, required double lng}) async {
    final response = await Dio().post(
      AppConstants.driverLocationPost,
      data: {
        'driver_id': driverId,
        'lat': lat,
        'lng': lng,
      },
    );
    return response;
  }

  // Get driver location (for customer app)
  Future<Response> getDriverLocation({required int driverId}) async {
    final response = await Dio().get(
      '${AppConstants.driverLocationGet}/$driverId',
    );
    return response;
  }
  final Ref ref;
  AuthService(this.ref);
  @override
  Future<Response> signUp({
    required SingUp singUpInfo,
  }) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await ref.read(apiClientProvider).post(
      AppConstants.registrationUrl,
      data: {
        ...singUpInfo.toMap(),
        'device_key': fcmToken,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      },
    );
    return response;
  }

  @override
  Future<Response> sendOTP(
      {required String phone, required bool isForgot}) async {
    // Only phone is required for new endpoint
    final response = await Dio().post(
      AppConstants.sendOTP,
      data: {
        "phone": phone,
      },
    );
    return response;
  }

  @override
  Future<Response> login(
      {required String phone, required String password}) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    final response = await ref.read(apiClientProvider).post(
      AppConstants.loginUrl,
      data: {
        "phone": phone,
        "password": password,
        "device_key": fcmToken,
        "device_type": Platform.isIOS ? 'ios' : 'android',
      },
    );
    return response;
  }

  @override
  Future<Response> verifyOTP(
      {required String phone, required String otp}) async {
    final response = await Dio().post(
      AppConstants.verifyOtp,
      data: {
        "phone": phone,
        "otp": otp,
      },
    );
    return response;
  }

  @override
  Future<Response> resetPassword({
    required String password,
    required String confirmPassword,
    required String forgotPasswordToken,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.resetPassword,
      data: {
        "password": password,
        "password_confirmation": confirmPassword,
        "token": forgotPasswordToken,
      },
    );
    return response;
  }

  @override
  Future<Response> logout() async {
    final response =
        await ref.read(apiClientProvider).post(AppConstants.logout);

    return response;
  }

  @override
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.changePassword,
      data: {
        "current_password": oldPassword,
        "password": newPassword,
        "password_confirmation": confirmNewPassword,
      },
    );
    return response;
  }

  @override
  Future<Response> updateProfile(
      {required User userInfo, required File? file}) async {
    FormData formData = FormData.fromMap({
      "profile_photo": file != null
          ? await MultipartFile.fromFile(file.path,
              filename: 'profile_photo.jpg')
          : null,
      ...userInfo.toMap(),
    });
    final response = await ref
        .read(apiClientProvider)
        .post(AppConstants.updateProfile, data: formData);
    return response;
  }
}
