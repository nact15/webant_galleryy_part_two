import 'dart:async';
import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:webant_gallery_part_two/data/repositories/firesrore_repository.dart';
import 'package:webant_gallery_part_two/data/repositories/http_user_gateway.dart';
import 'package:webant_gallery_part_two/domain/models/base_model/base_model.dart';
import 'package:webant_gallery_part_two/domain/models/photos_model/photo_model.dart';
import 'package:webant_gallery_part_two/domain/repositories/firestore_repository.dart';
import 'package:webant_gallery_part_two/domain/repositories/photo_gateway.dart';

part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc<T> extends Bloc<GalleryEvent, GalleryState> {
  GalleryBloc(this._photoGateway, this._httpUserGateway) : super(GalleryInitial());
  final PhotoGateway<T> _photoGateway;
  final HttpUserGateway _httpUserGateway;
  Box _photosBox;
  int _page = 1;
  BaseModel<T> _baseModel;
  FirestoreRepository _firestoreRepository = FirebaseFirestoreRepository();

@override
  Stream<GalleryState> mapEventToState(GalleryEvent event) async* {
    _photosBox = Hive.box(_photoGateway.enumToString());
    if (event is GalleryFetch) {
      yield* _mapGalleryFetch(event);
    }
    if (event is GalleryRefresh) {
      yield* _mapGalleryRefresh(event);
    }
    if (event is GalleryLoading){
      yield GalleryLoaded();
    }
  }

  Stream<GalleryState> _mapGalleryFetch(GalleryFetch event) async* {
    try {
      if (_photosBox.isEmpty) {
        yield GalleryLoaded();
      }
      _baseModel = await _photoGateway.fetchPhotos(page: _page);
      if (_photosBox.length < _baseModel.totalItems) {
        _addToBox(); //add photos to box
        _page++;
        yield GalleryData(
            isLoading: false, isLastPage: false, photosBox: _photosBox);
      }else {
        yield GalleryData(
          isLastPage: true,
          isLoading: false,
          photosBox: _photosBox,
        );
     }
    } on DioError {
      yield* _internetError();
    }
  }

  Stream<GalleryState> _mapGalleryRefresh(GalleryRefresh event) async* {
    try {
      _photosBox.clear();
      _page = 1;
      _baseModel = await _photoGateway.fetchPhotos(page: _page);
      _addToBox(); //add items to box after refresh
      _page++;
      yield GalleryData(
        isLoading: false,
        isLastPage: false,
        photosBox: _photosBox,
      );
    } on DioError {
      yield* _internetError();
    }
  }

  Stream<GalleryState> _internetError() async* {
    if (_photosBox.isNotEmpty) {
      yield GalleryData(
        photosBox: _photosBox,
        isLastPage: true,
        isLoading: false,
      );
    } else
      yield GalleryInternetLost();
  }

  void _addToBox()  {
    List<PhotoModel> basePhotoModel = _baseModel.data as List<PhotoModel>;
    List<PhotoModel> boxPhotoModel =
        _photosBox.values.toList().cast<PhotoModel>();
    basePhotoModel.forEach((element) async {
      if (element.user != null){
        String userName = await _httpUserGateway.getUserName(element.user);
        element = element.copyWith(user: userName);
      }
      if (boxPhotoModel.firstWhere(
            (elementB) => element.id == elementB.id,
            orElse: () => null,
          ) ==
          null) {
        _photosBox.add(element);
      }
    });
  }
}
