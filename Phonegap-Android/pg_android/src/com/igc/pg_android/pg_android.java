/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package com.igc.pg_android;

import android.os.Bundle;
import org.apache.cordova.*;

import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;



import com.urbanairship.AirshipConfigOptions;
import com.urbanairship.UAirship;
import com.urbanairship.push.PushManager;

import com.urbanairship.AirshipConfigOptions;
import com.urbanairship.Logger;
import com.urbanairship.UAirship;
import com.urbanairship.push.CustomPushNotificationBuilder;
import com.urbanairship.push.PushManager;


public class pg_android extends DroidGap
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        //MW added: Set app cookie 
        CookieSyncManager.createInstance(getContext());

        CookieManager cookieManager = CookieManager.getInstance();
        
        cookieManager.setCookie(Config.getStartUrl(), "mw-phonegap-android=true");
        		
        CookieSyncManager.getInstance().sync();
        
        
        super.loadUrl(Config.getStartUrl());
        
        //MW added: Initialize Urban Airship; Push disabled by default; enable in mobile app
        AirshipConfigOptions options = AirshipConfigOptions.loadDefaultOptions(this);
        
        UAirship.takeOff(this.getApplication(),options);
        if (UAirship.shared().getAirshipConfigOptions().pushServiceEnabled) {
            PushManager.disablePush();
            PushManager.shared().setIntentReceiver(PushNotificationPluginIntentReceiver.class);
        }
    }
   
}

