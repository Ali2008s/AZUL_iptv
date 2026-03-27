import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../repository/api/api.dart';
import '../../../../repository/models/category.dart';

part 'live_caty_event.dart';
part 'live_caty_state.dart';

class LiveCatyBloc extends Bloc<LiveCatyEvent, LiveCatyState> {
  final IpTvApi api;

  LiveCatyBloc(this.api) : super(LiveCatyInitial()) {
    on<GetLiveCategories>((event, emit) async {
      emit(LiveCatyLoading());
      final result = await api.getCategories("get_live_categories");
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
      emit(LiveCatySuccess(filteredResult));
    });
  }
}
