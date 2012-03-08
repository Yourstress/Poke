//
//  Transaction.m
//  Poke
//
//  Created by Macbook Pro on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Transaction.h"
#import "Bank.h"

@implementation Transaction

@synthesize player;
@synthesize playerOther;
@synthesize type;
@synthesize amount;
@synthesize timeStamp;

#pragma mark -
#pragma mark Static methods

// returns a string describing a transaction
+(NSString *)stringFromTransaction:(TransactionType)t
{
	switch (t)
	{
		case TransactionTypeCashIn:			return @"Cash In (Deposit)";
		case TransactionTypeCashOut:		return @"Cash Out (Withdraw)";
		case TransactionTypeCoinIn:			return @"Coin In (Deposit)";
		case TransactionTypeCoinOut:		return @"Coin Out (Withdraw)";
		case TransactionTypeCashInCoinOut:	return @"Cash In > Coin Out";
		case TransactionTypeCoinInCashOut:	return @"Coin In > Cash Out";
		case TransactionTypeTransferFrom:
		case TransactionTypeTransferTo:		return @"Transfer";
			
		default:							return @"";
	}
}

#pragma mark -
#pragma mark Initializers

// initialize a regular transaction
+(id)transaction:(TransactionType)t amount:(float)a player:(Player *)p
{
	Transaction *transaction = [[Transaction alloc] initWithTransaction:t amount:a player1:p player2:nil];
	return transaction;
}

// initialize a transfer transaction
+(id)transaction:(TransactionType)t amount:(float)a player:(Player *)p1 playerOther:(Player *)p2
{
	Transaction *transaction = [[Transaction alloc] initWithTransaction:t amount:a player1:p1 player2:p2];
	return transaction;
}

// init
-(id)initWithTransaction:(TransactionType)t amount:(float)a player1:(Player *)p1 player2:(Player *)p2
{
	if ( (self = [super init]) )
	{
		// save the type
		type = t;
		
		// save the amount
		amount = a;
		
		// save the players
		self.player = p1;
		self.playerOther = p2;
		
		// slap on a timestamp
		self.timeStamp = [NSDate date];
	}
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
	
	[player release];
	[playerOther release];
	[timeStamp release];
}

#pragma mark -
#pragma mark Data

// get net amount
-(float)netAmount
{
	/*
	 TransactionTypeCashIn,			+amount
	 TransactionTypeCashOut,		-amount
	 TransactionTypeCoinIn,			+amount
	 TransactionTypeCoinOut,		-amount
	 TransactionTypeCashInCoinOut,	0
	 TransactionTypeCoinInCashOut,	0
	 TransactionTypeTransferFrom	+amount
	 TransactionTypeTransferTo		-amount
	 */
	
	if (type == TransactionTypeCashIn ||
		type == TransactionTypeCoinIn ||
		type == TransactionTypeTransferFrom)
		return amount;
	else if (type == TransactionTypeCashOut ||
			 type == TransactionTypeCoinOut ||
			 type == TransactionTypeTransferTo)
		return -amount;
	else
		return 0;
}

// get string from transaction
-(NSString *)stringFromTransactionAmount
{
	float netAmount = [Bank roundMinus:[self netAmount]];
	
	if (netAmount != 0.0)
		return [NSString stringWithFormat:@"%1.3f KD", netAmount];
	else
		return [NSString stringWithFormat:@"[%1.3f KD]", [Bank roundMinus:amount]];
}

// get string from transaction parties
-(NSString *)stringFromTransactionParties
{
	// player is SECOND party
	if (type == TransactionTypeCashIn ||
		type == TransactionTypeCoinIn)
	{
		return [NSString stringWithFormat:@"Bank>%@", [player name]];
	}
	// player is FIRST party
	else if (type == TransactionTypeCashOut ||
			 type == TransactionTypeCoinOut)
	{
		return [NSString stringWithFormat:@"%@>Bank", [player name]];
	}
	// player is SECOND party
	else if (type == TransactionTypeTransferFrom)
	{
		return [NSString stringWithFormat:@"%@>%@", [playerOther name], [player name]];
	}
	// player is FIRST party
	else if (type == TransactionTypeTransferTo)
	{
		return [NSString stringWithFormat:@"%@>%@", [player name], [playerOther name]];
	}
	
	return nil;
}

// get color from balance
-(UIColor *)colorFromBalance
{
	float netAmount = [self netAmount];
	
	if (netAmount > 0.0)
		return [UIColor colorWithRed:0.1 green:0.7 blue:0 alpha:1];
	else if (netAmount < 0.0)
		return [UIColor colorWithRed:0.87 green:0.11 blue:0.11 alpha:1];
	else
		return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
}

#pragma mark -
#pragma mark Timestamps

// returns a short timestamp
-(NSString *)shortTimeStamp
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehaviorDefault];
	[df setDateFormat:@"dd-mm-yy HH:mm"];
	
	NSString *stringDate = [df stringFromDate:timeStamp];
	
	[df release];
	
	return stringDate;
}

// returns a long timestamp
-(NSString *)longTimeStamp
{
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setFormatterBehavior:NSDateFormatterBehaviorDefault];
	[df setDateFormat:@"EEE, dd-mm-yy HH:mm"];
	
	NSString *stringDate = [df stringFromDate:timeStamp];
	
	[df release];
	
	return stringDate;
}

#pragma mark -
#pragma mark Saving/Loading

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:player forKey:@"Transaction.player"];
	[aCoder encodeObject:playerOther forKey:@"Transaction.playerOther"];
	[aCoder encodeInt:type forKey:@"Transaction.type"];
	[aCoder encodeFloat:amount forKey:@"Transaction.amount"];
	[aCoder encodeObject:timeStamp forKey:@"Transaction.timeStamp"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		self.player = [aDecoder decodeObjectForKey:@"Transaction.player"];
		self.playerOther = [aDecoder decodeObjectForKey:@"Transaction.playerOther"];
		type = [aDecoder decodeIntForKey:@"Transaction.type"];
		amount = [aDecoder decodeFloatForKey:@"Transaction.amount"];
		self.timeStamp = [aDecoder decodeObjectForKey:@"Transaction.timeStamp"];
	}
	return self;
}

@end
