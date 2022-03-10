import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_validator/form_validator.dart';
import 'package:sizer/sizer.dart';

import '../../config/themes/themes_config.dart';
import '../../widgets/appbar/appbar.dart';
import '../cart/cart_bloc/cart_bloc.dart';
import 'checkout_progress.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool deletePressed = false;

  bool saveCardInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: VivityAppBar(
        bottom: buildTitle(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: CheckoutProgress(step: 2),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Payment methods',
                    style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 15.sp, color: fillerColor, fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                      overlayColor: MaterialStateProperty.all(Colors.grey),
                      fixedSize: MaterialStateProperty.all(Size(95.w, 15.sp * 3))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/credit_card.svg',
                        color: Colors.white,
                        height: 16.sp,
                      ),
                      Text(
                        'Pay With A Credit Card',
                        style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Colors.white),
                      )
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  'Choose another payment type',
                  style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, color: fillerColor, fontWeight: FontWeight.normal),
                ),
              ),
              SizedBox(height: 15),
              GestureDetector(
                onTap: () => print("Handle PayPal stuff"),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      border: Border.all(color: fillerColor),
                    ),
                    child: SizedBox(
                      height: 50,
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/icons/paypal_logo.svg"),
                          Text(
                            'Pay',
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 12.sp, color: fillerColor, fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Card number',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 13.sp,
                            color: fillerColor,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: cardNumberController,
                      validator: ValidationBuilder()
                          .minLength(16)
                          .maxLength(16)
                          .add((String? value) => value == null
                              ? "Must be a number"
                              : double.tryParse(value) != null
                                  ? null
                                  : "Must be a number")
                          .build(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: fillerColor,
                        fontWeight: FontWeight.normal,
                      ),
                      obscureText: true,
                      obscuringCharacter: '*',
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(borderSide: BorderSide(color: fillerColor)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fillerColor, width: 0.7)),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiry date',
                                style: Theme.of(context).textTheme.headline4!.copyWith(
                                      fontSize: 13.sp,
                                      color: fillerColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              SizedBox(height: 5),
                              RawKeyboardListener(
                                onKey: (event) {
                                  deletePressed = event.logicalKey == LogicalKeyboardKey.backspace;
                                },
                                focusNode: FocusNode(),
                                child: TextFormField(
                                  controller: dateController,
                                  validator: ValidationBuilder().add((value) {
                                    if (value == null || value.length != 5) return 'Follow format: MM/YY';
                                    List<String> dates = value.split('/');
                                    if (double.tryParse(dates[0]) == null || double.tryParse(dates[1]) == null) {
                                      return 'Follow format: MM/YY';
                                    }

                                    return null;
                                  }).build(),
                                  onChanged: (value) {
                                    int cursorPosition = dateController.selection.base.offset;

                                    String rawText = dateController.text;
                                    if (rawText.isEmpty) return;

                                    String text = rawText.substring(0, max(0, cursorPosition - 1)) +
                                        rawText.substring(cursorPosition, dateController.text.length);

                                    String enteredCharacter = rawText[max(0, cursorPosition - 1)];
                                    bool slashInserted = text.length > 2 ? text[2] == '/' : false;
                                    bool pressedBackspace = deletePressed;
                                    deletePressed = false;

                                    if (pressedBackspace) {
                                      print('entered delete');
                                      if (cursorPosition == 4) {
                                        dateController.text += '0';
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      } else if (cursorPosition == 3) {
                                        dateController.text =
                                            rawText.substring(0, cursorPosition) + '0' + rawText.substring(cursorPosition, rawText.length);
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      } else if (cursorPosition == 2) {
                                        dateController.text =
                                            rawText.substring(0, cursorPosition - 1) + '0/' + rawText.substring(cursorPosition, rawText.length);
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      } else if (cursorPosition == 1) {
                                        dateController.text =
                                            rawText.substring(0, cursorPosition) + '0' + rawText.substring(cursorPosition, rawText.length);
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      } else if (cursorPosition == 0) {
                                        dateController.text =
                                            rawText.substring(0, cursorPosition) + '0' + rawText.substring(cursorPosition, rawText.length);
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      }

                                      if (dateController.text == '00/00' || dateController.text == '00/') {
                                        dateController.text = '';
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
                                      }
                                      return;
                                    }

                                    print("Cursor: $cursorPosition; Char: $enteredCharacter; Text: $text}");

                                    if (int.tryParse(enteredCharacter) == null || (rawText.length > 5 && cursorPosition > 5)) {
                                      dateController.text = text;
                                      dateController.selection = TextSelection.fromPosition(TextPosition(offset: max(0, cursorPosition - 1)));
                                      return;
                                    }

                                    int numEntered = int.parse(enteredCharacter);

                                    if (cursorPosition == 1) {
                                      if (numEntered >= 2 && numEntered <= 9) {
                                        String modifiedText = slashInserted
                                            ? '0$enteredCharacter' + text.substring(min(text.length, 2), min(text.length, 6))
                                            : '0$enteredCharacter/' + text.substring(min(text.length, 4), min(text.length, 6));

                                        dateController.text = modifiedText;
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition + 2));
                                      } else if (slashInserted) {
                                        String modifiedText = enteredCharacter + rawText.substring(min(rawText.length, 2), min(rawText.length, 6));

                                        dateController.text = modifiedText;
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      }
                                    } else if (cursorPosition == 2) {
                                      dateController.text = slashInserted
                                          ? text.substring(0, 1) + enteredCharacter + text.substring(min(text.length, 2), min(text.length, 6))
                                          : text.substring(0, 1) + '$enteredCharacter/' + text.substring(min(text.length, 2), min(text.length, 6));
                                      dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition + 1));
                                    } else if (cursorPosition == 3) {
                                      dateController.text = text;
                                      dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                    } else if (cursorPosition == 4) {
                                      if (numEntered >= 4 && numEntered <= 9) {
                                        String modifiedText =  text.substring(0, 3) + '0$enteredCharacter';

                                        dateController.text = modifiedText;
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition + 1));
                                      } else {
                                        String modifiedText =  text.substring(0, 3) + enteredCharacter + text.substring(min(text.length, 4), min(text.length, 6));

                                        dateController.text = modifiedText;
                                        dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                      }
                                    } else if (cursorPosition == 5) {
                                      String modifiedText =  text.substring(0, 4) + enteredCharacter;

                                      dateController.text = modifiedText;
                                      dateController.selection = TextSelection.fromPosition(TextPosition(offset: cursorPosition));
                                    }
                                  },
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: fillerColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: "MM/YY",
                                    hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                                    border: OutlineInputBorder(borderSide: BorderSide(color: fillerColor)),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fillerColor, width: 0.7)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CVV',
                                style: Theme.of(context).textTheme.headline4!.copyWith(
                                      fontSize: 13.sp,
                                      color: fillerColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              SizedBox(height: 5),
                              TextFormField(
                                controller: cvvController,
                                validator: ValidationBuilder()
                                    .minLength(3)
                                    .maxLength(3)
                                    .add((String? value) => value == null
                                        ? "Must be a number"
                                        : double.tryParse(value) != null
                                            ? null
                                            : "Must be a number")
                                    .build(),
                                style: TextStyle(fontSize: 12.sp, color: Colors.black),
                                obscureText: true,
                                obscuringCharacter: '*',
                                onChanged: (String? value) {
                                  if (value == null) return;
                                  if (value.length > 3) dateController.text = dateController.text.substring(0, dateController.text.length - 1);
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(10),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: fillerColor)),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fillerColor, width: 0.7)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Card holder name',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            fontSize: 13.sp,
                            color: fillerColor,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    TextFormField(
                      controller: nameController,
                      validator: ValidationBuilder().minLength(1).maxLength(100).build(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: fillerColor,
                        fontWeight: FontWeight.normal,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: fillerColor,
                        )),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: fillerColor, width: 0.7)),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Save card information',
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, color: fillerColor, fontWeight: FontWeight.normal),
                        ),
                        Switch(
                          value: saveCardInfo,
                          activeColor: Colors.white,
                          activeTrackColor: fillerColor,
                          onChanged: (val) => setState(() {
                            // TODO: Move to checkout state BLOC once created.
                            saveCardInfo = val;
                          }),
                        )
                      ],
                    ),
                    SizedBox(height: 25),
                    Divider(color: Color(0xff707070), thickness: 1.2),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total -',
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, color: fillerColor, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          '\$' + BlocProvider.of<CartBloc>(context).state.priceTotal.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 13.sp, color: fillerColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryVariant),
                            overlayColor: MaterialStateProperty.all(Colors.grey),
                            fixedSize: MaterialStateProperty.all(Size(90.w, 15.sp * 3))),
                        child: Text(
                          'Pay Now',
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.sp, fontWeight: FontWeight.normal, color: Colors.white),
                        ),
                        onPressed: () {
                          if (!(_formKey.currentState?.validate() ?? true)) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out correctly.')));
                            return;
                          }
                          _formKey.currentState?.save();
                          handleSuccessfulSubmission(
                            cardNumberController.text,
                            dateController.text.split('/')[0],
                            dateController.text.split('/')[1],
                            cvvController.text,
                            nameController.text,
                            saveCardInfo,
                            BlocProvider.of<CartBloc>(context).state.priceTotal,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Handling transaction!')));

                          // TODO: Add to user BLOC this order history
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSize buildTitle(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            "Checkout",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headline4?.copyWith(color: Colors.white, fontSize: 24.sp),
          ),
        ),
      ),
    );
  }

  void handleSuccessfulSubmission(
    String cardNumber,
    String expirationMonth,
    String expirationYear,
    String cvv,
    String holderName,
    bool saveInfo,
    double total,
  ) {
    print(
        "Handling: (cardNumber: $cardNumber, expirationMonth: $expirationMonth, expirationYear: $expirationYear, cvv: $cvv, holderName: $holderName, saveInfo: $saveInfo, total: $total)");
  }
}
