//
//  Ragdoll.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/28/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"

enum  {
	rdTagHead = 1,
	rdTagTorso1,
	rdTagTorso2,
	rdTagTorso3,
	rdTagUpperArmL,
	rdTagUpperArmR,
	rdTagLowerArmL,
	rdTagLowerArmR,
	rdTagUpperLegL,
	rdTagUpperLegR,
	rdTagLowerLegL,
	rdTagLowerLegR,
};

#define USING_NS_DIC 1

@interface RagdollConfig: NSObject
{
	float _scale;
	BOOL _scaleSprite;
	
	//Sprite
	NSString *_texture;
	NSString *_frames;
	NSString *_head;
	NSString *_torso1;
	NSString *_torso2;
	NSString *_torso3;
	NSString *_upplerArmL;
	NSString *_upplerArmR;
	NSString *_lowerArmL;
	NSString *_lowerArmR;
	NSString *_upplerLegL;
	NSString *_upplerLegR;
	NSString *_lowerLegL;
	NSString *_lowerLegR;	
}
@property float scale;
@property BOOL scaleSprite;
@property(retain) NSString *texture;
@property(retain) NSString *frames;
@property(retain) NSString *head;
@property(retain) NSString *torso1;
@property(retain) NSString *torso2;
@property(retain) NSString *torso3;
@property(retain) NSString *upplerArmL;
@property(retain) NSString *upplerArmR;
@property(retain) NSString *lowerArmL;
@property(retain) NSString *lowerArmR;
@property(retain) NSString *upplerLegL;
@property(retain) NSString *upplerLegR;
@property(retain) NSString *lowerLegL;
@property(retain) NSString *lowerLegR;	

+ (id) config;

@end


@interface Ragdoll : CCComponent {
	NSMutableDictionary *_segments;

	PhysicContext *_physicContext;
	b2Body *head;
	
	BOOL _useSheet;
	CCSpriteBatchNode *_batchNode;
}
- (id) initWithPhysicContext:(PhysicContext *) context;
+ (id) ragdollWithPhysicContext:(PhysicContext *) context;
- (id) initWithPhysicContext:(PhysicContext *) context config:(RagdollConfig *) config;
+ (id) ragdollWithPhysicContext:(PhysicContext *) context config:(RagdollConfig *) config;

- (b2Body *) getSegment:(int) tag;
@end
