import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/item/classic_item.dart';
import 'package:vivity/features/item/ui_item_helper.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (ctx, state) {
          if (state is! UserLoggedInState) return const Text("Can't see this page without being logged in.\nHow are you even here?");

          Size gridSize = Size(100.w, 70.h);
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
              state.likedItems.isNotEmpty
                  ? SizedBox.fromSize(
                      size: gridSize, child: buildItemContentGrid(state.likedItems, gridSize, ScrollController(), itemHeightMultiplier: 0.55))
                  : Center(
                      child: Text(
                        'Start by adding an item to your favorites',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3?.copyWith(fontSize: 20.sp),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
