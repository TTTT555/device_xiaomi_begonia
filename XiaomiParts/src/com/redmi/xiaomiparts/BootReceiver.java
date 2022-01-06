/*
 * Copyright (C) 2018 The Asus-SDM660 Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.redmi.xiaomiparts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import androidx.preference.PreferenceManager;
import android.provider.Settings;
import com.redmi.xiaomiparts.preferences.VibratorStrengthPreference;

import com.redmi.xiaomiparts.ambient.SensorsDozeService;


public class BootReceiver extends BroadcastReceiver {
	

    public void onReceive(Context context, Intent intent) {
    
        SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        
        // Dirac
        context.startService(new Intent(context, DiracService.class));

        // Ambient
        context.startService(new Intent(context, SensorsDozeService.class));
        
        //FPS
        boolean enabled = sharedPrefs.getBoolean(DeviceSettings.PREF_KEY_FPS_INFO, false);
        if (enabled) {
            context.startService(new Intent(context, FPSInfoService.class));
        }
    }
}

