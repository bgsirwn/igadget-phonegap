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

//
//  AppDelegate.m
//  phonegap-ios
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <Cordova/CDVPlugin.h>


@implementation AppDelegate

@synthesize invokeString, launchNotification, snid, appState;

@synthesize window, viewController;


- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
#if __has_feature(objc_arc)
        NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
#else
        NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
#endif
    [NSURLCache setSharedURLCache:sharedCache];
    
    return [super init];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushMessage
{
    NSString *key = @"aps";
    NSString *value = [pushMessage objectForKey:key];
    
    
    NSString *message = [pushMessage descriptionWithLocale:nil indent: 1];
    
    NSLog(@"The message string is %@",message);
    
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Remote Notification" message: message delegate: nil cancelButtonTitle: @"ok" otherButtonTitles: nil];
    
    [alert show];
    [alert release];
     */
    
    [self showAlert:pushMessage];

}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

#if __has_feature(objc_arc)
        self.window = [[UIWindow alloc] initWithFrame:screenBounds];
#else
        self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
#endif
    self.window.autoresizesSubviews = YES;

#if __has_feature(objc_arc)
        self.viewController = [[MainViewController alloc] init];
#else
        self.viewController = [[[MainViewController alloc] init] autorelease];
#endif
    self.viewController.useSplashScreen = YES;
    
    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
    // self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url && [url isKindOfClass:[NSURL class]]) {
        NSLog(@"Cordova2.1Sample launchOptions = %@", url);
    }
    self.launchNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"app starting with notif? %@", self.launchNotification);
    if(self.launchNotification != nil)
    {
        self.snid = [launchNotification objectForKey:@"SN"];
        //[[XLappMgr get] insertSimpleAck:snid];
        self.appState = @"Passive-off";
        [self storeNotificationForLaunch];
    }
    
    
    //MW ADDED: ADD THE APP COOKIE

    NSString *cookieName = @"mw-phonegap-ios";
    NSString *cookieVal = @"true";
    NSString* stringURL = self.viewController.startPage;
    NSURL* server_url = [NSURL URLWithString:stringURL];
    
    
    NSHTTPCookie *cook = [NSHTTPCookie cookieWithProperties:
                          [NSDictionary dictionaryWithObjectsAndKeys:
                           [server_url host], NSHTTPCookieDomain,
                           [server_url path], NSHTTPCookiePath,
                           cookieName,  NSHTTPCookieName,
                           cookieVal, NSHTTPCookieValue,
                           nil]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cook];
    
    
 
    return YES;
}



-(void) showAlert:(NSDictionary *) push{
    self.launchNotification = push;

    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSDictionary *pusdic = [push objectForKey:@"aps"];
    NSString *alertValue = [pusdic objectForKey:@"alert"];
    NSString *prodName = [[NSString alloc]initWithString:[info objectForKey:@"CFBundleDisplayName"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prodName message: alertValue delegate: nil cancelButtonTitle: @"ok" otherButtonTitles: nil];
    
    [alert show];
    [alert release];

    alreadyHandlingNotification = true;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        alreadyHandlingNotification = false;
    }
    else if (buttonIndex == 1)
    {
        [self sendPayloadToWebView];
        alreadyHandlingNotification = false;
    }
}

- (void) sendPayloadToWebView
{
}

- (void) storeNotificationForLaunch{
    if (launchNotification) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:launchNotification forKey:@"notif"];
    }
}

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

- (NSString*) pathForResource:(NSString*)resourcepath;
{
    return [self.viewController pathForResource:resourcepath];
}

- (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    return;
}

- (void)webViewDidStartLoad:(UIWebView *)theWebView
{
    return [ self.viewController webViewDidStartLoad:theWebView ];
}

/**
 * Fail Loading With Error
 * Error - If the webpage failed to load display an error with the reason.
 */
- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
    return [ self.viewController webView:theWebView didFailLoadWithError:error ];
}

/**
 * Start Loading Request
 * This is where most of the magic happens... We take the request(s) and process the response.
 * From here we can redirect links and other protocols to different internal methods.
 */
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [ self.viewController webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
}

- (BOOL) execute:(CDVInvokedUrlCommand*)command
{
    return [self.viewController execute:command];
}






// this happens while we are running ( in the background, or from within our own app )
// only valid if phonegap-ios-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }

    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];

    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];

    return YES;
}

// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void)            application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end

/*
//Added to allow HTTPS requests, remove when SSL cert is added
@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
*/
