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
#import "SimpleMenu.h"
#import "SneakyJoystick.h"
#import "SneakyJoystickSkinnedBase.h"
#import "ColoredCircleSprite.h"
#import "SneakyButton.h"
#import "SneakyButtonSkinnedBase.h"

enum OnGameMenuItemTag {
	kMenuItemDoNotUse = 1,
	kMenuItemResume,
	kMenuItemRestart,
	kMenuItemHome,
	kMenuItemBackgroundMusic,
	kMenuItemSoundFX,
	kMenuItemToggleBackground,
	
	kMenuItemMoveLeft,
	kMenuItemMoveRight,
	kMenuItemJump,
	
	kSimpleMenuDynamicAutoFire = kSimpleMenuDynamicRestart + 1,
	kSimpleMenuDynamicControlMode,
};

@interface OnGameMenu : SimpleMenu {
	CCLabelTTF *_score;	
	SneakyJoystick *_joyStick;
	SneakyButton *_rightButton;
}
@property(readonly) SneakyJoystick *joyStick;
@property(readonly) SneakyButton *rightButton;

- (void) setScore:(int) score;
- (void) hideJoystick:(BOOL) yesorno;
@end
