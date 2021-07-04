import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as Storage;
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:webant_gallery_part_two/data/repositories/http_photo_gateway.dart';
import 'package:webant_gallery_part_two/domain/models/base_model/base_model.dart';
import 'package:webant_gallery_part_two/domain/models/user/user_model.dart';
import 'package:webant_gallery_part_two/domain/repositories/oauth_gateway.dart';
import 'package:webant_gallery_part_two/domain/repositories/photo_gateway.dart';
import 'package:webant_gallery_part_two/domain/repositories/user_gateway.dart';
import 'package:webant_gallery_part_two/presentation/resources/app_strings.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/gallery/main/new_or_popular_photos.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc<T> extends Bloc<UserEvent, UserState> {
  UserBloc(this._oauthGateway, this._userGateway)
      : super(UserInitial());
  final _storage = Storage.FlutterSecureStorage();
  final UserGateway _userGateway;
  final OauthGateway _oauthGateway;
  PhotoGateway _photoGateway = HttpPhotoGateway(type: typePhoto.SEARCH_BY_USER);
  UserModel _user;
  BaseModel<T> _baseModel;
  bool _isUpdate = false;

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UserFetch) {
      yield* _mapUserFetchToUserData(event);
    }
    if (event is UpdateUser) {
      yield* _mapUpdateUserToUserFetch(event);
    }
    if (event is UpdatePassword) {
      yield* _mapUpdatePasswordToUserFetch(event);
    }
    if (event is LogOut) {
      yield* _mapLogOutToExit(event);
    }
    if (event is UserDelete) {
      _mapUserDeleteToExit(event);
    }
  }

  Stream<UserState> _mapUserFetchToUserData(UserFetch event) async* {
    try {
      yield LoadingUpdate();
      _user = await _oauthGateway.getUser();
      _baseModel =
      await _photoGateway.fetchPhotos(page: 1, queryText: _user.id);
      int countOfPhotos = _baseModel.totalItems;
      yield UserData(user: _user, countOfPhotos: countOfPhotos, isUpdate: _isUpdate);
    } on DioError {
      yield ErrorData();
    }
  }

  Stream<UserState> _mapUpdateUserToUserFetch(UpdateUser event) async* {
    try {
      yield LoadingUpdate();
      await _userGateway.updateUser(event.user);
      _isUpdate = true;
      add(UserFetch());
      _isUpdate = false;
    } on DioError {
      yield ErrorUpdate(AppStrings.error);
    }
  }

  Stream<UserState> _mapUpdatePasswordToUserFetch(UpdatePassword event) async* {
    try {
      yield LoadingUpdate();
      await _userGateway.updatePasswordUser(
          event.user, event.oldPassword, event.newPassword);
      add(UserFetch());
    } on DioError catch (err) {
      _isUpdate = false;
      if (err?.response?.statusCode == 400) {
        yield ErrorUpdate(jsonDecode(err?.response?.data)['detail']);
      } else {
        yield ErrorUpdate(AppStrings.error);
      }
      add(UserFetch());
    }
  }

  Stream<UserState> _mapUserDeleteToExit(UserDelete event) async* {
    yield LoadingUpdate();
    await _storage.deleteAll();
    Hive.box('new').clear();
    Hive.box('popular').clear();
    await _userGateway.deleteUser(event.user);
    yield Exit();
  }

  Stream<UserState> _mapLogOutToExit(LogOut event) async* {
    yield LoadingUpdate();
    await _storage.deleteAll();
    Hive.box('new').clear();
    Hive.box('popular').clear();
    yield Exit();
  }
}
