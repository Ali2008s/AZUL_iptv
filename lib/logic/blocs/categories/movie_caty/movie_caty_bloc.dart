import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/api/api.dart';
import '../../../../repository/models/category.dart';

part 'movie_caty_event.dart';
part 'movie_caty_state.dart';

class MovieCatyBloc extends Bloc<MovieCatyEvent, MovieCatyState> {
  final IpTvApi api;

  MovieCatyBloc(this.api) : super(MovieCatyInitial()) {
    on<GetMovieCategories>((event, emit) async {
      emit(MovieCatyLoading());
      final result = await api.getCategories("get_vod_categories");
      final isAdultFilterEnabled = LocaleApi.getAdultFilter();
      final filteredResult = result.where((caty) {
        if (!isAdultFilterEnabled) return true;
        final name = (caty.categoryName ?? "").toLowerCase();
        return !name.contains('18+') && 
               !name.contains('+18') && 
               !name.contains('adult') &&
               !name.contains('xxx') &&
               !name.contains('للكبار');
      }).toList();
      emit(MovieCatySuccess(filteredResult));
    });
  }
}
