import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/drawer/bloc/drawer_bloc.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';

class BlocWrappedVivityDrawer extends StatelessWidget {
  const BlocWrappedVivityDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => DrawerBloc()..add(DrawerLoadEvent()),
      child: const VivityDrawer(),
    );
  }
}
