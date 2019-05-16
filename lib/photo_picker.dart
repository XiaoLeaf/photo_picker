import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotoPicker {
  static MethodChannel _channel =
       MethodChannel('photo_picker')
      ..setMethodCallHandler(pickPhotoHandler);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> pickPhotoHandler(MethodCall methodCall) {
    if (methodCall.method == 'photoPickerResponse') {
      List resultList = methodCall.arguments['result'];
      return Future.value(resultList);
    }
  }

  static Future<dynamic> pickPhoto ({
    @required int maxCount
  }) async {
   final result = await _channel.invokeMethod('pickPhoto', maxCount);
   return result;
  }

}
