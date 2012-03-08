//
//  Session.m
//  Poke
//
//  Created by Macbook Pro on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Session.h"
#import "Transaction.h"

@implementation Session

+(id)session
{
	return [[Session alloc] init];
}

-(id)init
{
	if ( (self = [super init]) )
	{
		transactions = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)addTransaction:(Transaction *)transaction
{
	[transactions addObject:transaction];
}

-(void)removeTransaction:(Transaction *)transaction
{
	[transactions removeObject:transaction];
}

-(Transaction *)transactionAtIndex:(int)index
{
	return [transactions objectAtIndex:index];
}

-(Transaction *)lastTransaction
{
	return [transactions lastObject];
}

-(int)numberOfTransactions
{
	return [transactions count];
}

-(NSString *)name
{
	if ([transactions count] == 0)
		return nil;
	
	NSDate *dateFirst	= [[transactions objectAtIndex:0] timeStamp];
	NSDate *dateLast	= [[transactions lastObject] timeStamp];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	// if it's been more than a week, use a long format
	if (YES || [dateLast timeIntervalSinceNow] > -604800/*(7*24*60*60)*/)
		[dateFormatter setDateFormat:@"EEE (dd/MM/yy)"];
	// otherwise, just use the weekday
	else
		[dateFormatter setDateFormat:@"EEEE"];
	
	NSString *dayFirst	= [dateFormatter stringFromDate:dateFirst];
	NSString *dayLast	= [dateFormatter stringFromDate:dateLast];
	
	// if the first and last transactions are on the same day
	if ([dayFirst isEqualToString:dayLast])
		return [dateFormatter stringFromDate:dateFirst];
	// if the session takes place within two or more days
	else
		return [NSString stringWithFormat:@"%@/%@", dayFirst, dayLast];
}

#pragma mark -
#pragma mark Saving/Loading

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:transactions forKey:@"Session.transactions"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		transactions = [aDecoder decodeObjectForKey:@"Session.transactions"];
	}
	
	return self;
}

@end
