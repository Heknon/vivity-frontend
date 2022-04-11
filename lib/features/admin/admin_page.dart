import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/admin/business_approver.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/admin_service.dart';

import '../business/models/business.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<List<Business>>? unapprovedBusinesses;
  Future<Map<String, Uint8List>>? businessIdImageMapFuture;
  late final Map<String, Future<Uint8List>> businessIdImageMap;

  @override
  void initState() {
    super.initState();
    businessIdImageMap = {};
  }

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! UserLoggedInState || !state.isSystemAdmin) return const Text('Seriously... How u here?');

    unapprovedBusinesses ??= getUnapprovedBusinesses(state.accessToken);

    return BasePage(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(builder: (context, constraints) {
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
                FutureBuilder<List<Business>>(
                  future: unapprovedBusinesses,
                  builder: (ctx, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    List<Business> businesses = snapshot.data!;

                    businessIdImageMapFuture ??= getOwnerIdImagesFromBusinessIds(businesses.map((e) => e.businessId.hexString).toList());
                    return FutureBuilder<Map<String, Uint8List>>(
                      future: businessIdImageMapFuture,
                      builder: (context, snapshot) {
                        List<Business> buildableBusinesses =
                            businesses.where((element) => snapshot.data?.containsKey(element.businessId.hexString) ?? false).toList();

                        if (!snapshot.hasData || buildableBusinesses.isEmpty) {
                          return Text(
                            "There are no businesses in need\nof approval",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                          );
                        }

                        return Column(
                          children: List.generate(
                            max(0, buildableBusinesses.length * 2 - 1),
                            (i) {
                              if (i.isOdd) return Divider();
                              Business business = buildableBusinesses[i ~/ 2];
                              return BusinessApprover(
                                business: business,
                                ownerIdImageBytes: snapshot.data![business.businessId.hexString]!,
                                approvePressed: (note) async {
                                  Business updated = await updateBusinessApproval(state.accessToken, business.businessId.hexString, true, note);

                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved ${updated.name}')));
                                  setState(() {
                                    if (updated.approved) {
                                      buildableBusinesses.removeWhere((element) => element.businessId == updated.businessId);
                                      unapprovedBusinesses = getUnapprovedBusinesses(state.accessToken);
                                    }
                                  });
                                },
                                declinePressed: (note) async {
                                  Business updated = await updateBusinessApproval(state.accessToken, business.businessId.hexString, false, note);
                                  if (updated.approved) {
                                    buildableBusinesses.removeWhere((element) => element.businessId == updated.businessId);
                                  }

                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Declined request and sent note to owner!')));
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
