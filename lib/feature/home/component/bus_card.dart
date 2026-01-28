import 'package:collection/collection.dart';
import 'package:dotto/feature/bus/bus.dart';
import 'package:dotto/feature/bus/controller/bus_data_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_scrolled_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_to_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_weekday_controller.dart';
import 'package:dotto/feature/bus/controller/bus_polling_controller.dart';
import 'package:dotto/feature/bus/controller/my_bus_stop_controller.dart';
import 'package:dotto/feature/bus/widget/bus_card_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BusCard extends ConsumerWidget {
  const BusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busData = ref.watch(busDataProvider);
    final myBusStop = ref.watch(myBusStopProvider);
    final busIsTo = ref.watch(busIsToProvider);
    final busPolling = ref.watch(busPollingProvider);
    final busIsWeekday = ref.watch(busIsWeekdayProvider);

    final fromToString = busIsTo ? 'to_fun' : 'from_fun';

    return busData.when(
      data: (data) {
        final dataOfDay =
            data[fromToString]![busIsWeekday ? 'weekday' : 'holiday']!;
        for (final busTrip in dataOfDay) {
          final funBusTripStop = busTrip.stops.firstWhereOrNull(
            (element) => element.stop.id == 14023,
          );
          if (funBusTripStop == null) {
            continue;
          }
          var targetBusTripStop = busTrip.stops.firstWhereOrNull(
            (element) => element.stop.id == myBusStop.id,
          );
          var kameda = false;
          if (targetBusTripStop == null) {
            targetBusTripStop = busTrip.stops.firstWhere(
              (element) => element.stop.id == 14013,
            );
            kameda = true;
          }
          final fromBusTripStop = busIsTo ? targetBusTripStop : funBusTripStop;
          final toBusTripStop = busIsTo ? funBusTripStop : targetBusTripStop;
          final now = busPolling;
          final nowDuration = Duration(hours: now.hour, minutes: now.minute);
          final arriveAt = fromBusTripStop.time - nowDuration;
          if (arriveAt.isNegative) {
            continue;
          }
          return InkWell(
            onTap: () {
              ref.read(busIsScrolledProvider.notifier).value = false;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BusScreen(),
                  settings: const RouteSettings(name: '/home/bus'),
                ),
              );
            },
            child: BusCardContent(
              busTrip.route,
              fromBusTripStop.time,
              toBusTripStop.time,
              arriveAt,
              isKameda: kameda,
              home: true,
            ),
          );
        }
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BusScreen(),
                settings: const RouteSettings(name: '/home/bus'),
              ),
            );
          },
          child: const BusCardContent(
            '0',
            Duration.zero,
            Duration.zero,
            Duration.zero,
            home: true,
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
