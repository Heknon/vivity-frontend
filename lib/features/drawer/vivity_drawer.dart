import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/drawer/bloc/drawer_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../../config/themes/themes_config.dart';

class VivityDrawer extends StatefulWidget {
  const VivityDrawer({Key? key}) : super(key: key);

  @override
  State<VivityDrawer> createState() => _VivityDrawerState();
}

class _VivityDrawerState extends State<VivityDrawer> {
  late final DrawerBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = context.read<DrawerBloc>();
  }

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
          child: BlocBuilder<DrawerBloc, DrawerState>(
            builder: (context, state) {
              if (state is! DrawerLoaded) return CircularProgressIndicator();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => filePickRoutine().then((value) {
                          if (value != null) {
                            _bloc.add(DrawerUpdateProfilePictureEvent(value));
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
                                  _bloc.add(DrawerDeleteProfilePictureEvent());
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
                                backgroundImage: Image.memory(state.profilePicture!).image,
                                radius: 48.sp,
                              )
                            : placeholderPfp,
                      ),
                      SizedBox(
                        width: 40.w,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Hello,\n${state.name}',
                            style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white, fontSize: 16.sp),
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(thickness: 0),
                  buildMenuButton(text: 'Profile', onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/profile');
                  }, context: context),
                  const Divider(thickness: 0),
                  buildMenuButton(
                    text: 'Settings',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/settings');
                    },
                    context: context,
                  ),
                  SizedBox(height: 7.h),
                  // TODO: Check whether already on home page.
                  buildMenuButton(
                    text: 'Home',
                    context: context,
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      if (Scaffold.of(context).isDrawerOpen) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Divider(thickness: 0),
                  buildMenuButton(text: 'Favorites list', onPressed: () => Navigator.of(context).pushNamed('/favorites'), context: context),
                  SizedBox(height: 7.h),
                  buildMenuButton(
                    text: state.ownsBusiness ? "My business" : "Create business",
                    onPressed: () {
                      Navigator.pop(context);
                      state.ownsBusiness ? Navigator.pushNamed(context, '/business') : Navigator.pushNamed(context, '/business/create');
                    },
                    context: context,
                  ),
                  if (state.isAdmin) ...[
                    const Divider(thickness: 0),
                    buildMenuButton(
                      text: 'Admin controls',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/admin');
                      },
                      context: context,
                    ),
                  ],
                  Spacer(),
                  buildMenuButton(
                    text: 'Sign out',
                    onPressed: () {
                      Navigator.pop(context);
                      showSnackBar('Signing out...', context);
                      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                        Navigator.pushReplacementNamed(context, '/logout');
                      });
                    },
                    context: context,
                    optionalStyle: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.grey[400]?.withOpacity(0.6), fontSize: 14.sp),
                  ),
                ],
              );
            },
          ),
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

  void smartDrawerNavigation(String route) {
    // TODO: Write function
  }
}
