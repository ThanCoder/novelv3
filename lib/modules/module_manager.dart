import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

abstract class ModuleApp<P, R> {
  String get id;

  Future<R?> go(BuildContext context, P params);
}

class ModuleManager {
  static ModuleManager instance = ModuleManager._();
  ModuleManager._();
  factory ModuleManager() => instance;

  // Type ရော ID နဲ့ပါ အလွယ်တကူ ရှာနိုင်အောင် Map နှစ်ခု သုံးမယ်
  final Map<Type, ModuleApp> _appsByType = {};
  final Map<String, ModuleApp> _appsById = {};

  void register(ModuleApp app) {
    final typeKey = app.runtimeType;
    final idKey = app.id;

    // ၁။ Type တူနေခြင်း ရှိ/မရှိ စစ်ဆေးခြင်း
    if (_appsByType.containsKey(typeKey)) {
      throw Exception(
        'Registration Failed: Module Type `$typeKey` is already registered! Duplicates are not allowed.',
      );
    }

    // ၂။ ID တူနေခြင်း ရှိ/မရှိ စစ်ဆေးခြင်း
    if (_appsById.containsKey(idKey)) {
      throw Exception(
        'Registration Failed: Module ID `$idKey` is already taken! Each module must have a unique ID.',
      );
    }

    // အားလုံး အဆင်ပြေမှ သိမ်းမယ်
    _appsByType[typeKey] = app;
    _appsById[idKey] = app;
  }

  Future<R?> open<T extends ModuleApp<P, R>, P, R>(
    BuildContext context,
    P params,
  ) async {
    final app = _appsByType[T];
    if (app == null) {
      // print('Module: `$T` No Found!');
      showTMessageDialogError(context, 'Module: `$T` No Found!');
      return null;
    }
    return await (app as T).go(context, params);
  }

  // String ID အသုံးပြုပြီး ခေါ်ယူခြင်း
  Future<R?> openId<P, R>(BuildContext context, String appId, P params) async {
    final app = _appsById[appId];
    if (app == null) {
      showTMessageDialogError(context, 'Module ID: `$appId` Not Found!');
      return null;
    }

    // ⚠️ စိတ်ချရအောင် Type ကို အရင်စစ်ဆေးမယ် (Crash မဖြစ်အောင်)
    if (app is! ModuleApp<P, R>) {
      showTMessageDialogError(
        context,
        'Module Type Mismatch! Expected ModuleApp<$P, $R> but got ${app.runtimeType}',
      );
      return null;
    }

    return await app.go(context, params);
  }
}
