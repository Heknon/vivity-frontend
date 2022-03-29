import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/item/classic_item.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (ctx, state) {
          if (state is! UserLoggedInState) return const Text("Can't see this page without being logged in.\nHow are you even here?");

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.headline4?.copyWith(fontSize: 24.sp),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SingleChildScrollView(
                child: SizedBox(
                  height: 90.h,
                  width: 90.w,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    children: state.likedItems.map((e) => ClassicItem(item: e)).toList(),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
