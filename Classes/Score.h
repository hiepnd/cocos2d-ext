//
//  Score.h
//  ___PROJECTNAME___
//
//  Created by Ngo Duc Hiep on 3/16/11.
//  Copyright 2011 PTT Solution., JSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject {
	NSString	*_name;
	int			_score;
	int64_t		_value;
	NSDate		*_date;
	NSString	*_category;
	id			_more;
}
@property(retain) NSString *name;
@property int64_t value;
@property int rank;
@property(retain) NSDate *date;
@property(retain) NSString *category;
@property(retain) id more;

+ (id) score;
@end
