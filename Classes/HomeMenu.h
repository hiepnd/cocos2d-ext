//
//  HomeMenu.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/1/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCSlider.h"

@class HomeMenu;

enum  {
	kHomeMenuJoint,
	kHomeMenuRagdoll,
	kHomeMenuFollow,
	kHomeMenuAllInOne,
};

@protocol HomeMenuDelegate
@optional 
- (void) homeMenu:(HomeMenu *) menu didActivateItemTag:(int) tag;
@end

@interface HomeMenu : CCLayer {
	NSObject<HomeMenuDelegate> *_delegate;
}
@property(assign) NSObject<HomeMenuDelegate> *delegate;
@end
