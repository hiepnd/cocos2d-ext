//
//  RagdollContext.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/28/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ragdoll.h"
#import "SimpleMenu.h"
#import "CCSlider.h"

enum {
	rStatePlaying,
	rStatePause,
};

#define RAGDOLL_GROUP 1

@interface RagdollContext : CCContext<SimpleMenuDelegate> {
	int _state;
	b2MouseJoint *_mouse;
	b2Body *_static;
	Ragdoll *doll;
	
	CCJointNode *_mouseNode;
	
	float _scale_;
	
	CCSlider *_slider;
	CCLabelTTF *_label;
}
- (Ragdoll *) addRagdollAt:(CGPoint) pos;

- (void) pause;
- (void) resume;
@end
