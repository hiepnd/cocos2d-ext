//
//  TestJointsMenu.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 4/4/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleMenu.h"

enum  {
	//Test menu item
	kMenuItemTestDoNotUse = kSimpleMenuDynamicRestart,
	kMenuItemTestDistance,
	kMenuItemTestRevolute,
	kMenuItemTestPrismatic,
	kMenuItemTestPulley,
	kMenuItemTestLine,
	kMenuItemTestWeld,
	kMenuItemTestOto,
};

@interface TestJointsMenu : SimpleMenu {
	CCLabelTTF *_testLabel;
}
- (void) setTestLabel:(NSString *) label;
@end
