import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/business/create_business.dart';
import 'package:vivity/features/business/unapproved_business_page.dart';
import 'package:vivity/features/home/home_page.dart';
import 'package:vivity/features/item/favorites_page.dart';
import 'package:vivity/features/settings/settings_page.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/features/user/profile_page.dart';
import 'package:vivity/main.dart';

import '../../config/themes/themes_config.dart';
import '../admin/admin_page.dart';
import '../business/business_page.dart';

class VivityDrawer extends StatelessWidget {
  const VivityDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget placeholderPfp = Icon(
      Icons.account_circle,
      color: Colors.white,
      size: 48.sp * 2,
    );

    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
            if (state is! UserLoggedInState) return const Text('You must be logged in to view the drawer. Why aren\'t you logged in?');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => filePickRoutine().then((value) {
                        if (value != null) {
                          context.read<UserBloc>().add(UserUpdateProfilePictureEvent(value));
                        }
                      }),
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Delete profile picture',
                            style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.read<UserBloc>().add(UserUpdateProfilePictureEvent(null));
                              },
                              style: ButtonStyle(
                                  splashFactory: InkRipple.splashFactory,
                                  textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
                              child: Text(
                                'DELETE',
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: primaryComplementaryColor, fontSize: 14.sp),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: ButtonStyle(
                                  splashFactory: InkRipple.splashFactory,
                                  textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.headline3?.copyWith(fontSize: 14.sp))),
                              child: Text(
                                'CANCEL',
                                style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey[600]!.withOpacity(0.7), fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: state.profilePicture != null
                          ? CircleAvatar(
                              backgroundImage: Image.file(state.profilePicture!).image,
                              radius: 48.sp,
                            )
                          : placeholderPfp,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Hello,\n${state.name}',
                        style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white, fontSize: 16.sp),
                      ),
                    )
                  ],
                ),
                const Divider(thickness: 0),
                buildMenuButton(
                    text: 'Profile',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfilePage())),
                    context: context),
                const Divider(thickness: 0),
                buildMenuButton(
                  text: 'Settings',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => SettingsPage())),
                  context: context,
                ),
                SizedBox(height: 7.h),
                // TODO: Check whether already on home page.
                buildMenuButton(
                    text: 'Home', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => HomePage())), context: context),
                const Divider(thickness: 0),
                buildMenuButton(
                    text: 'Favorites list',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => FavoritesPage())),
                    context: context),
                SizedBox(height: 7.h),
                buildMenuButton(
                  text: state.businessId != null ? "My business" : "Create business",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) {
                          if (state.businessId != null && state is BusinessUserLoggedInState) {
                            return state.business.approved ? BusinessPage() : UnapprovedBusinessPage();
                          }

                          return CreateBusiness();
                        },
                      ),
                    );
                  },
                  context: context,
                ),
                if (state.isSystemAdmin) ...[
                  const Divider(thickness: 0),
                  buildMenuButton(
                    text: 'Admin controls',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => AdminPage())),
                    context: context,
                  ),
                ],
                Spacer(),
                buildMenuButton(
                  text: 'Sign out',
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<UserBloc>().add(UserLogoutEvent());
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signing out...')));
                    logoutRoutine(context);
                  },
                  context: context,
                  optionalStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey[400]?.withOpacity(0.6), fontSize: 14.sp),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildMenuButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context,
    TextStyle? optionalStyle,
  }) {
    TextStyle? style = optionalStyle ?? Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white, fontSize: 16.sp);

    return TextButton(
      style: ButtonStyle(
        splashFactory: InkRipple.splashFactory,
        textStyle: MaterialStateProperty.all(style),
        overlayColor: MaterialStateProperty.all(Colors.grey),
        minimumSize: MaterialStateProperty.all(Size.zero),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: style,
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
}
