//
//  ContextDirector.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/6/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#import "Config.h"

@class CCContext;

@interface ContextDirector : NSObject {
	NSMutableArray *_stack;
	CCDirector *_ccDirector;
	
	bool attached;
	
	int stage;
	
	CCContext *_runningContext;
}
@property int stage;

- (void) pause;
- (void) resume;
- (void) attachInWindow:(UIWindow *) window;
- (void) attachInView:(UIView *) view;
- (void) runWithContext:(CCContext *) context;
- (void) pushContext:(CCContext *) context;
- (void) popContext;
- (void) replaceContext:(CCContext *) context;
- (CCContext *) runningContext;

#if NS_BLOCKS_AVAILABLE
- (void) pushContext:(CCContext *)context withTransitionBlock:(CCScene * (^)(CCScene * scene)) block;
- (void) replaceContext:(CCContext *)context withTransitionBlock:(CCScene * (^)(CCScene * scene)) block;
#endif
@end
