//
//  Bank.m
//  Poke
//
//  Created by Macbook Pro on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bank.h"
#import "Player.h"
#import "Standard.h"

@implementation Bank

@synthesize name;
@synthesize settings;
@synthesize balance;
@synthesize transactions;
@synthesize players;
@synthesize selectedPlayerIndex;

#pragma mark -
#pragma mark Static methods

+(NSString *)validateAmount:(NSString *)amount defaultAmount:(NSString *)defaultAmount
{
	if ([Bank validateString:amount withOptions:ValidationTypeCurrency])
	{
		float amt = [amount floatValue];
		
		// if it's more than 20 kd, pop up a confirmation
		if (amt >= 20.0)
			[Standard alertViewWithTitle:@"Big Transaction" message:@"You are about to make a transaction of over 20 KD." cancalButtonTitle:@"OK"];
		
		// make sure it's not in the minus, if it is, correct it
		if (amt < 0)
			amt = -amt;
		
		return [NSString stringWithFormat:@"%1.3f", amt];
	}
	else
	{
		[Standard alertViewWithTitle:@"Invalid Amount" message:@"The amount you have entered is not valid." cancalButtonTitle:@"OK"];
	}
	
	return defaultAmount;
}

+(BOOL)validateString:(NSString *)string withOptions:(ValidationType)validationType
{
	switch (validationType)
	{
		case ValidationTypeBankName:
		{
			// make sure the name is at least three characters long
			if ([string length] <= 2)
			{
				[Standard alertViewWithTitle:@"Invalid Name" message:@"The bank name must be at least three characters long." cancalButtonTitle:@"OK"];
				return NO;
			}
			
			// make sure the name doesn't start or end with a space
			if ([string characterAtIndex:0] == ' ' ||
				[string characterAtIndex:[string length]-1] == ' ')
			{
				[Standard alertViewWithTitle:@"Invalid Name" message:@"The bank name must not begin or end with white space." cancalButtonTitle:@"OK"];
				return NO;
			}
			
			return YES;
		}
		case ValidationTypePlayerName:
		{	
			// make sure the name is at least three characters long
			if ([string length] <= 2)
			{
				[Standard alertViewWithTitle:@"Invalid Name" message:@"The player name must be at least three characters long." cancalButtonTitle:@"OK"];
				return NO;
			}
			
			// make sure the name doesn't start or end with a space
			if ([string characterAtIndex:0] == ' ' ||
				[string characterAtIndex:[string length]-1] == ' ')
			{
				[Standard alertViewWithTitle:@"Invalid Name" message:@"The player name must not begin or end with white space." cancalButtonTitle:@"OK"];
				return NO;
			}
			
			return YES;
		}	
		case ValidationTypeCurrency:
		{
			// float to put the value in
			float amount;
			
			// scanner to scan the string into 'amount'
			NSScanner *scanner = [NSScanner scannerWithString:string];
			
			// make sure it's a float
			if (![scanner scanFloat:&amount])
				return NO;
			
			return YES;
		}
	}
	
	return NO;
}

+(NSString *)stringFromAmount:(float)amount
{
	return [NSString stringWithFormat:@"%1.3f KD", [Bank roundMinus:amount]];
}

+(UIColor *)colorFromAmount:(float)amount
{
	if (amount > 0)
		return [UIColor colorWithRed:0.1 green:0.7 blue:0 alpha:1];
	else if (amount < 0)
		return [UIColor colorWithRed:0.87 green:0.11 blue:0.11 alpha:1];
	else
		return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
}

+(float)roundMinus:(float)f
{
	return (f < 0.050 && f > -0.050) ? 0.0 : f;
}

#pragma mark -
#pragma mark Initializers

-(id)initWithName:(NSString *)bankName
{
    if ( (self = [super init]) )
	{
		// set name
		name = bankName;
		
		// initialize settings dictionary
		self.settings = [[NSMutableDictionary alloc] init];

			// set defaults
			[settings setValue:[NSNumber numberWithFloat:-5.0] forKey:BankSettingMinimumBalance];
		
		// zero out balance
		balance = 0;
		
		// initialize transactions
		self.transactions = [[NSMutableArray alloc] init];
		
		// initialize players array
		self.players = [[NSMutableArray alloc] init];
		
		// initialize selected player
		selectedPlayerIndex = -1;
	}
    
    return self;
}

-(void)dealloc
{
	[super dealloc];
	
	[settings release];
	[transactions release];
	[players release];
}

#pragma mark -
#pragma mark Player Getters

-(void)setSelectedPlayerIndex:(int)q
{
	selectedPlayerIndex = q;
}

-(Player *)playerAtIndex:(int)playerIndex
{
	return [players objectAtIndex:playerIndex];
}

-(Player *)playerFromName:(NSString *)playerName
{
	// look for a player with that name
	for (Player *player in players)
	{
		// if one was found, return it
		if ([player.name isEqualToString:playerName])
			return player;
	}
	
	// no player was found with that name
	return nil;
}

-(BOOL)playerExists:(NSString *)playerName
{
	// look for a player with that name
	for (Player *player in players)
	{
		// if one was found, return it
		if ([player.name isEqualToString:playerName])
			return YES;
	}
	
	// no player was found with that name
	return NO;
}

-(int)numberOfPlayers
{
	// return the number of players in the array
	return [players count];
}

#pragma mark -
#pragma mark Player Selection

-(Player *)selectedPlayer
{
	if (selectedPlayerIndex >= [players count])
		return nil;
	
	return [players objectAtIndex:selectedPlayerIndex];
}

-(void)selectPlayerAtIndex:(int)index
{
	if (index >= [self numberOfPlayers])
		selectedPlayerIndex = -1;
	else
		selectedPlayerIndex = index;
}

#pragma mark -
#pragma mark General Player Management

-(BOOL)addPlayer:(NSString *)playerName;
{
	// make sure the player doesn't already exist
	if ([self playerExists:playerName])
		return NO;

	// add the player object
	[players addObject:[Player playerWithName:playerName]];
	
	// sort players by name
	[players sortUsingComparator:^NSComparisonResult(id p1, id p2)
	 {
		 return [[((Player *)p1) name] caseInsensitiveCompare:[((Player *)p2) name]];
	 }];
	
	return YES;
}

-(void)deletePlayer:(NSString *)playerName
{
	// make sure the player actually exists
	if ([self playerExists:playerName])
	{
		// get the player
		Player *player = [self playerFromName:playerName];
		
		// remove transactions
		[transactions removeObjectsInArray:player.transactions];
		
		// fix the bank's balance
		balance += player.balance;
		
		// delete the player
		[players removeObject:player];
	}
}

#pragma mark -
#pragma mark Player Transaction Management

-(void)processTransaction:(Transaction *)transaction
{
	// FIRST: is it a transfer? process the other transaction
	if (transaction.type == TransactionTypeTransferTo)
	{
		// create the transaction
		Transaction *transaction2 = [Transaction transaction:TransactionTypeTransferFrom amount:transaction.amount player:transaction.playerOther playerOther:transaction.player];
		
		// process the transaction
		[self processTransaction:transaction2];
	}
	
	// process it within the player
	[transaction.player processTransaction:transaction];
	
	// process it within the bank
	balance -= [transaction netAmount];
	
	// add it to the bank's transaction history
	[transactions addObject:transaction];
	
	// SAVE IT
	[st saveBank];
}

-(void)deleteTransaction:(Transaction *)transaction
{
	Transaction *transactionOther = nil;
	
	// if it's "TransferTo", then its sister "TransferFrom" is PREV
	if (transaction.type == TransactionTypeTransferTo)
	{
		transactionOther = [transactions objectAtIndex:[transactions indexOfObject:transaction] - 1];
	}
	// if it's "TransferFrom", then its sister "TransferTo" is NEXT
	else if (transaction.type == TransactionTypeTransferFrom)
	{
		transactionOther = [transactions objectAtIndex:[transactions indexOfObject:transaction] + 1];
	}
	// only do this if it's not a transfer
	else
	{
		balance += [transaction netAmount];
	}
	
	// remove the transaction from the players
	[transaction.player deleteTransaction:transaction];
	
	// remove it from the other player if exists
	if (transactionOther)
		[transactionOther.player deleteTransaction:transactionOther];
	
	// remove it from the bank
	[self.transactions removeObject:transaction];
	
	if (transactionOther)
		[self.transactions removeObject:transactionOther];
}

#pragma mark -
#pragma mark Saving/Loading

-(void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:name forKey:@"Bank.name"];
	[aCoder encodeObject:settings forKey:@"Bank.settings"];
	[aCoder encodeFloat:balance forKey:@"Bank.balance"];
	[aCoder encodeObject:transactions forKey:@"Bank.transactions"];
	[aCoder encodeObject:players forKey:@"Bank.players"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		self.name = [aDecoder decodeObjectForKey:@"Bank.name"];
		self.settings = [aDecoder decodeObjectForKey:@"Bank.settings"];
		balance = [aDecoder decodeFloatForKey:@"Bank.balance"];
		self.transactions = [aDecoder decodeObjectForKey:@"Bank.transactions"];
		self.players = [aDecoder decodeObjectForKey:@"Bank.players"];
		selectedPlayerIndex = -1;
	}
	return self;
}

@end
