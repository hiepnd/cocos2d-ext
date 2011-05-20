//
//  LoadingContext.h
//  save_me2
//
//  Created by Hoang Minh Quan on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCContext.h"
#import "AppDirector.h"

@interface LoadingContext : CCContext {	
	CCSprite *logo;
	BOOL logoonly;
}
/** If you have nothing to load in loadResources, set this property to YES */
@property BOOL showLogoOnly;

- (id) init;
- (void) loadResources;
- (void) loadDone;
- (void) home;

//TODO: Next release
- (void) setPercentComplete:(int) percent;
@end
