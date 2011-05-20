//
//  Global.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "Utils.h"

#define APP_CONFIG_FILE			@"config.plist"
#define APP_HIGHSCORE_FILE		@"highscore.plist"

@class AppController;

@interface Global : NSObject {

}
+ (AppController *) appDelegate;
+ (Config *) config;
+ (Config *) highscore;

//Copy config files from bundle to Document director, called in app delegate
+ (void) loadConfig;
@end
