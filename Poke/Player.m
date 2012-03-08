//
//  Player.m
//  Poke
//
//  Created by Macbook Pro on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Transaction.h"

@implementation Player

@synthesize name;
@synthesize balance;
@synthesize transactions;

-(BOOL)isEqual:(Player *)playerOther
{
	return ([name isEqual:playerOther.name] &&
			balance == playerOther.balance);
}

#pragma mark -
#pragma mark Initializers

+(id)playerWithName:(NSString *)playerName;
{
	Player *playerNew = [[Player alloc] initWithName:playerName];
	
	return playerNew;
}

-(id)initWithName:(NSString *)playerName
{
	if ( (self = [super init]) )
	{
		// set the name
		self.name = playerName;
		
		// set the balance
		balance = 0;
		
		// create transactions
		transactions = [[NSMutableArray alloc] initWithCapacity:20];
	}
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
	
	[name release];
	[transactions release];
}

#pragma mark -
#pragma mark Balance Management

-(float)balanceFromDate:(NSTimeInterval)dateStart toDate:(NSTimeInterval)dateEnd
{
	float amount = 0.0;
	
	for (Transaction *transaction in transactions)
	{
		NSTimeInterval dateTrans = [transaction.timeStamp timeIntervalSinceReferenceDate];
		
		if (dateTrans >= dateStart && dateTrans <= dateEnd)
			amount += [transaction netAmount];
	}
	
	return amount;
}

#pragma mark -
#pragma mark Transaction Management

-(void)processTransaction:(Transaction *)transaction
{
	// add it to the player's balance
	balance += [transaction netAmount];
	
	// add it to the player's transaction history
	[transactions addObject:transaction];
}

-(void)deleteTransaction:(Transaction *)transaction
{
	// reverse the balance change
	balance -= [transaction netAmount];
	
	// remove it from the player's transaction history
	[transactions removeObject:transaction];
}

#pragma mark -
#pragma mark Saving/Loading

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:name forKey:@"Player.name"];
	[aCoder encodeFloat:balance forKey:@"Player.balance"];
	[aCoder encodeObject:transactions forKey:@"Player.transactions"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		name = [aDecoder decodeObjectForKey:@"Player.name"];
		balance = [aDecoder decodeFloatForKey:@"Player.balance"];
		transactions = [aDecoder decodeObjectForKey:@"Player.transactions"];
	}
	return self;
}

@end
