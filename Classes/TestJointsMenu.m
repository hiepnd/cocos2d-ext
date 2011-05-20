//
//  TestJointsMenu.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/4/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "TestJointsMenu.h"


@implementation TestJointsMenu

- (id) init{
	self = [super init];
	
	CCMenuItem *item;
	float dy = 28;
	float y = 100;
	
	
	/** Distance test Item  */
	item = [CCMenuItemFont itemFromString:@"Distance" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestDistance;
	item.position = ccp(0,y);
	[_menu addChild:item];
	
	/** Revolute Item  */
	item = [CCMenuItemFont itemFromString:@"Revolute" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestRevolute;
	item.position = ccp(0,y-1*dy);
	[_menu addChild:item];
	
	/** Pulley Item  */
	item = [CCMenuItemFont itemFromString:@"Pulley" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestPulley;
	item.position = ccp(0,y-2*dy);
	[_menu addChild:item];
	
	/** Prismatic Item  */
	item = [CCMenuItemFont itemFromString:@"Prismatic" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestPrismatic;
	item.position = ccp(0,y-3*dy);
	[_menu addChild:item];
	
	/** Line Item  */
	item = [CCMenuItemFont itemFromString:@"Line" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestLine;
	item.position = ccp(0,y-4*dy);
	[_menu addChild:item];
	
	/** Weld Item  */
	item = [CCMenuItemFont itemFromString:@"Weld" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestWeld;
	item.position = ccp(0,y-5*dy);
	[_menu addChild:item];
	
	/** Oto Item  */
	item = [CCMenuItemFont itemFromString:@"Oto" target:self selector:@selector(menuItemActivate:)];
	item.tag = kMenuItemTestOto;
	item.position = ccp(0,y-6*dy);
	[_menu addChild:item];
	
	return self;
}

- (void) setTestLabel:(NSString *) label{
	[_testLabel setString:label];
}
@end
