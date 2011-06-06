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
