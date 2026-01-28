import 'package:dotto/feature/bus/controller/bus_is_to_controller.dart';
import 'package:dotto/feature/bus/controller/my_bus_stop_controller.dart';
import 'package:dotto/feature/bus/domain/bus_type.dart';
import 'package:dotto/feature/bus/repository/bus_repository.dart';
import 'package:dotto_design_system/style/semantic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BusCardContent extends ConsumerWidget {
  const BusCardContent(
    this.route,
    this.beginTime,
    this.endTime,
    this.arriveAt, {
    super.key,
    this.isKameda = false,
    this.home = false,
  });
  final String route;
  final Duration beginTime;
  final Duration endTime;
  final Duration arriveAt;
  final bool isKameda;
  final bool home;

  BusType getType() {
    if (['55', '55A', '55B', '55C', '55E', '55F'].contains(route)) {
      return BusType.goryokaku;
    }
    if (route == '55G') {
      return BusType.syowa;
    }
    if (route == '55H') {
      return BusType.kameda;
    }
    return BusType.other;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busIsTo = ref.watch(busIsToProvider);
    final myBusStop = ref.watch(myBusStopProvider);
    final tripType = getType();
    final headerText = tripType != BusType.other
        ? tripType.where + (busIsTo ? 'から' : '行き')
        : '';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.light.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SemanticColor.light.borderPrimary),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: home ? 0 : 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (home)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      busIsTo
                          ? '${myBusStop.name} → 未来大'
                          : '未来大 → ${myBusStop.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 5),
                    child: IconButton(
                      color: SemanticColor.light.accentInfo,
                      onPressed: () {
                        ref.read(busIsToProvider.notifier).toggle();
                      },
                      icon: const Icon(Icons.swap_horiz_outlined),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            if (route != '0')
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$route $headerText'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        BusRepository().formatDuration(beginTime),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -5),
                        child: Text(isKameda && busIsTo ? '亀田支所発' : '発'),
                      ),
                      const Spacer(),
                      Transform.translate(
                        offset: const Offset(0, -5),
                        child: Text(
                          '${BusRepository().formatDuration(endTime)}'
                          '${isKameda && !busIsTo ? '亀田支所着' : '着'}',
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 6, color: tripType.dividerColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Text('出発まで${arriveAt.inMinutes}分')],
                  ),
                ],
              )
            else
              const Text('今日の運行は終了しました。'),
          ],
        ),
      ),
    );
  }
}
