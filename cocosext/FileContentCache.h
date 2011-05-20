//
//  FileContentChache.h
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/5/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FileContentCache : NSObject {
	NSMutableDictionary *defs;
}

+ (FileContentCache *) cache;
- (id) content:(NSString *) path;
- (id) contentInBundle:(NSString *) filename;
- (id) contentInDocument:(NSString *) filename;
- (void) remove:(NSString *) path;
- (void) removeUnusedDef;
- (void) removeAll;
@end
