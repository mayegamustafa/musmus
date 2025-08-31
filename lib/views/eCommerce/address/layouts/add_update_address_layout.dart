// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:ready_ecommerce/components/ecommerce/custom_button.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_text_field.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/address/address_controller.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/models/eCommerce/address/add_address.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';

class AddUpdateAddressLayout extends ConsumerStatefulWidget {
  final AddAddress? address;
  const AddUpdateAddressLayout({
    super.key,
    required this.address,
  });

  @override
  ConsumerState<AddUpdateAddressLayout> createState() =>
      _AddUpdateAddressLayoutState();
}

class _AddUpdateAddressLayoutState extends ConsumerState<AddUpdateAddressLayout> {
  final GlobalKey<FormBuilderState> _formkey = GlobalKey<FormBuilderState>();

  final TextEditingController nameControler = TextEditingController();

  final TextEditingController phoneNumController = TextEditingController();

  final TextEditingController areaController = TextEditingController();

  final TextEditingController flatNumController = TextEditingController();

  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController addressLine1Controller = TextEditingController();

  final TextEditingController addressLine2Controller = TextEditingController();

  int activeIndex = 0;

  List<String> addressTags = ['Home', 'Office', 'other'];
  String addressTag = '';

  Future<void> _fillAddressFromGPS(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied. Please enable it in settings.')),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          areaController.text = place.subLocality ?? '';
          flatNumController.text = place.subThoroughfare ?? '';
          postalCodeController.text = place.postalCode ?? '';
          addressLine1Controller.text = place.street ?? '';
          addressLine2Controller.text = place.locality ?? '';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address auto-filled from GPS.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  final List<FocusNode> fNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];
  bool isDefaultAddress = false;

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      nameControler.text = widget.address!.name;
      phoneNumController.text = widget.address!.phone;
      areaController.text = widget.address!.area ?? '';
      flatNumController.text = widget.address!.flatNo ?? '';
      postalCodeController.text = widget.address!.postCode ?? '';
      addressLine1Controller.text = widget.address!.addressLine;
      addressLine2Controller.text = widget.address!.addressLine2 ?? '';
      addressTag = widget.address!.addressType;
      isDefaultAddress = widget.address!.isDefault;
      activeIndex = addressTags.indexOf(widget.address!.addressType);
    } else {
      addressTag = addressTags.first;
    }
  }

  @override
  void dispose() {
    nameControler.dispose();
    phoneNumController.dispose();
    areaController.dispose();
    flatNumController.dispose();
    postalCodeController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materModelData =
        ref.watch(masterControllerProvider.notifier).materModel.data;
    final isPhoneRequired = materModelData.phoneRequired;
    int? phoneMinLength = materModelData.phoneMinLength;
    int? phoneMaxLength = materModelData.phoneMaxLength;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).addNewAddress),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: FormBuilder(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SingleChildScrollView(
              child: AnimationLimiter(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Auto-fill from GPS'),
                        onPressed: () => _fillAddressFromGPS(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    ...AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        SizedBox(height: 10.h),
                        CustomTextFormField(
                          name: S.of(context).name,
                          hintText: S.of(context).name,
                          textInputType: TextInputType.text,
                          controller: nameControler,
                          focusNode: fNodes[0],
                          textInputAction: TextInputAction.next,
                          validator: (value) => GlobalFunction.commonValidator(
                            context: context,
                            value: value!,
                            hintText: S.of(context).name,
                          ),
                        ),
                        Gap(14.h),
                        CustomTextFormField(
                          name: S.of(context).phone,
                          hintText: S.of(context).phone,
                          textInputType: TextInputType.number,
                          controller: phoneNumController,
                          focusNode: fNodes[1],
                          textInputAction: TextInputAction.next,
                          validator: (value) => GlobalFunction.phoneValidator(
                            isPhoneRequired: isPhoneRequired,
                            context: context,
                            value: value!,
                            hintText: S.of(context).phone,
                            minLength: phoneMinLength,
                            maxLength: phoneMaxLength,
                          ),
                        ),
                        Gap(14.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: CustomTextFormField(
                                name: S.of(context).area,
                                hintText: S.of(context).area,
                                textInputType: TextInputType.text,
                                controller: areaController,
                                focusNode: fNodes[2],
                                textInputAction: TextInputAction.next,
                                validator: (value) => null,
                              ),
                            ),
                            Gap(5.w),
                            Flexible(
                              flex: 1,
                              child: CustomTextFormField(
                                name: S.of(context).flat,
                                hintText: S.of(context).flat,
                                textInputType: TextInputType.text,
                                controller: flatNumController,
                                focusNode: fNodes[3],
                                textInputAction: TextInputAction.next,
                                validator: (value) => null,
                              ),
                            ),
                            Gap(5.w),
                            Flexible(
                              flex: 1,
                              child: CustomTextFormField(
                                name: S.of(context).postalCode,
                                hintText: '1200',
                                textInputType: TextInputType.text,
                                controller: postalCodeController,
                                focusNode: fNodes[4],
                                textInputAction: TextInputAction.next,
                                validator: (value) => null,
                              ),
                            ),
                          ],
                        ),
                        Gap(14.h),
                        CustomTextFormField(
                          name: S.of(context).addressLine1,
                          hintText: S.of(context).addressLine1,
                          textInputType: TextInputType.text,
                          controller: addressLine1Controller,
                          focusNode: fNodes[5],
                          textInputAction: TextInputAction.next,
                          validator: (value) => GlobalFunction.commonValidator(
                            context: context,
                            value: value!,
                            hintText: S.of(context).addressLine1,
                          ),
                        ),
                        Gap(14.h),
                        CustomTextFormField(
                          name: S.of(context).addressLine2,
                          hintText: S.of(context).addressLine2,
                          textInputType: TextInputType.text,
                          controller: addressLine2Controller,
                          textInputAction: TextInputAction.next,
                          validator: (value) => null,
                        ),
                        Gap(14.h),
                        buildAddressTag(),
                        Gap(14.h),
                        Row(
                          children: [
                            Checkbox(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              activeColor: colors(context).primaryColor,
                              value: isDefaultAddress,
                              onChanged: (defult) {
                                setState(() {
                                  isDefaultAddress = defult!;
                                });
                              },
                            ),
                            Text(S.of(context).makeItDefault, style: AppTextStyle(context).bodyTextSmall),
                            const Spacer(),
                            widget.address?.addressId != null
                                ? TextButton(
                                    onPressed: () {
                                      ref.read(addressControllerProvider.notifier).deleteAddress(
                                        addressId: widget.address?.addressId ?? 0,
                                      ).then((response) {
                                        if (response.isSuccess) {
                                          GlobalFunction.showCustomSnackbar(
                                              message: response.message,
                                              isSuccess: response.isSuccess);
                                          ref.read(addressControllerProvider.notifier).getAddress();
                                          context.nav.pop();
                                        }
                                      });
                                    },
                                    child: Text(
                                      S.of(context).deleteThis,
                                      style: AppTextStyle(context).bodyText.copyWith(color: EcommerceAppColor.red),
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20),
          child: ref.watch(addressControllerProvider)
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  buttonText: S.of(context).save,
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      final AddAddress address = AddAddress(
                        addressId: widget.address?.addressId,
                        name: nameControler.text,
                        phone: phoneNumController.text,
                        area: areaController.text,
                        flatNo: flatNumController.text,
                        postCode: postalCodeController.text,
                        addressLine: addressLine1Controller.text,
                        addressLine2: addressLine2Controller.text,
                        addressType: addressTag,
                        isDefault: isDefaultAddress,
                      );
                      if (widget.address != null) {
                        ref.read(addressControllerProvider.notifier).updateAddress(addAddress: address).then((response) {
                          if (response.isSuccess) {
                            GlobalFunction.showCustomSnackbar(
                                message: response.message,
                                isSuccess: response.isSuccess);
                            ref.read(addressControllerProvider.notifier).getAddress();
                            context.nav.pop();
                          }
                        });
                      } else {
                        ref.read(addressControllerProvider.notifier).addAddress(addAddress: address).then((response) {
                          if (response.isSuccess) {
                            GlobalFunction.showCustomSnackbar(
                                message: response.message,
                                isSuccess: response.isSuccess);
                            ref.read(addressControllerProvider.notifier).getAddress();
                            context.nav.pop();
                          }
                        });
                      }
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget buildAddressTag() {
    final textStyle = AppTextStyle(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).addressTag,
          style: AppTextStyle(context)
              .bodyTextSmall
              .copyWith(fontWeight: FontWeight.w500),
        ),
        Gap(14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: addressTags.asMap().entries.map(
            (entry) {
              int index = entry.key;
              String tag = entry.value;
              return InkWell(
                borderRadius: BorderRadius.circular(8.sp),
                onTap: () {
                  setState(() {
                    activeIndex = index;
                    addressTag = tag;
                  });
                },
                child: Container(
                  height: 50.h,
                  width: 110.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.sp),
                    border: Border.all(
                      color: activeIndex == index
                          ? colors(context).primaryColor ??
                              EcommerceAppColor.primary
                          : colors(context).bodyTextColor!.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      getTagTranslation(tag: tag),
                      style: textStyle.bodyTextSmall.copyWith(
                          color: activeIndex == index
                              ? colors(context).primaryColor ??
                                  EcommerceAppColor.primary
                              : colors(context).bodyTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  String getTagTranslation({required String tag}) {
    switch (tag.toUpperCase()) {
      case 'HOME':
        return S.of(ContextLess.context).home;
      case 'OFFICE':
        return S.of(ContextLess.context).office;
      default:
        return S.of(ContextLess.context).other;
    }
  }
}
