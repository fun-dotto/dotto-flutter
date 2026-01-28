import 'package:collection/collection.dart';
import 'package:dotto/asset.dart';
import 'package:dotto/feature/bus/controller/bus_data_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_scrolled_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_to_controller.dart';
import 'package:dotto/feature/bus/controller/bus_is_weekday_controller.dart';
import 'package:dotto/feature/bus/controller/bus_polling_controller.dart';
import 'package:dotto/feature/bus/controller/my_bus_stop_controller.dart';
import 'package:dotto/feature/bus/widget/bus_card_content.dart';
import 'package:dotto/feature/bus/widget/bus_stop_select.dart';
import 'package:dotto/feature/bus/widget/bus_timetable.dart';
import 'package:dotto_design_system/component/button.dart';
import 'package:dotto_design_system/style/semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<State<StatefulWidget>> busKey = GlobalKey();

final class BusScreen extends ConsumerWidget {
  const BusScreen({super.key});

  Widget busStopButton(
    BuildContext context,
    void Function()? onPressed,
    IconData icon,
    String title,
  ) {
    final width = MediaQuery.sizeOf(context).width * 0.3;
    const double height = 80;
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white,
          disabledForegroundColor: Colors.black87,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          fixedSize: Size(width, height),
          padding: const EdgeInsets.all(3),
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: title == '未来大' ? 0 : null,
        ),
        onPressed: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: width,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey, size: 28),
              const SizedBox(height: 5),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busData = ref.watch(busDataProvider);
    final myBusStop = ref.watch(myBusStopProvider);
    final busIsTo = ref.watch(busIsToProvider);
    final busPolling = ref.watch(busPollingProvider);
    final busIsWeekday = ref.watch(busIsWeekdayProvider);
    final busScrolled = ref.watch(busIsScrolledProvider);

    final myBusStopButton = busStopButton(
      context,
      () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const BusStopSelectScreen(),
            settings: const RouteSettings(name: '/home/bus/bus_stop_select'),
          ),
        );
      },
      Icons.directions_bus,
      myBusStop.name,
    );
    final funBusStopButton = busStopButton(context, null, Icons.school, '未来大');
    final departure = busIsTo ? myBusStopButton : funBusStopButton;
    final destination = busIsTo ? funBusStopButton : myBusStopButton;
    final fromToString = busIsTo ? 'to_fun' : 'from_fun';

    final btnChange = IconButton(
      iconSize: 20,
      color: SemanticColor.light.accentInfo,
      onPressed: () {
        ref.read(busIsToProvider.notifier).toggle();
        ref.read(busIsScrolledProvider.notifier).value = false;
      },
      icon: const Icon(Icons.swap_horiz_outlined),
    );

    final scrollController = ScrollController();

    var arriveAtSoon = true;
    final busListWidget = busData.when(
      data: (data) {
        final busListWidget =
            data[fromToString]![busIsWeekday ? 'weekday' : 'holiday']!.map((
              busTrip,
            ) {
              final funBusTripStop = busTrip.stops.firstWhereOrNull(
                (element) => element.stop.id == 14023,
              );
              if (funBusTripStop == null) {
                return Container();
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
              final fromBusTripStop = busIsTo
                  ? targetBusTripStop
                  : funBusTripStop;
              final toBusTripStop = busIsTo
                  ? funBusTripStop
                  : targetBusTripStop;
              final now = busPolling;
              final nowDuration = Duration(
                hours: now.hour,
                minutes: now.minute,
              );
              final arriveAt = fromBusTripStop.time - nowDuration;
              var hasKey = false;
              if (arriveAtSoon && arriveAt > Duration.zero) {
                arriveAtSoon = false;
                hasKey = true;
              }
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => BusTimetableScreen(busTrip),
                      settings: const RouteSettings(
                        name: '/home/bus/bus_timetable',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BusCardContent(
                    busTrip.route,
                    fromBusTripStop.time,
                    toBusTripStop.time,
                    arriveAt,
                    isKameda: kameda,
                    key: hasKey ? busKey : null,
                  ),
                ),
              );
            }).toList();
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(spacing: 8, children: busListWidget),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (busScrolled) return;
      final currentContext = busKey.currentContext;
      if (currentContext == null) return;
      final box = currentContext.findRenderObject()! as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      scrollController.animateTo(
        scrollController.offset + position.dy - 300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      ref.read(busIsScrolledProvider.notifier).value = true;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("バス一覧 ${busIsWeekday ? "平日" : "土日"}"),
        actions: [
          DottoButton(
            onPressed: () {
              ref.read(busIsWeekdayProvider.notifier).toggle();
              ref.read(busIsScrolledProvider.notifier).value = false;
            },
            type: DottoButtonType.text,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_horiz_outlined),
                Text("${busIsWeekday ? "土日" : "平日"}へ "),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.asset(
                  Asset.bus,
                  width: MediaQuery.of(context).size.width * 0.57,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    departure,
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [btnChange],
                    ),
                    destination,
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: busListWidget),
        ],
      ),
    );
  }
}
