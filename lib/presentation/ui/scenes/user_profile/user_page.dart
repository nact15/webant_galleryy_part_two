import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webant_gallery_part_two/domain/models/photos_model/photo_model.dart';
import 'package:webant_gallery_part_two/domain/models/user/user_model.dart';
import 'package:webant_gallery_part_two/domain/usecases/date_formatter.dart';
import 'package:webant_gallery_part_two/presentation/resources/app_colors.dart';
import 'package:webant_gallery_part_two/presentation/resources/app_strings.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/gallery/main/new_or_popular_photos.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/gallery/photos_pages/gallery_grid.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/gallery/photos_pages/single_photo.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/user_profile/user_bloc/user_bloc.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/user_profile/user_settings.dart';
import 'package:webant_gallery_part_two/presentation/ui/scenes/widgets/loading_circular.dart';

import 'firestore_bloc/firestore_bloc.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  UserModel user;
  List<PhotoModel> photos;
  DateFormatter dateFormatter;
  Completer<void> _reFresh;
  int _viewsCount;

  @override
  void initState() {
    dateFormatter = DateFormatter();
    _reFresh = Completer<void>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.black,
            onPressed: () =>
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (BuildContext context) => UserSettings()),
                ),
            alignment: Alignment.centerRight,
          ),
        ],
        elevation: 1,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              setState(() {
                _reFresh?.complete();
                _reFresh = Completer();
              });
            },
          ),
        ],
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is LoadingUpdate) {
              return LoadingCircular();
            }
            if (state is ErrorData) {
              return RefreshIndicator(
                color: AppColors.mainColorAccent,
                backgroundColor: AppColors.colorWhite,
                strokeWidth: 2.0,
                onRefresh: () async {
                  context.read<UserBloc>().add(UserFetch());
                  return _reFresh.future;
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    color: AppColors.colorWhite,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 220, 0, 8),
                            child: Image.asset(AppStrings.imageIntersect),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Sorry!',
                              style: TextStyle(
                                  fontSize: 25,
                                  color: AppColors.mainColorAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            'There is no internet connection.',
                            style: TextStyle(color: AppColors.mainColorAccent),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            if (state is UserData) {
              photos = state.usersPhotos;
              user = state.user;
              return Column(
                children: [
                  RefreshIndicator(
                    color: AppColors.mainColorAccent,
                    backgroundColor: AppColors.colorWhite,
                    strokeWidth: 2.0,
                    onRefresh: () async {
                      context.read<UserBloc>().add(UserFetch());
                      return _reFresh.future;
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 275,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.mainColorAccent,
                                  ),
                                ),
                                child: Center(
                                    child: CircleAvatar(
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 55,
                                        color: AppColors.mainColorAccent,
                                      ),
                                      radius: 50,
                                      backgroundColor: AppColors.colorWhite,
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Center(
                                child: Text(
                                  user.username,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Center(
                                child: Text(
                                  dateFormatter.fromDate(user.birthday),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mainColorAccent),
                                ),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 27, 0, 0),
                              child: Row(
                                children: [
                                  BlocBuilder<FirestoreBloc, FirestoreState>(
                                    builder: (context, fireState) {
                                      if (fireState is CountOfUserViews){
                                        return Text(
                                            'Views: ${fireState.count}');
                                      }
                                      return Text('');
                                    },
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                          'Loaded: ${state.countOfPhotos}')),
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 1.0,
                                      color: AppColors.mainColorAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GalleryGrid(
                      queryText: user.id,
                      type: typeGrid.SEARCH,
                      photos: photos,
                      crossCount: 4,
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  void _toScreenInfo(PhotoModel photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScreenInfo(photo: photo),
      ),
    );
  }
}
