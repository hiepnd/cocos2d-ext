//
//  HomeMenu.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

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
