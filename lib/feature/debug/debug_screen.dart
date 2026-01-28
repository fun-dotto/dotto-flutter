import 'package:dotto/data/api_environment.dart';
import 'package:dotto/feature/debug/debug_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  void _showEnvironmentPicker(
    BuildContext context,
    Environment currentEnvironment,
    void Function(Environment environment) onEnvironmentSelected,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Environment'),
        children: Environment.values.map((environment) {
          return MaterialButton(
            onPressed: () {
              onEnvironmentSelected(environment);
              Navigator.of(context).pop();
            },
            child: ListTile(
              title: Text(environment.name),
              trailing: Icon(
                environment == currentEnvironment ? Icons.check : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugViewModel = ref.watch(debugViewModelProvider);
    final environment = ref.watch(apiEnvironmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: debugViewModel.when(
        data: (data) => ListView(
          children: [
            ListTile(
              title: const Text('App Check Access Token'),
              subtitle: Text(
                data.appCheckAccessToken ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  if (data.appCheckAccessToken == null) return;
                  Clipboard.setData(
                    ClipboardData(text: data.appCheckAccessToken ?? ''),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('クリップボードにコピーしました')),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('User ID Token'),
              subtitle: Text(
                data.idToken ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  if (data.idToken == null) return;
                  Clipboard.setData(ClipboardData(text: data.idToken ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('クリップボードにコピーしました')),
                  );
                },
              ),
            ),
            ListTile(
              title: const Text('Environment'),
              subtitle: Text(environment.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEnvironmentPicker(
                context,
                environment,
                (environment) =>
                    ref.read(apiEnvironmentProvider.notifier).value =
                        environment,
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
