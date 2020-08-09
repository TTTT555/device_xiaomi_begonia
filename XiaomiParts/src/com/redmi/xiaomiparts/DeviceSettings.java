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

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Handler;
import androidx.preference.PreferenceFragment;
import androidx.preference.PreferenceManager;
import androidx.preference.SwitchPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceCategory;
import androidx.preference.SwitchPreference;

import com.redmi.xiaomiparts.kcal.KCalSettingsActivity;
import com.redmi.xiaomiparts.ambient.AmbientGesturePreferenceActivity;
import com.redmi.xiaomiparts.preferences.CustomSeekBarPreference;
import com.redmi.xiaomiparts.preferences.SecureSettingListPreference;
import com.redmi.xiaomiparts.preferences.SecureSettingSwitchPreference;
import com.redmi.xiaomiparts.preferences.VibratorStrengthPreference;

public class DeviceSettings extends PreferenceFragment implements
        Preference.OnPreferenceChangeListener {
            
    private static final String PREF_ENABLE_DIRAC = "dirac_enabled";
    private static final String PREF_HEADSET = "dirac_headset_pref";
    private static final String PREF_PRESET = "dirac_preset_pref";

    public static final String KEY_VIBSTRENGTH = "vib_strength";
    private static final String CATEGORY_DISPLAY = "display";
    private static final String PREF_DEVICE_KCAL = "device_kcal";
    
    public static final String PREF_SPECTRUM = "spectrum";
    public static final String SPECTRUM_SYSTEM_PROPERTY = "persist.spectrum.profile";
    
    public static final String PERF_MSM_THERMAL = "msmthermal";
    public static final String MSM_THERMAL_PATH = "/sys/module/msm_thermal/parameters/enabled";
    public static final String PERF_CORE_CONTROL = "corecontrol";
    public static final String CORE_CONTROL_PATH = "/sys/module/msm_thermal/core_control/enabled";
    public static final String PERF_VDD_RESTRICTION = "vddrestrict";
    public static final String VDD_RESTRICTION_PATH = "/sys/module/msm_thermal/vdd_restriction/enabled";
    public static final String PREF_CPUCORE = "cpucore";
    public static final String CPUCORE_SYSTEM_PROPERTY = "persist.cpucore.profile";
    
    public static final String PREF_KEY_FPS_INFO = "fps_info";

    public static final String PREF_TCP = "tcpcongestion";
    public static final String TCP_SYSTEM_PROPERTY = "persist.tcp.profile";
    
    private VibratorStrengthPreference mVibratorStrength;
    private Preference mKcal;
    private Preference mAmbientPref;
    private SecureSettingSwitchPreference mEnableDirac;
    private SecureSettingListPreference mHeadsetType;
    private SecureSettingListPreference mPreset;
    
    private SecureSettingListPreference mSPECTRUM;
    
    private SecureSettingSwitchPreference mMsmThermal;
    private SecureSettingSwitchPreference mCoreControl;
    private SecureSettingSwitchPreference mVddRestrict;
    private SecureSettingListPreference mCPUCORE;

    private SecureSettingListPreference mTCP;
    
    private static Context mContext;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.preferences_xiaomi_parts, rootKey);
        
        // Dirac
        boolean enhancerEnabled;
        try {
            enhancerEnabled = DiracService.sDiracUtils.isDiracEnabled();
        } catch (java.lang.NullPointerException e) {
            getContext().startService(new Intent(getContext(), DiracService.class));
            try {
                enhancerEnabled = DiracService.sDiracUtils.isDiracEnabled();
            } catch (NullPointerException ne) {
                // Avoid crash
                ne.printStackTrace();
                enhancerEnabled = false;
            }
        }
	// Dirac
        mEnableDirac = (SecureSettingSwitchPreference) findPreference(PREF_ENABLE_DIRAC);
        mEnableDirac.setOnPreferenceChangeListener(this);
        mEnableDirac.setChecked(enhancerEnabled);
	// HeadSet
        mHeadsetType = (SecureSettingListPreference) findPreference(PREF_HEADSET);
        mHeadsetType.setOnPreferenceChangeListener(this);
	// PreSet
        mPreset = (SecureSettingListPreference) findPreference(PREF_PRESET);
        mPreset.setOnPreferenceChangeListener(this);
        
        mContext = this.getContext();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(mContext);

        String device = FileUtils.getStringProp("ro.build.product", "unknown");

        
        PreferenceCategory displayCategory = (PreferenceCategory) findPreference(CATEGORY_DISPLAY);

        mVibratorStrength = (VibratorStrengthPreference) findPreference(KEY_VIBSTRENGTH);
        if (mVibratorStrength != null) {
            mVibratorStrength.setEnabled(VibratorStrengthPreference.isSupported());
        }
        
        
        SwitchPreference fpsInfo = (SwitchPreference) findPreference(PREF_KEY_FPS_INFO);
        fpsInfo.setChecked(prefs.getBoolean(PREF_KEY_FPS_INFO, false));
        fpsInfo.setOnPreferenceChangeListener(this);

        mKcal = findPreference(PREF_DEVICE_KCAL);

        mKcal.setOnPreferenceClickListener(preference -> {
            Intent intent = new Intent(getActivity().getApplicationContext(), KCalSettingsActivity.class);
            startActivity(intent);
            return true;
        });
            
        mSPECTRUM = (SecureSettingListPreference) findPreference(PREF_SPECTRUM);
        mSPECTRUM.setValue(FileUtils.getStringProp(SPECTRUM_SYSTEM_PROPERTY, "0"));
        mSPECTRUM.setSummary(mSPECTRUM.getEntry());
        mSPECTRUM.setOnPreferenceChangeListener(this);
        
        //MSM Thermal control
        if (FileUtils.fileWritable(MSM_THERMAL_PATH)) {
            mMsmThermal = (SecureSettingSwitchPreference) findPreference(PERF_MSM_THERMAL);
            mMsmThermal.setChecked(FileUtils.getFileValueAsBoolean(MSM_THERMAL_PATH, true));
            mMsmThermal.setOnPreferenceChangeListener(this);
        } else {
            getPreferenceScreen().removePreference(findPreference(PERF_MSM_THERMAL));
        }

        if (FileUtils.fileWritable(CORE_CONTROL_PATH)) {
            mCoreControl = (SecureSettingSwitchPreference) findPreference(PERF_CORE_CONTROL);
            mCoreControl.setChecked(FileUtils.getFileValueAsBoolean(CORE_CONTROL_PATH, true));
            mCoreControl.setOnPreferenceChangeListener(this);
        } else {
            getPreferenceScreen().removePreference(findPreference(PERF_CORE_CONTROL));
        }

        if (FileUtils.fileWritable(VDD_RESTRICTION_PATH)) {
            mVddRestrict = (SecureSettingSwitchPreference) findPreference(PERF_VDD_RESTRICTION);
            mVddRestrict.setChecked(FileUtils.getFileValueAsBoolean(VDD_RESTRICTION_PATH, true));
            mVddRestrict.setOnPreferenceChangeListener(this);
        } else {
            getPreferenceScreen().removePreference(findPreference(PERF_VDD_RESTRICTION));
        }

        mCPUCORE = (SecureSettingListPreference) findPreference(PREF_CPUCORE);
        mCPUCORE.setValue(FileUtils.getStringProp(CPUCORE_SYSTEM_PROPERTY, "0"));
        mCPUCORE.setSummary(mCPUCORE.getEntry());
        mCPUCORE.setOnPreferenceChangeListener(this);

	// TCP
	mTCP = (SecureSettingListPreference) findPreference(PREF_TCP);
	mTCP.setValue(FileUtils.getStringProp(TCP_SYSTEM_PROPERTY, "0"));
	mTCP.setSummary(mTCP.getEntry());
	mTCP.setOnPreferenceChangeListener(this);

	//Ambient gestures
	mAmbientPref = findPreference("ambient_display_gestures");
        mAmbientPref.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override
            public boolean onPreferenceClick(Preference preference) {
                Intent intent = new Intent(getContext(), AmbientGesturePreferenceActivity.class);
                startActivity(intent);
                return true;
            }
        });

    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object value) {
        final String key = preference.getKey();
        switch (key) {
            
            case PREF_ENABLE_DIRAC:
                try {
                    DiracService.sDiracUtils.setEnabled((boolean) value);
                } catch (java.lang.NullPointerException e) {
                    getContext().startService(new Intent(getContext(), DiracService.class));
                    DiracService.sDiracUtils.setEnabled((boolean) value);
                }
                break;

            case PREF_HEADSET:
                try {
                    DiracService.sDiracUtils.setHeadsetType(Integer.parseInt(value.toString()));
                } catch (java.lang.NullPointerException e) {
                    getContext().startService(new Intent(getContext(), DiracService.class));
                    DiracService.sDiracUtils.setHeadsetType(Integer.parseInt(value.toString()));
                }
                break;

            case PREF_PRESET:
                try {
                    DiracService.sDiracUtils.setLevel(String.valueOf(value));
                } catch (java.lang.NullPointerException e) {
                    getContext().startService(new Intent(getContext(), DiracService.class));
                    DiracService.sDiracUtils.setLevel(String.valueOf(value));
                }
                break;
                
            case PREF_SPECTRUM:
                mSPECTRUM.setValue((String) value);
                mSPECTRUM.setSummary(mSPECTRUM.getEntry());
                FileUtils.setStringProp(SPECTRUM_SYSTEM_PROPERTY, (String) value);
                break;
            
            case PERF_MSM_THERMAL:
                FileUtils.setValue(MSM_THERMAL_PATH, (boolean) value);
                break;

            case PERF_CORE_CONTROL:
                FileUtils.setValue(CORE_CONTROL_PATH, (boolean) value);
                break;

            case PERF_VDD_RESTRICTION:
                FileUtils.setValue(VDD_RESTRICTION_PATH, (boolean) value);
                break;

            case PREF_CPUCORE:
                mCPUCORE.setValue((String) value);
                mCPUCORE.setSummary(mCPUCORE.getEntry());
                FileUtils.setStringProp(CPUCORE_SYSTEM_PROPERTY, (String) value);
                break;
            
            case PREF_TCP:
                mTCP.setValue((String) value);
                mTCP.setSummary(mTCP.getEntry());
                FileUtils.setStringProp(TCP_SYSTEM_PROPERTY, (String) value);
                break;
               
            case PREF_KEY_FPS_INFO:
                boolean enabled = (Boolean) value;
                Intent fpsinfo = new Intent(this.getContext(), FPSInfoService.class);
                if (enabled) {
                    this.getContext().startService(fpsinfo);
                } else {
                    this.getContext().stopService(fpsinfo);
                }
                break;

            default:
                break;
        }
        return true;
    }

    private boolean isAppNotInstalled(String uri) {
        PackageManager packageManager = getContext().getPackageManager();
        try {
            packageManager.getPackageInfo(uri, PackageManager.GET_ACTIVITIES);
            return false;
        } catch (PackageManager.NameNotFoundException e) {
            return true;
        }
    }
}
