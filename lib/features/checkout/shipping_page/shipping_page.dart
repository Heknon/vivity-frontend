import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/address/service/address_service.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/checkout/checkout_progress.dart';
import 'package:vivity/features/checkout/payment_page/payment_page.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/checkout/ui_checkout_helper.dart';
import 'package:vivity/features/user/repo/user_repository.dart';
import 'package:vivity/helpers/ui_helpers.dart';
import 'package:vivity/models/shipping_method.dart';
import '../../address/address.dart' as address_widget;

import '../../../widgets/appbar/appbar.dart';

class ShippingPage extends StatefulWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  final AddressService _addressService = AddressService();
  final UserRepository _userRepository = UserRepository();
  final LoadDialog _loadDialog = LoadDialog();
  bool _loadDialogOpen = false;

  int? selectedAddress;

  @override
  Widget build(BuildContext context) {
    // TODO: Add switch between business pickup and user to house shipping
    // TODO: Address creation menu

    return BasePage(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context, "Checkout"),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<ShippingBloc, ShippingState>(
          builder: (context, state) {
            if (state is! ShippingDeliveryLoaded) {
              return const CircularProgressIndicator();
            }

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: CheckoutProgress(step: 1),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: state.addresses.length > 1 ? 30.h : (state.addresses.length * 17).h,
                  child: buildShippingAddressList(
                    state.addresses,
                    context,
                    highlightIndex: selectedAddress,
                    canDelete: true,
                    onDeleteTap: (index) async {
                      showDialog(context: context, builder: (ctx) => _loadDialog).whenComplete(() => _loadDialogOpen = false);
                      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                        setState(() {
                          selectedAddress = null;
                        });
                      });
                      _loadDialogOpen = true;
                      var snapshot = await _addressService.removeAddress(index: index);
                      if (_loadDialogOpen) {
                        Navigator.pop(context);
                        _loadDialogOpen = false;
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        Navigator.pop(context);
                      }
                      List<Address> data = snapshot.data!;
                      _userRepository.replaceRepositoryUserAddresses(addresses: data);
                      context.read<ShippingBloc>().add(ShippingReplaceAddressesEvent(data));
                    },
                    onTap: (i) => state.confirmationStageState.shippingMethod == ShippingMethod.delivery
                        ? setState(() {
                          selectedAddress = selectedAddress == i ? null : i;
                          print(selectedAddress);
                        })
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                if (state.confirmationStageState.shippingMethod != ShippingMethod.pickup)
                  buildAddressCreationWidget(
                      context: context,
                      onSubmit: (address) async {
                        showDialog(context: context, builder: (ctx) => _loadDialog);
                        _loadDialogOpen = true;
                        var snapshot = await _addressService.addAddress(address: address);
                        if (_loadDialogOpen) {
                          Navigator.pop(context);
                          _loadDialogOpen = false;
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          Navigator.pop(context);
                        }
                        List<Address> data = snapshot.data!;
                        await _userRepository.replaceRepositoryUserAddresses(addresses: data);
                        context.read<ShippingBloc>().add(ShippingReplaceAddressesEvent(data));
                        Navigator.pop(context);
                      }),
                SizedBox(height: 50),
                buildPaymentButton(
                  context,
                  onPressed: () {
                    if (selectedAddress == null) {
                      showSnackBar("Please select an address", context);
                      return;
                    }

                    Navigator.pushNamed(context, '/checkout/payment', arguments: [context.read<ShippingBloc>(), state.addresses[selectedAddress!]]);
                  },
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
