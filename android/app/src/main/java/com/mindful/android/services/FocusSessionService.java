package com.mindful.android.services;

import static com.mindful.android.utils.AppConstants.EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.CountDownTimer;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.NonNull;

import com.mindful.android.generics.SafeServiceConnection;
import com.mindful.android.generics.ServiceBinder;
import com.mindful.android.helpers.NotificationHelper;
import com.mindful.android.helpers.SharedPrefsHelper;
import com.mindful.android.utils.AppConstants;

public class FocusSessionService extends Service {
    private static final String TAG = "Mindful.FocusSessionService";

    private CountDownTimer mCountDownTimer;
    private NotificationManager mNotificationManager;
    private SafeServiceConnection<MindfulTrackerService> mTrackerServiceConn;

    @Override
    public void onCreate() {
        super.onCreate();
        mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        // Bind to tracking service
        mTrackerServiceConn = new SafeServiceConnection<>(MindfulTrackerService.class, this);
//        mTrackerServiceConn.setOnConnectedCallback(service -> service.pauseResumeTracking(true));
        mTrackerServiceConn.bindService();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        int leftPasses = SharedPrefsHelper.fetchEmergencyPassesCount(this);

        // Stop if no passes left
        if (leftPasses <= 0) {
            stopSelf();
            return START_NOT_STICKY;
        }

        SharedPrefsHelper.storeEmergencyPassesCount(this, leftPasses - 1);
        startTimer();

        Log.d(TAG, "onStartCommand: Focus Session service started successfully");
        return START_STICKY;
    }


    /**
     * Starts the countdown timer and updates the notification with the remaining time.
     */
    private void startTimer() {
        startForeground(EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID, createNotification(AppConstants.DEFAULT_EMERGENCY_PASS_PERIOD_MS));
        mCountDownTimer = new CountDownTimer(AppConstants.DEFAULT_EMERGENCY_PASS_PERIOD_MS, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                mNotificationManager.notify(EMERGENCY_PAUSE_SERVICE_NOTIFICATION_ID, createNotification(millisUntilFinished));
            }

            @Override
            public void onFinish() {
//                if (mTrackerServiceConn.isConnected()) {
//                    mTrackerServiceConn.getService().pauseResumeTracking(false);
//                }
//                stopSelf();
            }
        }.start();
    }

    /**
     * Creates a notification for the Focus Session with the remaining time.
     *
     * @param millisUntilFinished The remaining time in milliseconds.
     * @return The notification object.
     */
    @NonNull
    private Notification createNotification(long millisUntilFinished) {
        int totalSeconds = (int) (millisUntilFinished / 1000);
        int leftMinutes = totalSeconds / 60;
        int leftSeconds = totalSeconds % 60;

        String msg = "Focus session will end in " + leftMinutes + ":" + leftSeconds + " minutes";

        return NotificationHelper.buildProgressNotification(
                this,
                "Emergency pause",
                msg,
                AppConstants.DEFAULT_EMERGENCY_PASS_PERIOD_MS,
                (int) millisUntilFinished
        );
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        mTrackerServiceConn.unBindService();
        if (mCountDownTimer != null) {
            mCountDownTimer.cancel();
        }
        stopForeground(STOP_FOREGROUND_DETACH);
        Log.d(TAG, "onDestroy: Focus Session service destroyed");
    }

    @Override
    public IBinder onBind(Intent intent) {
        return new ServiceBinder<>(FocusSessionService.this);
    }
}