import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'admin_page_event.dart';
part 'admin_page_state.dart';

class AdminPageBloc extends Bloc<AdminPageEvent, AdminPageState> {
  AdminPageBloc() : super(AdminPageInitial()) {
    on<AdminPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
