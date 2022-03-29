import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';

import 'bloc/user_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! UserLoggedInState) return const Text("Can't see this page without being logged in.\nHow are you even here?");

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
