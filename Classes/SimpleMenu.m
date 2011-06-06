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

#import "SimpleMenu.h"

@interface CCMenuItem(SimpleMenu)
- (void) setTaget:(id) target selector:(SEL) selector; 
@end

@implementation CCMenuItem(SimpleMenu)

- (void) setTaget:(id) target selector:(SEL) selector{
	if (invocation) {
		[invocation release];
	}
	
	NSMethodSignature * sig = nil;
	
	if( target && selector ) {
		sig = [target methodSignatureForSelector:selector];
		
		invocation = nil;
		invocation = [NSInvocation invocationWithMethodSignature:sig];
		[invocation setTarget:target];
		[invocation setSelector:selector];
#if NS_BLOCKS_AVAILABLE
		if ([sig numberOfArguments] == 3) 
#endif
			[invocation setArgument:&self atIndex:2];
		
		[invocation retain];
	}	
}
@end


@interface SimpleMenu(Private)
- (void) menuDidShow;
- (void) menuDidHide;
- (void) menuItemActivate:(CCMenuItem *) item;
@end

@implementation SimpleMenu(Private)
- (void) menuDidShow{
	_isAnimating = NO;
	_isShown = YES;
	if ([_delegate respondsToSelector:@selector(simpleMenuDidShow:)]) {
		[_delegate simpleMenuDidShow:self];
	}
}

- (void) menuDidHide{
	_isAnimating = NO;
	_isShown = NO;
	_menu.visible = NO;
	if ([_delegate respondsToSelector:@selector(simpleMenuDidHide:)]) {
		[_delegate simpleMenuDidHide:self];
	}
}

//Menu item callback
- (void) menuItemActivate:(CCMenuItem *) item{
	if ([_delegate respondsToSelector:@selector(simpleMenu:didActivateItemTag:)]) {
		[_delegate simpleMenu:self didActivateItemTag:item.tag];
	}
}
@end

@implementation SimpleMenu
@synthesize delegate = _delegate;
@synthesize dynamicMenu = _menu;
@synthesize isShown = _isShown;
@synthesize staticMenu = _staticMenu;
@synthesize showAnimation = _showAnimation;
@synthesize hideAnimation = _hideAnimation;
@synthesize animationTarget = _animationTarget;

- (id) init{
	self = [super init];
	isTouchEnabled_ = NO;
	
	_staticMenu = [CCMenu menuWithItems:nil];
	[self addChild:_staticMenu];
	
	CCMenuItem *item;
	[CCMenuItemFont setFontSize:25];
	/** Pause Item  */
	item = [CCMenuItemFont itemFromString:@"Menu" target:self selector:@selector(toggle)];
	item.tag = kSimpleMenuStaticPause;
	item.position = ccp(200,140);
	[_staticMenu addChild:item];
	
	_menu = [CCMenu menuWithItems:nil];
	_menu.position = ccp(_menu.position.x,_menu.position.y + 480);
	NSLog(@"mp=%@",NSStringFromCGPoint(_menu.position));
	[self addChild:_menu];
	
	//Home
	item = [CCMenuItemFont itemFromString:@"Home" target:self selector:@selector(menuItemActivate:)];
	item.tag = kSimpleMenuDynamicHome;
	item.position = ccp(-120,100);
	[_menu addChild:item];
	
	//Resume
	item = [CCMenuItemFont itemFromString:@"Resume" target:self selector:@selector(menuItemActivate:)];
	item.tag = kSimpleMenuDynamicResume;
	item.position = ccp(-120,100 - 28);
	[_menu addChild:item];
	
	//Resatrt
	item = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(menuItemActivate:)];
	item.tag = kSimpleMenuDynamicRestart;
	item.position = ccp(-120,100 - 56);
	[_menu addChild:item];
	
	self.showAnimation = [CCMoveBy actionWithDuration:.5 position:ccp(0,-480)];
	self.hideAnimation = [CCMoveBy actionWithDuration:.2 position:ccp(0,480)];
	self.animationTarget = _menu;
	
	return self;
}

- (void) dealloc{
	[_showAnimation release];
	[_hideAnimation release];
	[super dealloc];
}

- (void) toggle{
	if (_isAnimating) {
		return;
	}
	if (_isShown) {
		[self hide];
	}else {
		[self show];
	}
}

- (void) show{
	if (_isShown || _isAnimating) {
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(simpleMenuWillShow:)]) {
		[_delegate simpleMenuWillShow:self];
	}
	_isAnimating = YES;
	_menu.visible = YES;
	CCSequence *action = [CCSequence actions:
						  self.showAnimation,// [CCMoveBy actionWithDuration:.5 position:ccp(0,-480)],
						  [CCCallFunc actionWithTarget:self selector:@selector(menuDidShow)],
						  nil
						  ];
	[_animationTarget runAction:action];
}

- (void) showImmediately{
	if (!_isShown) {
		_menu.position = ccp(_menu.position.x,_menu.position.y - 480);
		_isShown = YES;
		_menu.visible = YES;
	}
}

- (void) hide{
	if (!_isShown || _isAnimating) {
		return;
	}
	
	if ([_delegate respondsToSelector:@selector(simpleMenuWillHide:)]) {
		[_delegate simpleMenuWillHide:self];
	}
	
	_isAnimating = YES;
	CCSequence *action = [CCSequence actions:
						  self.hideAnimation,// [CCMoveBy actionWithDuration:.5 position:ccp(0,480)],
						  [CCCallFunc actionWithTarget:self selector:@selector(menuDidHide)],
						  nil
						  ];
	[_animationTarget runAction:action];
}

- (void) hideImmediately{
	if (_isShown) {
		_menu.position = ccp(_menu.position.x,_menu.position.y + 480);
		_isShown = NO;
		_menu.visible = NO;
	}
}

/** Get the menu item by its tag  */
- (CCMenuItem *) staticMenuItemBytag:(int) tag{
	return (CCMenuItem *) [_staticMenu getChildByTag:tag];
}

- (CCMenuItem *) dynamicMenuItemBytag:(int) tag{
	return (CCMenuItem *) [_menu getChildByTag:tag];
}

- (void) addDynamicItem:(CCMenuItem *) item{
	[_menu addChild:item];
	[item setTaget:self selector:@selector(menuItemActivate:)];
}

- (void) addStaticItem:(CCMenuItem *) item{
	[_staticMenu addChild:item];
	[item setTaget:self selector:@selector(menuItemActivate:)];
}
@end
