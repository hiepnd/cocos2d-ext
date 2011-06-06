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

#import "HomeMenu.h"


@implementation HomeMenu
@synthesize delegate = _delegate;
- (id) init{
	self = [super init];
	CCMenu *menu = [CCMenu menuWithItems:nil];
	CCMenuItemFont *item;
	
	[CCMenuItemFont setFontSize:17];
	//Joints
	item = [CCMenuItemFont itemFromString:@"Test Joint nodes" target:self selector:@selector(menuItemActivate:)];
	item.tag = kHomeMenuJoint;
	item.position = ccp(-120,80);
	[item.label setColor:ccBLACK];
	[menu addChild:item];
	
	//Ragdoll
	item = [CCMenuItemFont itemFromString:@"Ragdoll" target:self selector:@selector(menuItemActivate:)];
	item.tag = kHomeMenuRagdoll;
	item.position = ccp(-120,50);
	[item.label setColor:ccBLACK];
	[menu addChild:item];
	
	//Ragdoll
	item = [CCMenuItemFont itemFromString:@"Test Follow" target:self selector:@selector(menuItemActivate:)];
	item.tag = kHomeMenuFollow;
	item.position = ccp(120,80);
	[item.label setColor:ccBLACK];
	[menu addChild:item];
	
	//Ragdoll
	item = [CCMenuItemFont itemFromString:@"Simple Game" target:self selector:@selector(menuItemActivate:)];
	item.tag = kHomeMenuAllInOne;
	item.position = ccp(120,50);
	[item.label setColor:ccBLACK];
	[menu addChild:item];
	
	
	[self addChild:menu];
	
	return self;
}

- (void) menuItemActivate:(CCMenuItem *) item{
	if ([_delegate respondsToSelector:@selector(homeMenu:didActivateItemTag:)]) {
		[_delegate homeMenu:self didActivateItemTag:item.tag];
	}
}

@end
