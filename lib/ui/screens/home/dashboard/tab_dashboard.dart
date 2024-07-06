import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/enums/usage_type.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/core/extensions/ext_widget.dart';
import 'package:mindful/core/utils/utils.dart';
import 'package:mindful/providers/aggregated_usage_provider.dart';
import 'package:mindful/providers/packages_by_network_usage_provider.dart';
import 'package:mindful/providers/packages_by_screen_usage_provider.dart';
import 'package:mindful/ui/common/async_error_indicator.dart';
import 'package:mindful/ui/common/async_loading_indicator.dart';
import 'package:mindful/ui/common/list_tile_skeleton.dart';
import 'package:mindful/ui/common/rounded_container.dart';
import 'package:mindful/ui/common/usage_chart_panel.dart';
import 'package:mindful/ui/common/usage_cards_sliver.dart';
import 'package:mindful/ui/common/sliver_flexible_appbar.dart';
import 'package:mindful/ui/common/animated_apps_list.dart';
import 'package:mindful/ui/screens/home/dashboard/application_tile.dart';

class TabDashboard extends ConsumerStatefulWidget {
  const TabDashboard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TabDashboardState();
}

class _TabDashboardState extends ConsumerState<TabDashboard> {
  UsageType _usageType = UsageType.screenUsage;
  int _dayOfWeek = 1;
  bool _includeAllApps = false;

  @override
  void initState() {
    super.initState();
    _dayOfWeek = dayOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    /// Aggregated usage for whole week on the basis of full day
    final aggregatedUsage = ref.watch(aggregatedUsageProvider);

    /// Parameters for family provider
    final params = (dayOfWeek: _dayOfWeek, includeAll: _includeAllApps);

    /// Filtered and sorted apps based on usage type and day of this week
    final filtered = _usageType == UsageType.screenUsage
        ? ref.watch(packagesByScreenUsageProvider(params))
        : ref.watch(packagesByNetworkUsageProvider(params));

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 8),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// Appbar
          const SliverFlexibleAppBar(title: "Dashboard"),

          /// Usage type selector and usage info card
          UsageCardsSliver(
            usageType: _usageType,
            screenUsageInfo: aggregatedUsage.screenTimeThisWeek[_dayOfWeek],
            wifiUsageInfo: aggregatedUsage.wifiUsageThisWeek[_dayOfWeek],
            mobileUsageInfo: aggregatedUsage.mobileUsageThisWeek[_dayOfWeek],
            onUsageTypeChanged: (i) => setState(
              () => _usageType = UsageType.values[i],
            ),
          ),
          20.vSliverBox(),

          /// Usage bar chart and selected day changer
          UsageChartPanel(
            dayOfWeek: _dayOfWeek,
            usageType: _usageType,
            barChartData: _usageType == UsageType.screenUsage
                ? aggregatedUsage.screenTimeThisWeek
                : aggregatedUsage.networkUsageThisWeek,
            onDayOfWeekChanged: (dow) => setState(() => _dayOfWeek = dow),
          ),

          /// Most used apps list
          filtered.when(
            loading: () => const AsyncLoadingIndicator().toSliverBox(),
            error: (e, st) => AsyncErrorIndicator(e, st).toSliverBox(),
            data: (packages) => AnimatedAppsList(
              itemExtent: 64,
              appPackages: packages,
              headerTitle: "Most used apps",
              itemBuilder: (context, app) => ApplicationTile(
                app: app,
                usageType: _usageType,
                day: _dayOfWeek,
              ),
            ),
          ),

          /// Show all apps button
          if (!_includeAllApps && filtered.hasValue)
            RoundedContainer(
              height: 48,
              onPressed: () => setState(() => _includeAllApps = true),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(top: 20),
              child: const ListTileSkeleton(
                leading: Icon(FluentIcons.select_all_off_20_regular),
                title: Text("Show all apps"),
                trailing: Icon(FluentIcons.chevron_down_20_filled),
              ),
            ).toSliverBox(),

          72.vSliverBox(),
        ],
      ),
    );
  }
}
