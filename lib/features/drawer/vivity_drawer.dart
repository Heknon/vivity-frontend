import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/business/create_business.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/main.dart';

import '../business/business_page.dart';

class VivityDrawer extends StatelessWidget {
  const VivityDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserLoggedInState userState = (context.read<UserBloc>().state as UserLoggedInState);
    String? pfpUrl = userState.profilePicture;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedNetworkImage(
                    imageUrl: pfpUrl ?? "",
                    imageBuilder: (ctx, prov) => CircleAvatar(
                      backgroundImage: prov,
                      radius: 48.sp,
                    ),
                    placeholder: (ctx, text) => placeholderPfp,
                    errorWidget: (ctx, text, e) => placeholderPfp,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Welcome back,\n${userState.name}',
                      style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.white, fontSize: 16.sp),
                    ),
                  )
                ],
              ),
              const Divider(thickness: 0),
              buildMenuButton(text: 'Profile', onPressed: () => print("Pressed Profile"), context: context),
              const Divider(thickness: 0),
              buildMenuButton(text: 'Settings', onPressed: () => print("Pressed Settings"), context: context),
              SizedBox(height: 7.h),
              buildMenuButton(text: 'Cart', onPressed: () => print("Pressed cart"), context: context),
              const Divider(thickness: 0),
              buildMenuButton(text: 'Favorites list', onPressed: () => print("Pressed favorites"), context: context),
              SizedBox(height: 7.h),
              buildMenuButton(
                text: userState.businessId != null ? "My business" : "Create business",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => userState.businessId != null ? BusinessPage() : CreateBusiness(),
                    ),
                  );
                },
                context: context,
              ),
              if (userState.isSystemAdmin) ...[
                const Divider(thickness: 0),
                buildMenuButton(text: 'Admin controls', onPressed: () => print("Pressed admin"), context: context),
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
}
