import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/auth/auth_service.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';

class RegisterModule extends StatefulWidget {
  @override
  State<RegisterModule> createState() => _RegisterModuleState();
}

class _RegisterModuleState extends State<RegisterModule> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: Add accurate validation checks
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              buildTextFormField('Email', emailController),
              SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 85.w,
                  child: TextFormField(
                    controller: passwordController,
                    validator: ValidationBuilder().minLength(8).maxLength(80).build(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    obscureText: true,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              buildTextFormField('Phone', phoneController),
              SizedBox(height: 15),
              buildTextFormField('Name', nameController),
              SizedBox(height: 25),
              Center(
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      fixedSize: MaterialStateProperty.all(Size(85.w, 15.sp * 3))),
                  child: Text(
                    'Register',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 20.sp, fontWeight: FontWeight.normal, color: Colors.white),
                  ),
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? true)) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out correctly.')));
                      return;
                    }
                    _formKey.currentState?.save();
                    handleRegister(
                      emailController.text,
                      passwordController.text,
                      phoneController.text,
                      nameController.text,
                      context,
                    );
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registering!')));
                  },
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFormField(String labelText, TextEditingController controller) {
    return Center(
      child: SizedBox(
        width: 85.w,
        child: TextFormField(
          controller: controller,
          validator: ValidationBuilder().minLength(5).maxLength(80).build(),
          style: TextStyle(fontSize: 12.sp, color: Colors.black),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  void handleRegister(String email, String password, String phone, String name, BuildContext context) {
    print("Handling register - Email: $email, Password: $password, Name: $name, Phone: $phone");
    context.read<AuthBloc>().add(AuthRegisterEvent(email, password, name, phone));
  }
}
