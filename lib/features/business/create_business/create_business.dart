import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:no_interaction_dialog/no_interaction_dialog.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/place_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/constants/regex.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/business/create_business/bloc/create_business_bloc.dart';
import 'package:vivity/features/business/unapproved_business_page.dart';
import 'package:vivity/features/map/location_service.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:latlng/latlng.dart' as latlng;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart' as loc_interface;

class CreateBusiness extends StatefulWidget {
  CreateBusiness({Key? key}) : super(key: key);

  @override
  State<CreateBusiness> createState() => _CreateBusinessState();
}

class _CreateBusinessState extends State<CreateBusiness> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _businessNameController = TextEditingController();

  final TextEditingController _businessEmailController = TextEditingController();

  final TextEditingController _businessPhoneController = TextEditingController();

  final TextEditingController _businessNationalNumberController = TextEditingController();

  final NoInteractionDialogController _dialogController = NoInteractionDialogController();
  late final LoadDialog _loadDialog;
  late final CreateBusinessBloc _bloc;

  File? ownerIdFile;
  latlng.LatLng? location;
  LocationResult? locationData;

  bool isLoadingOpen = false;

  @override
  void initState() {
    super.initState();

    _loadDialog = LoadDialog(controller: _dialogController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = context.read<CreateBusinessBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: BlocListener<CreateBusinessBloc, CreateBusinessState>(
        listener: (context, state) {
          if (isLoadingOpen && state is! CreateBusinessCreating) {
            Navigator.pop(context);
            isLoadingOpen = false;

            if (state is CreateBusinessFailedCreating) {
              showSnackBar(state.message, context);
            } else if (state is CreateBusinessCreated) {
              Navigator.pushReplacementNamed(context, '/business');
              showSnackBar('Created business!', context);
            }
          }
        },
        child: defaultGradientBackground(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Register business',
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  // name, email, phone, national business number, business owner id, location
                  buildTextFormField('Business name', _businessNameController, ValidationBuilder().minLength(3).maxLength(40)),
                  buildTextFormField(
                    'Business email',
                    _businessEmailController,
                    ValidationBuilder().add((value) => validEmail.hasMatch(value ?? "f") ? null : "Must be a valid email"),
                  ),
                  buildTextFormField(
                    'Business phone',
                    _businessPhoneController,
                    ValidationBuilder().add((value) {
                      if (value?.length != 10) return 'Must be a 10 digit number';
                      return int.tryParse(value ?? "f") != null ? null : 'Must be a 10 digit number';
                    }),
                  ),
                  buildTextFormField(
                    'National business number',
                    _businessNationalNumberController,
                    ValidationBuilder().minLength(4).maxLength(20).add((String? value) => value == null
                        ? "Must be a number"
                        : double.tryParse(value) != null
                            ? null
                            : "Must be a number"),
                  ),
                  Divider(thickness: 0, color: Colors.transparent),
                  if (ownerIdFile == null)
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(primaryComplementaryColor),
                        overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.4)),
                        fixedSize: MaterialStateProperty.all(Size(40.w, 15.sp * 2)),
                      ),
                      onPressed: () => filePickRoutine().then((value) => setState(() => ownerIdFile = value ?? ownerIdFile)),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.folder_open_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Picture of ID',
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white),
                          )
                        ],
                      ),
                    )
                  else ...[
                    Text(
                      'Picture of business owner\'s ID',
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => filePickRoutine().then((value) => setState(() => ownerIdFile = value ?? ownerIdFile)),
                      child: Image.file(ownerIdFile!, height: 30.h),
                    ),
                  ],
                  Divider(thickness: 0, color: Colors.transparent),
                  if (locationData != null)
                    Text(
                      'Selected: ${locationData!.name}',
                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal),
                    ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryComplementaryColor),
                      overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.4)),
                      fixedSize: MaterialStateProperty.all(Size(40.w, 15.sp * 2)),
                    ),
                    onPressed: () async {
                      LocationResult? res = await showPlacePicker();
                      setState(() {
                        location = res == null ? null : latlng.LatLng(res.latLng!.latitude, res.latLng!.longitude);
                        locationData = res;
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Shop location',
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 0, color: Colors.transparent),
                  Center(
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                        overlayColor: MaterialStateProperty.all(Colors.grey),
                        fixedSize: MaterialStateProperty.all(Size(85.w, 15.sp * 3)),
                      ),
                      child: Text(
                        'Register',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
                      ),
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? true)) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out correctly.')));
                          return;
                        } else if (ownerIdFile == null || location == null) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missing business location or owner ID')));
                          return;
                        }

                        _formKey.currentState?.save();
                        handleRegister(
                          _businessNameController.value.text,
                          _businessEmailController.value.text,
                          _businessPhoneController.value.text,
                          _businessNationalNumberController.value.text,
                          ownerIdFile!,
                          location!,
                        );
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registering!')));
                        showDialog(context: context, builder: (ctx) => _loadDialog);
                        isLoadingOpen = true;
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleRegister(
    String businessName,
    String businessEmail,
    String businessPhone,
    String nationalBusinessNumber,
    File ownerId,
    latlng.LatLng location,
  ) {
    _bloc.add(CreateBusinessCreateEvent(
      businessName: businessName.trim(),
      businessEmail: businessEmail.trim(),
      businessPhone: businessPhone.trim(),
      nationalBusinessNumber: nationalBusinessNumber.trim(),
      ownerId: ownerId,
      location: location,
    ));
  }

  Widget buildTextFormField(String labelText, TextEditingController controller, ValidationBuilder validation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          width: 85.w,
          child: TextFormField(
            controller: controller,
            validator: validation.build(),
            style: TextStyle(fontSize: 12.sp, color: Colors.black),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> filePickRoutine() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  Future<LocationResult?> showPlacePicker() async {
    latlng.LatLng loc = await LocationService().getPosition(defaultLocation: latlng.LatLng(31.0461, 34.8516));

    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              googleApiKey,
              displayLocation: loc_interface.LatLng(loc.latitude, loc.longitude),
            )));

    return result;
  }
}
