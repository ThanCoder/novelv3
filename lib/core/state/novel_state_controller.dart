import 'dart:async';

import 'package:novel_v3/core/extensions/novel_extensions.dart';
import 'package:novel_v3/core/state/novel_state.dart';
import 'package:novel_v3/core/state/novel_state_event.dart';
import 'package:novel_v3/core/utils/novel_source_scanner.dart';

class NovelStateController {
  static NovelStateController instance = NovelStateController._();
  NovelStateController._();
  factory NovelStateController() => instance;

  final _controller = StreamController<NovelState>.broadcast();
  Stream<NovelState> get stream => _controller.stream;

  NovelState _state = NovelState.empty();
  NovelState get state => _state;

  void dispatch(NovelStateEvent event) {
    if (event is NovelSourceLoading) {
      _state = _state.copyWith(isLoading: true, error: '', novelList: []);
      _notify();
    } else if (event is NovelSourceLoaded) {
      _state = _state.copyWith(
        isLoading: false,
        novelList: event.list,
        error: '',
      );
      _notify();
    } else if (event is NovelSourceError) {
      _state = _state.copyWith(isLoading: false, error: event.error);
      _notify();
    }
  }

  void initSource() async {
    try {
      dispatch(NovelSourceLoading());

      final res = await getNovelsFromSource();
      res.sortDate();
      dispatch(NovelSourceLoaded(res));
    } catch (e) {
      dispatch(NovelSourceError(e.toString()));
    }
  }

  void _notify() {
    _controller.add(_state);
  }

  void dispose() {
    _controller.close();
  }
}
