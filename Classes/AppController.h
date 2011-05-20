//
//  AppController.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © 2011 PTT Solution., JSC . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDirector.h"
#import "Global.h"

#define  POST_APP_STATE_CHANGE FALSE

@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}
@property (readonly) RootViewController	*rootViewController;
@property (nonatomic, retain) UIWindow *window;

@end
