import 'package:serverpod/serverpod.dart';

class DefaultPageWidget extends Widget {
  DefaultPageWidget() : super(name: 'index') {
    values = {
      'served': DateTime.now(),
      'runmode': Serverpod.instance.runMode,
    };
  }
}
