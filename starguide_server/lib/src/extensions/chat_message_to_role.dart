import 'package:starguide_server/src/generated/protocol.dart';

extension ChatMessageToRole on ChatMessageType {
  String get aiRole {
    switch (this) {
      case ChatMessageType.model:
        return 'model';
      case ChatMessageType.user:
        return 'user';
    }
  }
}
