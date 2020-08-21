package com.redmi.xiaomiparts;

import android.app.ActivityManager;
import android.content.Intent;
import android.os.Handler;
import android.content.Context;
import android.os.Bundle;
import android.service.quicksettings.Tile;
import android.service.quicksettings.TileService;

import com.redmi.xiaomiparts.R;

// TODO: Add Mi drawables
public class MiTileService extends TileService {

    @Override
    public void onStartListening() {


	boolean enhancerEnabled;
        try {
            enhancerEnabled = MiService.sMiUtils.isMiEnabled();
        } catch (java.lang.NullPointerException e) {
            try {
		getApplicationContext().startService(new Intent(getApplicationContext(), MiService.class));
                enhancerEnabled = MiService.sMiUtils.isMiEnabled();
            } catch (NullPointerException ne) {
                // Avoid crash
                ne.printStackTrace();
                enhancerEnabled = false;
            }
        }

        Tile tile = getQsTile();
        if (enhancerEnabled) {
            tile.setState(Tile.STATE_ACTIVE);
        } else {
            tile.setState(Tile.STATE_INACTIVE);
        }

        tile.updateTile();

        super.onStartListening();
    }

    @Override
    public void onClick() {
        Tile tile = getQsTile();
	if (MiService.sMiUtils.isMiEnabled()) {
	    getApplicationContext().stopService(new Intent(getApplicationContext(), MiService.class));
            MiService.sMiUtils.setEnabled(false);
            tile.setState(Tile.STATE_INACTIVE);
        } else {
	    getApplicationContext().startService(new Intent(getApplicationContext(), MiService.class));
            MiService.sMiUtils.setEnabled(true);
            tile.setState(Tile.STATE_ACTIVE);
        }
        tile.updateTile();
        super.onClick();
    }
}
