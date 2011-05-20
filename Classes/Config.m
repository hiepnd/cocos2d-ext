//
//  Configuration.m
//  Sqlite
//
//  Created by Tutv on 3/24/10.
//  Copyright 2010 PTT Solution,. JSC. All rights reserved.
//

#import "Config.h"
#import "NSData+CommonCrypto.h"
#import "GameSound.h"

static NSMutableDictionary *_instances = nil;

@interface Config(Private)
- (NSArray *) keyComponents:(NSString *) key;
@end

@implementation Config(Private)

- (NSArray *) keyComponents:(NSString *) key{
	NSMutableArray *components = [NSMutableArray array];
	NSArray *keys = [key componentsSeparatedByString:@"/"];
	
	if ([keys count] > 0) {
		for (int i = 0; i < [keys count]; i++) {
			NSString *s = [[keys objectAtIndex:i] stringByReplacingOccurrencesOfString:@" " withString:@""];
			if ([s length] > 0) {
				[components addObject:s];
			}
		}
	}
	
	return components;
}
@end


@implementation Config
@synthesize dataChanged, saveOnChanged, path;

+ (id) instanceForFile:(NSString *) file{
	if(_instances == nil)
		_instances = [[NSMutableDictionary alloc] init];
	if([_instances objectForKey:file] != nil)
		return [_instances objectForKey:file];
	
	Config *obj = (Config *)[[Config alloc] initWithFile:file];
	if(obj != nil){
		[_instances setObject:obj forKey:file];
		[obj release];
		return obj;
	}
	return nil;
}

+ (void) removeInstanceForFile:(NSString *) file{
	if(_instances != nil)
		[_instances removeObjectForKey:file];
}

+ (void) removeAllInstance{
	if(_instances != nil)
		[_instances removeAllObjects];
}

+ (void) removeInstance:(Config *) instance{
	if(_instances == nil)
		return;
	NSString *p = nil;
	NSArray *keys = [_instances allKeys];
	for (NSString *pp in keys) {
		if([_instances objectForKey:pp] == instance){
			p = pp;
			break;
		}
	}
	if(p != nil)
		[self removeInstanceForFile:p];
}

+ (void) saveAll{
	for(Config *cf in _instances)
		[cf save];
}

- (BOOL) save{
	if ([self save:path]) {
		dataChanged = NO;
		return YES;
	}
	
	return NO;
}

- (BOOL) save:(NSString *) path_{
	NSString *errorMsg = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:config format:NSPropertyListBinaryFormat_v1_0 errorDescription:&errorMsg];
	if(errorMsg != nil){
		NSLog(@"Configuration@(save) : Cannot get data from plist -- %@",errorMsg);
		[errorMsg release];
		return FALSE;
	}
	NSError *err;
	BOOL ok;
	ok = [data writeToFile:path_ options:0 error:&err];
	if(!ok){
		NSLog(@"Configuration@(save) : Cannot save data at %@ -(%@)",path_,err);
		return FALSE;
	}
	
	return TRUE;
}

- (void) deleteFile{
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (id) initWithFile:(NSString *)fpath
{
	NSFileManager *fm = [NSFileManager defaultManager];
	if(![fm fileExistsAtPath:fpath]){
		NSLog(@"Configuration@(initWithFile:) : %@ does not exist, function return nil",fpath);
		return nil;
	}
	path = 	[fpath retain];
	config = [[Config readPlistFileAtPath:fpath] retain];
	saveOnChanged = FALSE;
	
	return self;
} 

- (void) dealloc{
	[path release];
	[config release];
	[super dealloc];
}

- (void) print{
	NSLog(@"%@",config);	
}

- (void) remove:(NSString *) key{
	NSArray *keys = [self keyComponents:key];
	if ([keys count] == 0) {
		[config release];
		config = [[NSMutableDictionary alloc] init];
		return;
	}
	
	NSMutableDictionary *parent = config;
	for (int i = 0; i < [keys count] - 1; i ++) {
		if ([parent isKindOfClass:[NSMutableDictionary class]]) {
			parent = [parent objectForKey:[keys objectAtIndex:i]];
		}else{
			NSLog(@"Config: @(remove:) - Parent is not a mutable dictionary");
			return;
		}
	}
	
	[parent removeObjectForKey:[keys lastObject]];
}

#pragma mark Setter
- (void) set:(id) value forKey:(NSString *) key{
	if(value == nil || key == nil)
		return;
	
	NSArray *keys = [self keyComponents:key];
		
	//Set the entire config;
	if([keys count] == 0){
		[config release];
		config = [value mutableCopy];
		if(saveOnChanged)
			[self save];
		else
			dataChanged = TRUE;
		return;
	}
	
	NSMutableDictionary *parent = config;
	NSMutableString *xkey = [NSMutableString stringWithString:@"/"];
	for (int i = 0 ; i < [keys count] - 1; i++) {
		if([parent isKindOfClass:[NSMutableDictionary class]]){
			NSMutableDictionary *child = [parent objectForKey:[keys objectAtIndex:i]];
			if (child == nil) {
				[parent setObject:[NSMutableDictionary dictionary] forKey:[keys objectAtIndex:i]];
				child = [parent objectForKey:[keys objectAtIndex:i]];
			}
			parent = child;
		}
		else{
			NSLog(@"Configuration@(set:forKey:) object at key path \"%@\" is not mutable",xkey);
			return;
		}
		[xkey appendFormat:@"%@/",[keys objectAtIndex:i]];
	}
	
	
	if([parent isKindOfClass:[NSMutableDictionary class]]){
		[parent setObject:[[value mutableCopy] autorelease] forKey:[keys objectAtIndex:[keys count]-1]];
		if(saveOnChanged)
			[self save];
		else
			dataChanged = TRUE;	
	}
	else {
		NSLog(@"Configuration@(set:forKey:) object at key path \"%@%@\" is not mutable",xkey,[keys objectAtIndex:[keys count]-1]);
	}
}


- (void) setInt:(int) value forKey:(NSString *) key{
	[self set:[NSString stringWithFormat:@"%d",value] forKey:key];
}

- (void) setBool:(BOOL) value forKey:(NSString *) key{
	[self set:[NSString stringWithFormat:@"%d",value] forKey:key];
}

- (void) setFloat:(float) value forKey:(NSString *) key{
	[self set:[NSString stringWithFormat:@"%f",value] forKey:key];
}

- (void) setCGPoint:(CGPoint) value forKey:(NSString *) key{
	[self set:NSStringFromCGPoint(value) forKey:key];
}

- (void) setCGRect:(CGRect) value forKey:(NSString *) key{
	[self set:NSStringFromCGRect(value) forKey:key];
}

- (void) setDate:(NSDate *) value	forKey:(NSString *) key{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[formatter setTimeStyle:NSDateFormatterFullStyle];
	[self set:[formatter stringFromDate:value] forKey:key];
	[formatter release];
}

#pragma mark Getter
- (id) get:(NSString *) key{
	if(key == nil)
		return nil;
	
	NSArray *listKey = [self keyComponents:key];
	id value = config;
	
	if([key length] == 0)
		return config;
	
	for( int i = 0; i < [listKey count]; i++)
	{			
		if([value isKindOfClass:[NSMutableDictionary class]]){
			value = [value objectForKey:[listKey objectAtIndex:i]];
		}
		else
			return nil;
	}
	
	return value;
}

- (int) getInt:(NSString *) key{
	return [[self get:key] intValue];
}

- (float) getFloat:(NSString *) key{
	return [[self get:key] floatValue];
}

- (BOOL) getBool:(NSString *) key{
	return [[self get:key] boolValue];
}

- (CGPoint) getCGPoint:(NSString *) key{
	return CGPointFromString([self get:key]);
}

- (CGRect) getCGRect:(NSString *) key{
	return CGRectFromString([self get:key]);
}

- (NSDate *) getDate:(NSString *) key{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter autorelease];
	[formatter setTimeZone:[NSTimeZone systemTimeZone]];
	[formatter setDateStyle:NSDateFormatterFullStyle];
	[formatter setTimeStyle:NSDateFormatterFullStyle];
	
	return [formatter dateFromString:[self get:key]];
}

#pragma mark ABCD
+ (NSMutableDictionary *) readPlistFileAtPath:(NSString *) path_{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path_];
	NSMutableDictionary *temp = (NSMutableDictionary *)[NSPropertyListSerialization
										  propertyListFromData:plistXML
										  mutabilityOption:NSPropertyListMutableContainersAndLeaves
										  format:&format errorDescription:&errorDesc];
	
	if (!temp) {
		NSLog(@"Configuration@(readPlistFileAtPath):Cannot read plist file at %@",path_);
		[errorDesc release];
		return nil;
	}	
	return temp;
}

#pragma mark Encryption
+ (NSMutableDictionary *) readPlistFileAtPath:(NSString *) path_ key:(id) key{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path_];
	NSData *data = [plistXML decryptedAES256DataUsingKey:key error:nil];
	NSMutableDictionary *temp = (NSMutableDictionary *)[NSPropertyListSerialization
														propertyListFromData:data
														mutabilityOption:NSPropertyListMutableContainersAndLeaves
														format:&format errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Configuration@(readPlistFileAtPath):Cannot read plist file at %@",path_);
		//[errorDesc release];
		return nil;
	}	
	return temp;
}

+ (id) instanceForFile:(NSString *) file key:(id) key{
	if(_instances == nil)
		_instances = [[NSMutableDictionary alloc] init];
		if([_instances objectForKey:file] != nil)
			return [_instances objectForKey:file];
	
	Config *obj = (Config *)[[Config alloc] initWithFile:file key:key];
	if(obj != nil){
		[_instances setObject:obj forKey:file];
		[obj release];
		return obj;
	}
	return nil;
}

- (id) initWithFile:(NSString *)fpath key:(id) key_{
	NSFileManager *fm = [NSFileManager defaultManager];
	if(![fm fileExistsAtPath:fpath]){
		NSLog(@"Configuration@(initWithFilePath:) : %@ does not exist, function return nil",fpath);
		return nil;
	}
	path = 	[fpath retain];
	config = [[Config readPlistFileAtPath:fpath key:key_] retain];
	saveOnChanged = FALSE;
	encrypted = YES;
	ekey = [key_ retain];
	
	return self;
}
@end