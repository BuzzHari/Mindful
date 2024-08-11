import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/config/app_themes.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/providers/settings_provider.dart';
import 'package:mindful/ui/common/default_list_tile.dart';
import 'package:mindful/ui/common/rounded_container.dart';
import 'package:mindful/ui/common/sliver_content_title.dart';
import 'package:mindful/ui/common/sliver_flexible_appbar.dart';
import 'package:mindful/ui/common/default_dropdown_tile.dart';
import 'package:mindful/ui/common/styled_text.dart';

class TabGeneral extends ConsumerWidget {
  const TabGeneral({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataUsageResetTime =
        ref.watch(settingsProvider.select((v) => v.dataResetToD));

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 8),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Appbar
          const SliverFlexibleAppBar(title: "General"),

          /// Appearance
          const SliverContentTitle(title: "Appearance"),

          /// Theme mode
          DefaultDropdownTile<ThemeMode>(
            value: ref.watch(settingsProvider.select((v) => v.themeMode)),
            dialogIcon: FluentIcons.dark_theme_20_filled,
            label: "Theme mode",
            onSelected: ref.read(settingsProvider.notifier).changeThemeMode,
            items: [
              DefaultDropdownItem(label: "System", value: ThemeMode.system),
              DefaultDropdownItem(label: "Dark", value: ThemeMode.dark),
              DefaultDropdownItem(label: "Light", value: ThemeMode.light),
            ],
          ).sliver,

          /// Material Color
          DefaultDropdownTile<String>(
            label: "Material color",
            dialogIcon: FluentIcons.color_20_filled,
            value: ref.watch(settingsProvider.select((v) => v.color)),
            onSelected: ref.read(settingsProvider.notifier).changeColor,
            trailingBuilder: (item) => RoundedContainer(
              height: 18,
              width: 18,
              circularRadius: 15,
              color: AppTheme.materialColors[item],
            ),
            items: AppTheme.materialColors.entries
                .map((e) => DefaultDropdownItem(
                      label: e.key,
                      value: e.key,
                    ))
                .toList(),
          ).sliver,

          /// Default settings
          12.vSliverBox,
          const SliverContentTitle(title: "Default"),

          /// Data reset time
          DefaultListTile(
            titleText: "Daily data usage reset time",
            subtitleText:
                "Specify the time when your daily data cycle renews based on your recharge plan.",
            trailing: StyledText(
              " ${dataUsageResetTime.format(context)}",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: dataUsageResetTime,
                helpText: "Select daily data usage reset time",
              );

              if (pickedTime != null && context.mounted) {
                ref
                    .read(settingsProvider.notifier)
                    .changeDataResetTime(pickedTime);
              }
            },
          ).sliver,
        ],
      ),
    );
  }
}
