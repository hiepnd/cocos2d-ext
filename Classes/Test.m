//
//  Test.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/29/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Test.h"
#import "Bomb.h"

@implementation TestNSvsSTL

+ (void) dotest{
	int TOTAL = 10000;
	NSTimeInterval t1,t2;
	//push TOTAL integer into NSArray
	NSMutableArray *ns = [NSMutableArray array];
	
	for (int i = 0; i < TOTAL; i++) {
		[ns addObject:[Bomb node]];
	}
	NSAssert([ns count] == TOTAL,@"1");
	
	t1 = [[NSDate date] timeIntervalSince1970];
	for (int i = 0; i < TOTAL; i++) {
		id k = [ns objectAtIndex:i];
	}
	
	t2 = [[NSDate date] timeIntervalSince1970];
	
	NSLog(@"T1=%f",t2-t1);
	
	
	list<Bomb *> l;
	
	for (int i = 0; i < TOTAL; i++) {
		l.push_back([Bomb node]);
	}
	NSAssert(l.size() == TOTAL,@"2");
	
	t1 = [[NSDate date] timeIntervalSince1970];
	list<Bomb *>::iterator it;
	for (it = l.begin(); it != l.end(); it++) {
		Bomb *k = *it;
		//NSLog(@"bomb: %@",k);
	}
	
	t2 = [[NSDate date] timeIntervalSince1970];
	
	NSLog(@"T2=%f",t2-t1);
}

@end
