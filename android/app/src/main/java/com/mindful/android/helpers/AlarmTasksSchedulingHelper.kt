/*
 *
 *  *
 *  *  * Copyright (c) 2024 Mindful (https://github.com/akaMrNagar/Mindful)
 *  *  * Author : Pawan Nagar (https://github.com/akaMrNagar)
 *  *  *
 *  *  * This source code is licensed under the GPL-2.0 license license found in the
 *  *  * LICENSE file in the root directory of this source tree.
 *  *
 *
 */
package com.mindful.android.helpers

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import com.mindful.android.generics.SafeServiceConnection
import com.mindful.android.models.BedtimeSettings
import com.mindful.android.receivers.alarm.BedtimeRoutineReceiver
import com.mindful.android.receivers.alarm.MidnightResetReceiver
import com.mindful.android.receivers.alarm.NotificationBatchReceiver
import com.mindful.android.receivers.alarm.NotificationBatchReceiver.NotificationBatchWorker
import com.mindful.android.services.tracking.MindfulTrackerService
import com.mindful.android.utils.AppConstants
import com.mindful.android.utils.Utils
import com.mindful.android.utils.Utils.todToTodayCal
import java.util.Calendar
import java.util.Date

/**
 * Helper class for scheduling alarm tasks related to bedtime routines and midnight resets.
 */
object AlarmTasksSchedulingHelper {
    private const val TAG = "Mindful.AlarmTasksSchedulingHelper"

    /**
     * Schedules the midnight reset task if it is not already scheduled.
     * Which will trigger at 12 midnight every day (with delay of 3 seconds).
     *
     * @param context               The application context.
     * @param checkBeforeScheduling Flag indicating whether to check if the task is already scheduled.
     */
    @JvmStatic
    fun scheduleMidnightResetTask(context: Context, checkBeforeScheduling: Boolean) {
        if (checkBeforeScheduling) {
            val intent =
                Intent(context.applicationContext, MidnightResetReceiver::class.java).setAction(
                    MidnightResetReceiver.ACTION_START_MIDNIGHT_RESET
                )
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
            )

            if (pendingIntent != null) {
                Log.d(TAG, "scheduleMidnightTask: Midnight reset task is already scheduled")
                return
            }
        }

        val cal = Calendar.getInstance()
        cal[Calendar.HOUR_OF_DAY] = 0
        cal[Calendar.MINUTE] = 0
        cal[Calendar.SECOND] = 3 // For safe side
        cal.add(Calendar.DATE, 1)

        scheduleOrUpdateExactAlarmTask(
            context,
            MidnightResetReceiver::class.java,
            MidnightResetReceiver.ACTION_START_MIDNIGHT_RESET,
            cal.timeInMillis
        )
        Log.d(
            TAG,
            "scheduleMidnightTask: Midnight reset task scheduled successfully for " + cal.time
        )
    }

    /**
     * Schedules the bedtime alert, start, and stop tasks based on the bedtime settings.
     *
     * @param context         The application context.
     * @param bedtimeSettings The Bedtime settings object used for scheduling.
     */
    @JvmStatic
    fun scheduleBedtimeRoutineTasks(context: Context, bedtimeSettings: BedtimeSettings) {
        val nowInMs = System.currentTimeMillis()
        var alertTimeMs = todToTodayCal(bedtimeSettings.startTimeInMins - 30).timeInMillis
        var startTimeMs = todToTodayCal(bedtimeSettings.startTimeInMins).timeInMillis
        var endTimeMs =
            todToTodayCal(bedtimeSettings.startTimeInMins + bedtimeSettings.totalDurationInMins).timeInMillis

        // Bedtime is already ended then reschedule for the next day
        if (endTimeMs < nowInMs) {
            alertTimeMs += AppConstants.ONE_DAY_IN_MS
            startTimeMs += AppConstants.ONE_DAY_IN_MS
            endTimeMs += AppConstants.ONE_DAY_IN_MS
        }

        // If alert time is in future
        if (alertTimeMs > nowInMs) {
            scheduleOrUpdateExactAlarmTask(
                context = context,
                receiverClass = BedtimeRoutineReceiver::class.java,
                intentAction = BedtimeRoutineReceiver.ACTION_ALERT_BEDTIME,
                epochTimeMs = alertTimeMs
            )
        }

        // Bedtime start and stop tasks
        scheduleOrUpdateExactAlarmTask(
            context = context,
            receiverClass = BedtimeRoutineReceiver::class.java,
            intentAction = BedtimeRoutineReceiver.ACTION_START_BEDTIME,
            epochTimeMs = startTimeMs
        )
        scheduleOrUpdateExactAlarmTask(
            context = context,
            receiverClass = BedtimeRoutineReceiver::class.java,
            intentAction = BedtimeRoutineReceiver.ACTION_STOP_BEDTIME,
            epochTimeMs = endTimeMs
        )
        Log.d(
            TAG, """
                 scheduleBedtimeStartTask: Bedtime routine tasks scheduled successfully for - 
                 alert: ${if (alertTimeMs > nowInMs) "" else "(skipping) "}${Date(alertTimeMs)}
                 start: ${Date(startTimeMs)}
                 end: ${Date(endTimeMs)}
                 """.trimIndent()
        )
    }


    /**
     * Cancels both scheduled start and stop bedtime routine tasks.
     *
     * @param context The application context.
     */
    @JvmStatic
    fun cancelBedtimeRoutineTasks(context: Context) {
        // Cancel the alarms
        cancelExactAlarmTasks(
            context,
            BedtimeRoutineReceiver::class.java,
            listOf(
                BedtimeRoutineReceiver.ACTION_ALERT_BEDTIME,
                BedtimeRoutineReceiver.ACTION_START_BEDTIME,
                BedtimeRoutineReceiver.ACTION_STOP_BEDTIME
            )
        )

        // Let service know
        if (Utils.isServiceRunning(context, MindfulTrackerService::class.java)) {
            val conn = SafeServiceConnection(MindfulTrackerService::class.java, context)
            conn.setOnConnectedCallback { service -> service.getRestrictionManager.updateBedtimeApps(null) }
            conn.bindService()
            conn.unBindService()
        }
        Log.d(TAG, "cancelBedtimeRoutineTasks: Bedtime routine tasks cancelled successfully")
    }

    /**
     * Schedules next future possible notification batch.
     *
     * @param context      The application context.
     * @param scheduleTods The hashset of integers representing TODs in minutes.
     */
    fun scheduleNotificationBatchTask(context: Context, scheduleTods: HashSet<Int>) {
        val sortedTods = scheduleTods.sorted()
        if (sortedTods.isEmpty()) return

        val now = System.currentTimeMillis()
        var nextAlarmTimeMs: Long? = null

        // Find the first future TOD
        for (tod in sortedTods) {
            val currentTime = todToTodayCal(tod).timeInMillis
            if (currentTime > now) {
                nextAlarmTimeMs = currentTime
                break
            }
        }

        // If no future TOD, schedule for the first TOD of the next day
        nextAlarmTimeMs = nextAlarmTimeMs
            ?: (todToTodayCal(sortedTods[0]).timeInMillis + AppConstants.ONE_DAY_IN_MS)


        scheduleOrUpdateExactAlarmTask(
            context = context,
            receiverClass = NotificationBatchReceiver::class.java,
            intentAction = NotificationBatchReceiver.ACTION_PUSH_BATCH,
            epochTimeMs = nextAlarmTimeMs,
        )
        Log.d(
            TAG,
            "scheduleNotificationBatchTask: Notification batch task scheduled successfully for " + Date(
                nextAlarmTimeMs
            )
        )
    }

    /**
     * Cancels notification batch schedule task.
     *
     * @param context The application context.
     */
    @JvmStatic
    fun cancelNotificationBatchTask(context: Context) {
        cancelExactAlarmTasks(
            context = context,
            receiverClass = NotificationBatchWorker::class.java,
            intentActions = listOf(NotificationBatchReceiver.ACTION_PUSH_BATCH)
        )
        Log.d(TAG, "cancelNotificationBatchTask: Notification batch tasks cancelled successfully")
    }

    /**
     * Schedules or updates an alarm task with the specified parameters.
     *
     * @param context       The application context.
     * @param receiverClass The receiver class for the alarm.
     * @param intentAction  The action to be set on the intent.
     * @param epochTimeMs   The time at which the alarm should go off, in milliseconds since epoch.
     */
    private fun scheduleOrUpdateExactAlarmTask(
        context: Context,
        receiverClass: Class<*>,
        intentAction: String,
        epochTimeMs: Long
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context.applicationContext, receiverClass).setAction(intentAction)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    epochTimeMs,
                    pendingIntent
                )
            }
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                epochTimeMs,
                pendingIntent
            )
        }
    }

    /**
     * Cancels all the exact alarm task related to the service class and the list of actions.
     *
     * @param context       The application context.
     * @param receiverClass The receiver class for the alarm.
     * @param intentActions The list of actions to be set on the intents.
     */
    private fun cancelExactAlarmTasks(
        context: Context,
        receiverClass: Class<*>,
        intentActions: List<String>
    ) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        for (action in intentActions) {
            val intent = Intent(context.applicationContext, receiverClass).setAction(action)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
    }
}
