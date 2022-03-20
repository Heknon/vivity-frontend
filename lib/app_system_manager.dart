import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/cart/cart_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';

import 'features/cart/cart_bloc/cart_bloc.dart';

class AppSystemManager extends StatefulWidget {
  final Widget child;

  const AppSystemManager({Key? key, required this.child}) : super(key: key);

  @override
  _AppSystemManagerState createState() => _AppSystemManagerState();
}

class _AppSystemManagerState extends State<AppSystemManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print("OBSERVE");
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: Save cart to database here
    switch (state) {
      case AppLifecycleState.inactive:
        print('inactive');
        saveCart(context);
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.resumed:
        print('resumed');
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
