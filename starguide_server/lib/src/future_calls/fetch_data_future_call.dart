import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';

class FetchDataFutureCall extends FutureCall {
  @override
  Future<void> invoke(Session session, SerializableModel? object) async {
    print('FETCH DATA FUTURE CALL');
    final fetcher = setupDataFetcher();
    await fetcher.fetchAndOrganize(session);
  }
}
