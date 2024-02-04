import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindful/core/extensions/ext_duration.dart';
import 'package:mindful/core/extensions/ext_num.dart';
import 'package:mindful/providers/schedule_provider.dart';
import 'package:mindful/ui/screens/home/bedtime/days_selector.dart';
import 'package:mindful/ui/widgets/buttons.dart';
import 'package:mindful/ui/widgets/custom_text.dart';

class BedtimeCard extends StatelessWidget {
  const BedtimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 4, right: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Schedule time
          Consumer(
            builder: (_, WidgetRef ref, __) {
              return Row(
                children: [
                  _SelectedTime(
                    label: "Start",
                    initialTime: ref
                        .watch(bedtimeProvider.select((value) => value.start)),
                    onChange: (t) =>
                        ref.read(bedtimeProvider.notifier).setBedtimeStart(t),
                  ),
                  const Spacer(),
                  _SelectedTime(
                    label: "End",
                    initialTime:
                        ref.watch(bedtimeProvider.select((value) => value.end)),
                    onChange: (t) =>
                        ref.read(bedtimeProvider.notifier).setBedtimeEnd(t),
                  ),
                ],
              );
            },
          ),

          /// Total bedtime duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Divider(
                  color: Theme.of(context).focusColor,
                ),
              ),
              12.hBox(),
              Consumer(
                builder: (_, WidgetRef ref, __) {
                  final duration = ref
                      .watch(bedtimeProvider.select((value) => value.duration));
                  return SubtitleText(duration.toTimeShort());
                },
              ),
              // SubtitleText(10552.minutes.toTimeFull()),
              12.hBox(),
              Expanded(
                child: Divider(
                  color: Theme.of(context).focusColor,
                ),
              ),
            ],
          ),

          /// Days
          const DaysSelector(),
        ],
      ),
    );
  }
}

class _SelectedTime extends ConsumerWidget {
  const _SelectedTime({
    required this.label,
    required this.onChange,
    required this.initialTime,
  });

  final String label;
  final TimeOfDay initialTime;
  final Function(TimeOfDay time) onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(bedtimeProvider.select((value) => value.bedtimeStatus));

    return SecondaryButton(
      onPressed: status
          ? () {
              showTimePicker(
                context: context,
                initialTime: initialTime,
              ).then((value) {
                onChange(value ?? initialTime);
              });
            }
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubtitleText(label),
          4.vBox(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleText(
                initialTime.format(context).split(' ').first,
                size: 36,
              ),
              6.hBox(),
              SubtitleText(
                "${initialTime.period.name} ${initialTime.period.index}",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
