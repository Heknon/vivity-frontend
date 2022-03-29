import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/helpers/conversion_helper.dart';

class Address extends StatelessWidget {
  final String name;
  final String country;
  final String city;
  final String street;
  final String extraInfo;
  final String province;
  final String zipCode;
  final String phone;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;
  final Color? color;

  const Address({
    Key? key,
    required this.name,
    required this.country,
    required this.city,
    required this.street,
    required this.province,
    required this.extraInfo,
    required this.zipCode,
    required this.phone,
    this.onTap,
    this.onDeleteTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
      child: Card(
        elevation: 2,
        color: color,
        child: onTap != null ? InkWell(
          child: buildCardBody(context),
          onTap: onTap,
        ) : buildCardBody(context),
      ),
    );
  }

  Widget buildCardBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 13.sp, fontWeight: FontWeight.normal)),
              Material(
                elevation: 5,
                child: SvgPicture.asset(
                  'icons/flags/svg/${country.toLowerCase()}.svg',
                  package: 'country_icons',
                  width: 25,
                ),
              ),
            ],
          ),
          Text('$street $extraInfo', style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal)),
          Text('$province, $city $zipCode', style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phone: $phone', style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal)),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: BoxConstraints(),
                onPressed: onDeleteTap,
                icon: Icon(
                  Icons.delete_forever,
                  color: primaryComplementaryColor,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
