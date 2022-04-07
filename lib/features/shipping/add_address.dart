import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/shipping/address_service.dart';
import '../../models/address.dart';

import '../user/bloc/user_bloc.dart';

class AddAddress extends StatefulWidget {
  const AddAddress({Key? key}) : super(key: key);

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  CountryCode? selectedCountryCode;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController streetExtraController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Get from current GPS/wifi - Use a BLOC for location state management
    selectedCountryCode = CountryCode.fromCountryCode("IL");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Add Address'),
      titleTextStyle: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 14.sp),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country/Region',
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 5),
            CountryCodePicker(
              onChanged: (code) => setState(() {
                selectedCountryCode = code;
              }),
              initialSelection: selectedCountryCode!.code,
              flagDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
              ),
              builder: (CountryCode? code) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Material(
                        elevation: 2,
                        child: SvgPicture.asset(
                          'icons/flags/svg/${code!.code!.toLowerCase()}.svg',
                          package: 'country_icons',
                          width: 25,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        code.name!,
                        style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 10.sp),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_drop_down_sharp, color: Colors.grey[500])
                    ],
                  ),
                );
              },
              searchStyle: TextStyle(fontSize: 12.sp, color: Colors.black),
              showDropDownButton: true,
              dialogSize: Size(85.w, 70.h),
            ),
            SizedBox(height: 10),
            Text(
              'Full name (First and Last name)',
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: nameController,
              validator: ValidationBuilder().minLength(1).maxLength(40).build(),
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Phone number',
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: phoneController,
              validator: ValidationBuilder()
                  .minLength(10)
                  .maxLength(10)
                  .add((String? value) => value == null
                      ? "Must be a number"
                      : double.tryParse(value) != null
                          ? null
                          : "Must be a number")
                  .build(),
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Street address',
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: streetController,
              validator: ValidationBuilder().minLength(1).maxLength(60).build(),
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: "Street address",
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: streetExtraController,
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
              validator: ValidationBuilder().minLength(1).maxLength(80).build(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: "Apt, suite, unit, building, floor, etc.",
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'State / Province / Region',
              style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: provinceController,
              validator: ValidationBuilder().minLength(1).maxLength(50).build(),
              style: TextStyle(fontSize: 12.sp, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City',
                        style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: cityController,
                        validator: ValidationBuilder().minLength(1).maxLength(50).build(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ZIP Code',
                        style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 13.sp),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: zipCodeController,
                        validator: ValidationBuilder()
                            .minLength(5)
                            .maxLength(7)
                            .add((String? value) => value == null
                                ? "Must be a number"
                                : double.tryParse(value) != null
                                    ? null
                                    : "Must be a number")
                            .build(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                  overlayColor: MaterialStateProperty.all(Colors.grey),
                  fixedSize: MaterialStateProperty.all(Size(90.w, 15.sp * 3))),
              child: Text(
                'Add Address',
                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
              ),
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? true)) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out correctly.')));
                  return;
                }
                _formKey.currentState?.save();
                handleSuccessfulSubmission(
                  selectedCountryCode!,
                  nameController.value.text,
                  phoneController.value.text,
                  streetController.value.text,
                  streetExtraController.value.text,
                  provinceController.value.text,
                  cityController.value.text,
                  zipCodeController.value.text,
                  (context.read<UserBloc>().state as UserLoggedInState).accessToken,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void handleSuccessfulSubmission(
    CountryCode country,
    String fullName,
    String phoneNumber,
    String street,
    String extraAddressInfo,
    String province,
    String city,
    String zipCode,
    String token,
  ) async {
    print(
        "Handling: (country: $country, name: $fullName, phone: $phoneNumber, street: $street, streetExtra: $extraAddressInfo, province: $province, city: $city, zipCode: $zipCode)");

    List<Address> addresses = await addAddress(
        token,
        Address(
          name: fullName.trim(),
          country: selectedCountryCode!.code!.trim(),
          city: city.trim(),
          street: street.trim(),
          extraInfo: extraAddressInfo.trim(),
          province: province.trim(),
          zipCode: zipCode.trim(),
          phone: phoneNumber.trim(),
        ),
      context: context
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address added!')));

    context.read<UserBloc>().add(UserUpdateAddressesEvent(addresses));
  }
}
