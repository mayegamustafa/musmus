// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:ready_ecommerce/components/ecommerce/animate_image.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/other_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/authentication/authentication_controller.dart';
import 'package:ready_ecommerce/controllers/misc/misc_controller.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/common/authentication/components/pin_put.dart';

import '../../../../controllers/common/master_controller.dart';

class ConfirmOTPLayout extends ConsumerStatefulWidget {
  final ConfirmOTPScreenArguments arguments;
  const ConfirmOTPLayout({
    super.key,
    required this.arguments,
  });

  @override
  ConsumerState<ConfirmOTPLayout> createState() => _ConfirmOTPLayoutState();
}

class _ConfirmOTPLayoutState extends ConsumerState<ConfirmOTPLayout> {
  final TextEditingController pinCodeController = TextEditingController();

  Timer? timer;
  int start = 60;
  bool isComplete = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initOTP();
    });
    startTimer();

    pinCodeController.addListener(pinCodeListener);
    super.initState();
  }

  Future initOTP() async {
    ref
        .read(authControllerProvider.notifier)
        .sendOTP(
            phone: widget.arguments.phoneNumber,
            isForgot: widget.arguments.isPasswordRecover)
        .then((response) {
      // if (response.isSuccess) pinCodeController.text = response.data.toString();
      GlobalFunction.showCustomSnackbar(
          message: response.message, isSuccess: response.isSuccess);
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      if (start == 0) {
        timer.cancel();
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  void pinCodeListener() {
    if (pinCodeController.text.length == 4) {
      setState(() {
        isComplete = true;
      });
      // Optionally auto-submit OTP
      // _onConfirmOTP();
    } else {
      setState(() {
        isComplete = false;
      });
    }
  }

  Future<void> _onConfirmOTP() async {
    if (!isComplete) return;
    setState(() { isComplete = false; });
    final response = await ref.read(authControllerProvider.notifier).verifyOTP(
      phone: widget.arguments.phoneNumber,
      otp: pinCodeController.text,
    );
    if (response.isSuccess) {
      if (widget.arguments.isPasswordRecover) {
        context.nav.pushNamed(
          Routes.createPassword,
          arguments: response.data.toString(),
        );
      } else if (widget.arguments.isFromCheckoutScreen == true) {
        ref.read(isProfileVefifySuccess.notifier).state = true;
        ref.refresh(profileInfoControllerProvider);
        Future.delayed(const Duration(milliseconds: 200), () {
          context.nav.pop();
        });
      } else {
        context.nav.pushNamed(
          Routes.getCoreRouteName(AppConstants.appServiceName),
        );
      }
      GlobalFunction.showCustomSnackbar(
        message: response.message,
        isSuccess: response.isSuccess,
      );
    } else {
      GlobalFunction.showCustomSnackbar(
        message: response.message,
        isSuccess: false,
      );
    }
    setState(() { isComplete = true; });
  }

  @override
  void dispose() {
    timer!.cancel();
    pinCodeController.removeListener(pinCodeListener);

    // pinCodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedImage(
                      imageSize: 100.w,
                      imageWidget: Assets.png.confirmOtp.image()),
                  Gap(20.h),
                  Text(
                    S.of(context).enterotp,
                    style: AppTextStyle(context)
                        .title
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Gap(20.h),
                  Column(
                    children: [
                      if (ref
                              .read(masterControllerProvider.notifier)
                              .materModel
                              .data
                              .registerOtpType ==
                          'email') ...[
                        Text(S.of(context).weSentOtpEmail)
                      ] else ...[
                        Text(S.of(context).weSentOtpPhone)
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.arguments.phoneNumber,
                            style: AppTextStyle(context).bodyText.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colors(context).primaryColor,
                                ),
                          ),
                          Gap(5.w),
                          GestureDetector(
                              onTap: () {
                                context.nav.pop();
                              },
                              child: SvgPicture.asset(Assets.svg.edit))
                        ],
                      )
                    ],
                  ),
                  Gap(40.h),
                  PinPutWidget(
                    pinCodeController: pinCodeController,
                    onCompleted: (pin) {},
                    validator: (value) {
                      return null;
                    },
                  ),
                  Gap(30.h),
                  AbsorbPointer(
                    absorbing: !isComplete || ref.watch(authControllerProvider),
                    child: ref.watch(authControllerProvider)
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            buttonText: S.of(context).confirmOtp,
                            buttonColor: isComplete
                                ? colors(context).primaryColor
                                : ColorTween(
                                    begin: colors(context).primaryColor,
                                    end: colors(context).light,
                                  ).lerp(0.5),
                            onPressed: _onConfirmOTP,
                          ),
                  ),
                  Gap(30.h),
                  Text(
                    "${S.of(context).resendCode} 00:$start sec",
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (start == 0)
                    GestureDetector(
                      onTap: () {
                        start = 60;
                        startTimer();
                        initOTP();
                      },
                      child: Text(
                        S.of(context).resend,
                        style: AppTextStyle(context)
                            .bodyTextSmall
                            .copyWith(color: colors(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmOTPScreenArguments {
  final String phoneNumber;
  final bool isPasswordRecover;
  final bool? isFromCheckoutScreen;
  ConfirmOTPScreenArguments({
    required this.phoneNumber,
    required this.isPasswordRecover,
    this.isFromCheckoutScreen,
  });
}
