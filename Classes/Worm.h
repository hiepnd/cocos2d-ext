//
//  Worm.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 5/13/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d+ext.h"
#include <list>

using namespace std;

@interface Worm : CCNode {
	list<CGPoint> trailPoints;
	NSMutableArray *trails;
}

- (void) pushTrail:(CCNode *) node;
- (void) popTrail;
@end
