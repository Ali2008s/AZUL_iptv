import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/api/api.dart';
import '../../../../repository/models/category.dart';

part 'series_caty_event.dart';
part 'series_caty_state.dart';

class SeriesCatyBloc extends Bloc<SeriesCatyEvent, SeriesCatyState> {
  final IpTvApi api;
  SeriesCatyBloc(this.api) : super(SeriesCatyInitial()) {
    on<GetSeriesCategories>((event, emit) async {
      emit(SeriesCatyLoading());
      final result = await api.getCategories("get_series_categories");
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
      emit(SeriesCatySuccess(filteredResult));
    });
  }
}
