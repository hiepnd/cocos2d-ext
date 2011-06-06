/*
 * cocos2d+ext for iPhone
 *
 * Copyright (c) 2011 - Ngo Duc Hiep
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

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
