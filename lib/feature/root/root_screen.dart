import 'package:dotto/domain/tab_item.dart';
import 'package:dotto/feature/assignment/assignment_list_screen.dart';
import 'package:dotto/feature/home/home_screen.dart';
import 'package:dotto/feature/map/map_screen.dart';
import 'package:dotto/feature/root/root_viewmodel.dart';
import 'package:dotto/feature/root/root_viewmodel_state.dart';
import 'package:dotto/feature/search_course/search_course_screen.dart';
import 'package:dotto/feature/setting/settings.dart';
import 'package:dotto/widget/app_tutorial.dart';
import 'package:dotto/widget/invalid_app_version_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

final class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  Widget _updateAlertDialog({
    required BuildContext context,
    required String appStorePageUrl,
  }) {
    return AlertDialog(
      title: const Text('アップデートが必要です'),
      content: const Text('最新版のDottoをご利用ください。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('あとで'),
        ),
        TextButton(
          onPressed: () => launchUrlString(
            appStorePageUrl,
            mode: LaunchMode.externalApplication,
          ),
          child: const Text('今すぐアップデート'),
        ),
      ],
    );
  }

  Widget _body({
    required BuildContext context,
    required RootViewModelState viewModel,
    required void Function() onGoToSettingButtonTapped,
  }) {
    return SafeArea(
      child: Stack(
        children: TabItem.values
            .map(
              (tabItemOnce) => Offstage(
                offstage: viewModel.selectedTab != tabItemOnce,
                child: Navigator(
                  key: viewModel.navigatorStates[tabItemOnce],
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(
                      builder: (context) => switch (tabItemOnce) {
                        TabItem.home => const HomeScreen(),
                        TabItem.map => MapScreen(
                          onGoToSettingButtonTapped: onGoToSettingButtonTapped,
                        ),
                        TabItem.course => const SearchCourseScreen(),
                        TabItem.assignment => const AssignmentListScreen(),
                        TabItem.setting => const SettingsScreen(),
                      },
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _bottomNavigationBar({
    required BuildContext context,
    required RootViewModelState viewModel,
    required void Function(int) onTabItemTapped,
  }) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: TabItem.values.indexOf(viewModel.selectedTab),
      items: TabItem.values
          .map(
            (tabItem) => BottomNavigationBarItem(
              icon: Icon(tabItem.icon),
              activeIcon: Icon(tabItem.activeIcon),
              label: tabItem.title,
            ),
          )
          .toList(),
      onTap: onTabItemTapped,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(rootViewModelProvider);

    switch (viewModelAsync) {
      case AsyncData(:final value):
        if (!value.hasShownAppTutorial) {
          debugPrint('Show App Tutorial');
          return AppTutorial(
            onDismissed: () => ref
                .read(rootViewModelProvider.notifier)
                .onAppTutorialDismissed(),
          );
        }
        if (!value.isValidAppVersion) {
          debugPrint('Invalid App Version');
          return InvalidAppVersionScreen(
            appStorePageUrl: value.appStorePageUrl,
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!value.isLatestAppVersion && !value.hasShownUpdateAlert) {
            debugPrint('Not Latest App Version');
            ref.read(rootViewModelProvider.notifier).onUpdateAlertShown();
            showDialog<void>(
              context: context,
              builder: (context) => _updateAlertDialog(
                context: context,
                appStorePageUrl: value.appStorePageUrl,
              ),
            );
          }
        });

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: _body(
            context: context,
            viewModel: value,
            onGoToSettingButtonTapped: () => ref
                .read(rootViewModelProvider.notifier)
                .onGoToSettingButtonTapped(),
          ),
          bottomNavigationBar: _bottomNavigationBar(
            context: context,
            viewModel: value,
            onTabItemTapped: (index) =>
                ref.read(rootViewModelProvider.notifier).onTabItemTapped(index),
          ),
        );

      case AsyncError(:final error):
        debugPrint('RootScreen Error: $error');
        return const SizedBox.shrink();

      case AsyncLoading():
        return const Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
