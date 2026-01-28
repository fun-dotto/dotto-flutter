import 'dart:async';

import 'package:dotto/controller/user_controller.dart';
import 'package:dotto/data/json/model/cancel_lecture.dart';
import 'package:dotto/feature/timetable/viewmodel/course_cancellation_viewmodel.dart';
import 'package:dotto_design_system/component/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CourseCancellationScreen extends ConsumerStatefulWidget {
  const CourseCancellationScreen({super.key});

  @override
  ConsumerState<CourseCancellationScreen> createState() =>
      _CourseCancellationScreenState();
}

final class _CourseCancellationScreenState
    extends ConsumerState<CourseCancellationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref.read(courseCancellationViewModelProvider.notifier).onAppear(),
      );
    });
  }

  Widget _buildListView(List<CancelLecture> list) {
    if (list.isEmpty) {
      return const Center(child: Text('休講・補講はありません。'));
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          title: Text(
            '${item.date} ${item.period}限',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          subtitle: Text(
            '${item.lessonName}\n'
            '${item.comment}',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('休講・補講')),
        body: const Center(
          child: Text('Googleアカウント(@fun.ac.jp)ログインが必要です。'),
        ),
      );
    }

    final viewModel = ref.watch(courseCancellationViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('休講・補講'),
        actions: <Widget>[
          DottoButton(
            onPressed: () async {
              await ref
                  .read(courseCancellationViewModelProvider.notifier)
                  .onFilterToggled();
            },
            type: DottoButtonType.text,
            child: Row(
              spacing: 4,
              children: [
                Icon(
                  viewModel.isFilteredOnlyTaking
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                ),
                Text(viewModel.isFilteredOnlyTaking ? '履修中' : 'すべて'),
              ],
            ),
          ),
        ],
      ),
      body: viewModel.courseCancellations.when(
        data: _buildListView,
        error: (error, stackTrace) =>
            const Center(child: Text('データの取得に失敗しました。')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
