//
//  AppNotification.h
//  SugarCRM
//
//  Created by Ngo Duc Hiep on 8/13/10.
//  Copyright 2010 PTT Solution,. JSC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAppNotificationScoreUpdated					@"kAppNotificationScoreUpdated"
#define kAppNotificationLeaderboardUpdated				@"kAppNotificationLeaderboardUpdated"

#define kAppNotificationShakeEvent						@"kAppNotificationShakeEvent"

@interface AppNotification : NSObject {
	
}
+ (NSNotificationCenter *) center;
+ (void) addObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)sender;
+ (void) removeObserver:(id)observer name:(NSString *)name object:(id)sender;
+ (void) postNotification:(NSString *)name object:(id)sender userInfo:(NSDictionary *)userInfo;
@end
