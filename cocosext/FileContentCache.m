//
//  FileContentChache.m
//  Penguins Destroyer
//
//  Created by Ngo Duc Hiep on 10/5/10.
//  Copyright 2010 PTT Solution., JSC. All rights reserved.
//

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