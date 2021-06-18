import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as Storage;
import 'package:meta/meta.dart';
import 'package:webant_gallery_part_two/domain/models/registration/user_model.dart';
import 'package:webant_gallery_part_two/domain/repositories/user_gateway.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this.userGateway) : super(UserInitial());
  final _storage = Storage.FlutterSecureStorage();
  final UserGateway userGateway;

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is LogOut) {
      await _storage.deleteAll();
      yield Exit();
    }
    if (event is UserFetch){

    }
    if (event is UpdateUser) {
      try{
        yield LoadingUpdate();
        await userGateway.updateUser(event.user);
        //yield;
      } on DioError{
        yield ErrorUpdate();
      }
    }
  }
}
