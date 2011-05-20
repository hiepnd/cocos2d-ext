//
//  AppNotification.m
//  SugarCRM
//
//  Created by Ngo Duc Hiep on 8/13/10.
//  Copyright 2010 PTT Solution,. JSC. All rights reserved.
//

#import "AppNotification.h"


@implementation AppNotification

+ (void) addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)sender{
	[[self center] addObserver:observer selector:selector name:name object:sender];
}

+ (void) removeObserver:(id)observer name:(NSString *)name object:(id)sender{
	[[self center] removeObserver:observer name:name object:sender];
}

+ (void) postNotification:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo{
	[[self center] postNotificationName:name object:sender userInfo:userInfo];
}

+ (NSNotificationCenter *) center{
	return [NSNotificationCenter defaultCenter];
}
@end
