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

    public static final String KEY_VIBSTRENGTH = "vibration_strength";
    private static final String CATEGORY_DISPLAY = "display";

    public static final String PREF_GOVERNOR = "governor";
    public static final String GOVERNOR_SYSTEM_PROPERTY = "persist.xp.governor";

    public static final String PREF_SPECTRUM = "spectrum";
    public static final String SPECTRUM_SYSTEM_PROPERTY = "persist.spectrum.profile";
    
    public static final String PREF_KEY_FPS_INFO = "fps_info";

    public static final String PREF_HWCODECS = "codecs";
    public static final String HWCODECS_SYSTEM_PROPERTY = "persist.xp.hw_codecs";

    public static final String PREF_TCP = "tcpcongestion";
    public static final String TCP_SYSTEM_PROPERTY = "persist.tcp.profile";

    public static final String PREF_WIFI80 = "wifi80";
    public static final String WIFI80_SYSTEM_PROPERTY = "persist.xp.wifi80";

    public static final String PREF_USB = "usb";
    public static final String USB_SYSTEM_PROPERTY = "persist.xp.usb";

    public static final String PREF_FORCE64 = "force64";
    public static final String FORCE64_SYSTEM_PROPERTY = "persist.xp.force64";
	
    public static final String PREF_DISABLE_VSYNC = "vsync";
    public static final String VSYNC_SYSTEM_PROPERTY = "persist.xp.vsync.disabled";

    public static final String PREF_LATCH_UNSIGNALED = "latch_unsignaled";
    public static final String LATCH_UNSIGNALED_SYSTEM_PROPERTY = "persist.xp.latch_unsignaled";

    public static final String PREF_PQ = "pq";
    public static final String PQ_SYSTEM_PROPERTY = "persist.xp.pq";

    public static final String PREF_HW_OVERLAYS = "hw_overlays";
    public static final String HW_OVERLAYS_SYSTEM_PROPERTY = "persist.xp.hw_overlays";
    
    private VibratorStrengthPreference mVibratorStrength;
    private Preference mAmbientPref;
    private SecureSettingSwitchPreference mEnableDirac;
    private SecureSettingListPreference mHeadsetType;
    private SecureSettingListPreference mPreset;

    private SecureSettingListPreference mGovernor;

    private SecureSettingListPreference mSPECTRUM;

    private SecureSettingListPreference mHwCodecs;

    private SecureSettingListPreference mTCP;

    private SecureSettingListPreference mWiFi80;

    private SecureSettingSwitchPreference mUsb;

    private SecureSettingSwitchPreference mForce64;
	
    private SecureSettingListPreference mDisableVSYNC;

    private SecureSettingSwitchPreference mLatchUnsignaled;

    private SecureSettingSwitchPreference mPq;

    private SecureSettingSwitchPreference mHwOverlays;
    
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
            
        mSPECTRUM = (SecureSettingListPreference) findPreference(PREF_SPECTRUM);
        mSPECTRUM.setValue(FileUtils.getStringProp(SPECTRUM_SYSTEM_PROPERTY, "0"));
        mSPECTRUM.setSummary(mSPECTRUM.getEntry());
        mSPECTRUM.setOnPreferenceChangeListener(this);

    // Governor
    mGovernor = (SecureSettingListPreference) findPreference(PREF_GOVERNOR);
    mGovernor.setValue(FileUtils.getStringProp(GOVERNOR_SYSTEM_PROPERTY, "0"));
    mGovernor.setSummary(mGovernor.getEntry());
    mGovernor.setOnPreferenceChangeListener(this);

    // Codecs
    mHwCodecs = (SecureSettingListPreference) findPreference(PREF_HWCODECS);
    mHwCodecs.setValue(FileUtils.getStringProp(HWCODECS_SYSTEM_PROPERTY, "0"));
    mHwCodecs.setSummary(mHwCodecs.getEntry());
    mHwCodecs.setOnPreferenceChangeListener(this);

	// TCP
	mTCP = (SecureSettingListPreference) findPreference(PREF_TCP);
	mTCP.setValue(FileUtils.getStringProp(TCP_SYSTEM_PROPERTY, "0"));
	mTCP.setSummary(mTCP.getEntry());
	mTCP.setOnPreferenceChangeListener(this);

	// WiFi 80
	mWiFi80 = (SecureSettingListPreference) findPreference(PREF_WIFI80);
	mWiFi80.setValue(FileUtils.getStringProp(WIFI80_SYSTEM_PROPERTY, "0"));
	mWiFi80.setSummary(mWiFi80.getEntry());
	mWiFi80.setOnPreferenceChangeListener(this);

    // USB Charging
    mUsb = (SecureSettingSwitchPreference) findPreference(PREF_USB);
    mUsb.setChecked(FileUtils.getProp(USB_SYSTEM_PROPERTY, false));
    mUsb.setOnPreferenceChangeListener(this);

    // Force 64
    mForce64 = (SecureSettingSwitchPreference) findPreference(PREF_FORCE64);
    mForce64.setChecked(FileUtils.getProp(FORCE64_SYSTEM_PROPERTY, false));
    mForce64.setOnPreferenceChangeListener(this);

    // VSYNC Disabler
    mDisableVSYNC = (SecureSettingListPreference) findPreference(PREF_DISABLE_VSYNC);
    mDisableVSYNC.setValue(FileUtils.getStringProp(VSYNC_SYSTEM_PROPERTY, "0"));
    mDisableVSYNC.setSummary(mDisableVSYNC.getEntry());
    mDisableVSYNC.setOnPreferenceChangeListener(this);

    // latch_unsignaled
    mLatchUnsignaled = (SecureSettingSwitchPreference) findPreference(PREF_LATCH_UNSIGNALED);
    mLatchUnsignaled.setChecked(FileUtils.getProp(LATCH_UNSIGNALED_SYSTEM_PROPERTY, false));
    mLatchUnsignaled.setOnPreferenceChangeListener(this);

    // PQ
    mPq = (SecureSettingSwitchPreference) findPreference(PREF_PQ);
    mPq.setChecked(FileUtils.getProp(PQ_SYSTEM_PROPERTY, false));
    mPq.setOnPreferenceChangeListener(this);

    // HW overlays
    mHwOverlays = (SecureSettingSwitchPreference) findPreference(PREF_HW_OVERLAYS);
    mHwOverlays.setChecked(FileUtils.getProp(HW_OVERLAYS_SYSTEM_PROPERTY, false));
    mHwOverlays.setOnPreferenceChangeListener(this);

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

            case PREF_GOVERNOR:
                mGovernor.setValue((String) value);
                mGovernor.setSummary(mGovernor.getEntry());
                FileUtils.setStringProp(GOVERNOR_SYSTEM_PROPERTY, (String) value);
                break;

            case PREF_SPECTRUM:
                mSPECTRUM.setValue((String) value);
                mSPECTRUM.setSummary(mSPECTRUM.getEntry());
                FileUtils.setStringProp(SPECTRUM_SYSTEM_PROPERTY, (String) value);
                break;

            case PREF_HWCODECS:
                mHwCodecs.setValue((String) value);
                mHwCodecs.setSummary(mHwCodecs.getEntry());
                FileUtils.setStringProp(HWCODECS_SYSTEM_PROPERTY, (String) value);
                break;

            case PREF_TCP:
                mTCP.setValue((String) value);
                mTCP.setSummary(mTCP.getEntry());
                FileUtils.setStringProp(TCP_SYSTEM_PROPERTY, (String) value);
                break;

            case PREF_WIFI80:
                mWiFi80.setValue((String) value);
                mWiFi80.setSummary(mWiFi80.getEntry());
                FileUtils.setStringProp(WIFI80_SYSTEM_PROPERTY, (String) value);
                break;

            case PREF_USB:
                FileUtils.setProp(USB_SYSTEM_PROPERTY, (Boolean) value);
                break;

            case PREF_FORCE64:
                FileUtils.setProp(FORCE64_SYSTEM_PROPERTY, (Boolean) value);
                break;

            case PREF_DISABLE_VSYNC:
                mDisableVSYNC.setValue((String) value);
                mDisableVSYNC.setSummary(mDisableVSYNC.getEntry());
                FileUtils.setStringProp(VSYNC_SYSTEM_PROPERTY, (String) value);
                break;
            
            case PREF_LATCH_UNSIGNALED:
                FileUtils.setProp(LATCH_UNSIGNALED_SYSTEM_PROPERTY, (Boolean) value);
                break;

            case PREF_PQ:
                FileUtils.setProp(PQ_SYSTEM_PROPERTY, (Boolean) value);
                break;

            case PREF_HW_OVERLAYS:
                FileUtils.setProp(HW_OVERLAYS_SYSTEM_PROPERTY, (Boolean) value);
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
