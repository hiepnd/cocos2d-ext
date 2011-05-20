//
//  Score.m
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import "Score.h"


@implementation Score
@synthesize name = _name;
@synthesize value = _value;
@synthesize category = _category;
@synthesize date = _date;
@synthesize rank = _rank;
@synthesize more = _more;

+ (id) score{
	return [[[self alloc] init] autorelease];
}



- (void) dealloc{
	[_more release];
	[_name release];
	[_category release];
	[_date release];
	[super dealloc];
}
@end
