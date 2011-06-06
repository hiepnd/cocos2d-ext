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

#import "FileContentCache.h"
#import "Utils.h"

FileContentCache *_instance = nil;

@interface FileContentCache(Private)
- (id) initInstance;
@end

@implementation FileContentCache(Private)

- (id) initInstance{
	self = [super init];
	defs = [[NSMutableDictionary alloc] init];
	
	return self;
}
@end

@implementation FileContentCache

- (id) init{
	NSAssert(FALSE, @"Don't touch me, use [ActorDefCache cache] instead");
	return nil;
}

+ (FileContentCache *) cache {
	if (_instance == nil) {
		@synchronized(self){
			_instance = [[FileContentCache alloc] initInstance];
		}
	}
	
	return _instance;
}

- (id) content:(NSString *) path {
	@synchronized(self){
		if ([defs objectForKey:path] == nil) {
			NSFileManager *manager = [NSFileManager defaultManager];
			if (![manager fileExistsAtPath:path]) {
				return nil;
			}
			NSData *data = [manager contentsAtPath:path];
			if (data == nil) {
				return nil;
			}
			id def = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:nil];
			[defs setObject:def forKey:path];
		}
	}
	return [defs objectForKey:path];
}

- (id) contentInBundle:(NSString *) filename{
	NSString *path = [Utils pathForFileInBundle:filename];
	return [self content:path];
}

- (id) contentInDocument:(NSString *) filename{
	NSString *path = [Utils pathForFileInDocument:filename];
	return [self content:path];
}

- (void) remove:(NSString *) path{
	@synchronized(self){
		[defs removeObjectForKey:path];
	}
}
- (void) removeUnusedDef{
	@synchronized(self){
		NSMutableArray *keys = [[NSMutableArray alloc] init];
		for (NSString *key in [defs allKeys]) {
			if ([[defs objectForKey:key] retainCount] == 1) {
				[keys addObject:key];
			}
			//NSLog(@"KKK: %d",[[defs objectForKey:key] retainCount]);
		}
		CCLOG(@"%@ remove %d/%d unused def",[self class], [keys count],[defs count]);
		[defs removeObjectsForKeys:keys];
		[keys release];
	}
}

- (void) removeAll{
	[defs removeAllObjects];
}
@end