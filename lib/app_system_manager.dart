import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/repo/cart_repository.dart';

class AppSystemManager extends StatefulWidget {
  final Widget child;

  const AppSystemManager({Key? key, required this.child}) : super(key: key);

  @override
  _AppSystemManagerState createState() => _AppSystemManagerState();
}

class _AppSystemManagerState extends State<AppSystemManager> with WidgetsBindingObserver {
  late final CartBloc _bloc;
  final CartRepository _cartRepository = CartRepository();

  @override
  void initState() {
    super.initState();
    print("OBSERVE");
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<CartBloc>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        print('inactive');
        CartState cartState = _bloc.state;
        if (cartState is CartLoaded) {
          _cartRepository.replaceCart(cartItems: cartState.items, updateDatabase: true);
        }
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.resumed:
        _bloc.add(CartSyncEvent());
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
