import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/admin/business_approver.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/admin_service.dart';

import '../../models/business.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Future<List<Business>>? unapprovedBusinesses;
  Stream<MapEntry<String, Future<Uint8List>>>? businessIdImageMapEntryStream;
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

    unapprovedBusinesses ??= getUnapprovedBusinesses(state.token);

    return BasePage(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
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
                  businessIdImageMapEntryStream ??= getOwnerIdImagesFromBusinessIds(businesses.map((e) => e.businessId.hexString).toList());
                  return StreamBuilder<MapEntry<String, Future<Uint8List>>>(
                    stream: businessIdImageMapEntryStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        businessIdImageMap[snapshot.data!.key] = snapshot.data!.value;
                      }

                      if (businessIdImageMap.isEmpty) {
                        return Text(
                          "There are no businesses in need\nof approval",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 18.sp),
                        );
                      }

                      List<Business> buildableBusinesses =
                          businesses.where((element) => businessIdImageMap.containsKey(element.businessId.hexString)).toList();

                      return SizedBox(
                        height: 100.h - (Scaffold.of(context).appBarMaxHeight ?? 100),
                        child: ListView.separated(
                          itemCount: buildableBusinesses.length,
                          itemBuilder: (ctx, i) {
                            Business business = buildableBusinesses[i];
                            return FutureBuilder<Uint8List>(
                              future: businessIdImageMap[business.businessId.hexString],
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }

                                return BusinessApprover(
                                  business: business,
                                  ownerIdImageBytes: snapshot.data!,
                                  approvePressed: (note) async {
                                    Business updated = await updateBusinessApproval(state.token, business.businessId.hexString, true, note);

                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved ${updated.name}')));
                                    setState(() {
                                      if (updated.approved) {
                                        buildableBusinesses.removeWhere((element) => element.businessId == updated.businessId);
                                        unapprovedBusinesses = getUnapprovedBusinesses(state.token);
                                      }
                                    });
                                  },
                                  declinePressed: (note) async {
                                    Business updated = await updateBusinessApproval(state.token, business.businessId.hexString, false, note);
                                    if (updated.approved) {
                                      buildableBusinesses.removeWhere((element) => element.businessId == updated.businessId);
                                    }

                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Declined request and sent note to owner!')));
                                  },
                                );
                              },
                            );
                          },
                          separatorBuilder: (ctx, i) {
                            return SizedBox(
                              child: Divider(thickness: 1),
                              width: 90.w,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}
