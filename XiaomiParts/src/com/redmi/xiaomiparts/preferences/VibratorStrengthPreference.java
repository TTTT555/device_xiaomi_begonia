/*
* Copyright (C) 2016 The OmniROM Project
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.com/licenses/>.
*
*/
package com.redmi.xiaomiparts.preferences;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Vibrator;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceViewHolder;
import android.util.AttributeSet;
import com.redmi.xiaomiparts.Utils;
import com.redmi.xiaomiparts.DeviceSettings;
import com.redmi.xiaomiparts.BootReceiver;

import java.util.List;

public class VibratorStrengthPreference extends CustomSeekBarPreference {

    // from thunderquake engine v1.1
    private static int mMinVal = 0;
    private static int mMaxVal = 9;
    private static int mDefVal = 9;
    private Vibrator mVibrator;

    private static final String FILE_LEVEL = "/sys/kernel/thunderquake_engine/level";
    private static final long testVibrationPattern[] = {0,250};

    public VibratorStrengthPreference(Context context, AttributeSet attrs) {
        super(context, attrs);

        mInterval = 1;
        mShowSign = false;
        mUnits = "";
        mContinuousUpdates = false;
        mMinValue = mMinVal;
        mMaxValue = mMaxVal;
        mDefaultValueExists = true;
        mDefaultValue = mDefVal;
        mValue = Integer.parseInt(loadValue());

        setPersistent(false);

        mVibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
    }

    public static boolean isSupported() {
        return Utils.fileWritable(FILE_LEVEL);
    }

    public static void restore(Context context) {
        if (!isSupported()) {
            return;
        }

        String storedValue = PreferenceManager.getDefaultSharedPreferences(context).getString(DeviceSettings.KEY_VIBSTRENGTH, String.valueOf(mDefVal));
        Utils.writeValue(FILE_LEVEL, storedValue);
    }

    public static String loadValue() {
        return Utils.getFileValue(FILE_LEVEL, String.valueOf(mDefVal));
    }

    private void saveValue(String newValue) {
        Utils.writeValue(FILE_LEVEL, newValue);
        SharedPreferences.Editor editor = PreferenceManager.getDefaultSharedPreferences(getContext()).edit();
        editor.putString(DeviceSettings.KEY_VIBSTRENGTH, newValue);
        editor.apply();
        mVibrator.vibrate(testVibrationPattern, -1);
    }

    @Override
    protected void changeValue(int newValue) {
        saveValue(String.valueOf(newValue));
    }
}
