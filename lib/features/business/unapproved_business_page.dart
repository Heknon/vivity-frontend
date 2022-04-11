import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/business/business_page.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/widgets/simple_card.dart';

import '../../helpers/ui_helpers.dart';

class UnapprovedBusinessPage extends StatefulWidget {
  const UnapprovedBusinessPage({Key? key}) : super(key: key);

  @override
  State<UnapprovedBusinessPage> createState() => _UnapprovedBusinessPageState();
}

class _UnapprovedBusinessPageState extends State<UnapprovedBusinessPage> {
  late bool showNote;
  late bool initialized;

  @override
  void initState() {
    super.initState();

    showNote = true;
    initialized = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      context.read<UserBloc>().add(UpdateBusinessDataEvent());
      initialized = true;
    }

    return BasePage(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is! BusinessUserLoggedInState) {
            return const Text('One of two things: You are either not logged in or don\'t own a business.\nEither way, how are you here 🤨');
          }

          if (state.business.approved) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => BusinessPage()));
            return CircularProgressIndicator();
          }

          return defaultGradientBackground(
            child: SizedBox(
              height: 100.w - Scaffold.of(context).appBarMaxHeight!,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        state.business.name,
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  Text(
                    "Seems like your business hasn't been approved yet\n\nFeel free to edit some business settings",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                  ),
                  Spacer(),
                  AnimatedOpacity(
                    opacity: showNote ? 1 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: buildAdminNote(context, state.business.adminNote),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAdminNote(BuildContext context, String note) {
    return SimpleCard(
      elevation: 7,
      onTap: () => setState(() {
        showNote = !showNote;
      }),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Admin note",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
            ),
            Text(
              note,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 16.sp),
            )
          ],
        ),
      ),
    );
  }
}
