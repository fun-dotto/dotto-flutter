import 'package:dotto/data/api_client.dart';
import 'package:dotto/domain/announcement.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => AnnouncementRepositoryImpl(ref),
);

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();
}

final class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this.ref);

  final Ref ref;

  @override
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final api = ref.read(apiClientProvider).getAnnouncementsApi();
      final response = await api.announcementsList();
      if (response.statusCode != 200) {
        throw Exception('Failed to get announcements');
      }
      final data = response.data;
      if (data == null) {
        throw Exception('Failed to get announcements');
      }
      return data
          .map(
            (e) => Announcement(
              id: e.id,
              title: e.title,
              date: e.date,
              url: e.url,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
