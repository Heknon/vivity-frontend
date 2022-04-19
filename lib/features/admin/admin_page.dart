import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/admin/admin_unapproved_list.dart';
import 'package:vivity/features/admin/bloc/admin_page_bloc.dart';
import 'package:vivity/features/admin/business_approver.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../business/models/business.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final LoadDialog _loadDialog = LoadDialog();
  late final AdminPageBloc _bloc;
  bool isLoadingOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<AdminPageBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SizedBox(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'Admin Controls',
                        style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  BlocConsumer<AdminPageBloc, AdminPageState>(
                    listener: (context, state) {
                      if (isLoadingOpen) {
                        Navigator.pop(context);
                        isLoadingOpen = false;
                      }
                    },
                    builder: (context, state) {
                      if (state is! AdminPageLoaded) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.unapprovedBusinesses.isEmpty) {
                        return Text(
                          "There are no businesses in need\nof approval",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                        );
                      }

                      return AdminUnapprovedList(
                        businesses: state.unapprovedBusinesses,
                        approvePressed: (business, note) {
                          showDialog(context: context, builder: (ctx) => _loadDialog);
                          isLoadingOpen = true;
                          _bloc.add(AdminPageMoveToApprovedEvent(note: note, businessId: business.businessId.hexString));
                          showSnackBar('Approved ${business.name}', context);
                        },
                        declinePressed: (business, note) {
                          showDialog(context: context, builder: (ctx) => _loadDialog);
                          isLoadingOpen = true;
                          _bloc.add(AdminPageMoveToUnapprovedEvent(note: note, businessId: business.businessId.hexString));
                          showSnackBar('Declined request and sent note to owner!', context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
