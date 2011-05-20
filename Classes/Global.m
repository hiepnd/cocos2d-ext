//
//  Global.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#import "AppController.h"

@implementation Global
+ (AppController *) appDelegate{
	return (AppController *) [[UIApplication sharedApplication] delegate];
}

+ (Config *) config{
	return [Config instanceForFile:[Utils pathForFileInDocument:APP_CONFIG_FILE]];
}

+ (Config *) highscore{
	return [Config instanceForFile:[Utils pathForFileInDocument:APP_HIGHSCORE_FILE]];	
}

+ (void) loadConfig{
	//Copy config file if needed
	NSString *dpath = [Utils pathForFileInDocument:APP_CONFIG_FILE];
	if (![Utils fileExist:dpath]) {
		[Utils copyFile:[Utils pathForFileInBundle:APP_CONFIG_FILE] to:dpath];
	}
	
	//Copy highscore file if needed
	dpath = [Utils pathForFileInDocument:APP_HIGHSCORE_FILE];
	if (![Utils fileExist:dpath]) {
		[Utils copyFile:[Utils pathForFileInBundle:APP_HIGHSCORE_FILE] to:dpath];
	}
}
@end
