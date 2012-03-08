//
//  Bank.h
//  Poke
//
//  Created by Macbook Pro on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Transaction.h"
#import "Player.h"
#import "Session.h"

#define SessionLength		(5*60*60)

#define GetBankSettingMinimumBalance			([[st.bank.settings objectForKey:BankSettingMinimumBalance] floatValue])
#define SetBankSettingMinimumBalance(balance)	([st.bank.balance setObject:[NSNumber numberWithFloat:balance] forKey:BankSettingMinimumBalance])

#define BankSettingMinimumBalance		@"SettingMinBalance"

typedef enum
{
	ValidationTypeBankName,
	ValidationTypePlayerName,
	ValidationTypeCurrency,
}	ValidationType;

@interface Bank : NSObject <NSCoding>
{
}

// bank-specific properties
@property (nonatomic, assign) NSString *name;
@property (nonatomic, retain) NSMutableDictionary *settings;
@property (nonatomic, readonly) float balance;
@property (nonatomic, retain) NSMutableArray *transactions;

// player-specific properties
@property (nonatomic, retain) NSMutableArray *players;
@property (nonatomic, readonly) int selectedPlayerIndex;

#pragma mark -
#pragma mark Static methods

// validates and corrects a value in currency
+(NSString *)validateAmount:(NSString *)amount defaultAmount:(NSString *)defaultAmount;

// validates a string (returns YES if all is well)
+(BOOL)validateString:(NSString *)string withOptions:(ValidationType)validationType;

// returns a string using an amount in this format: "x.xxx KD"
+(NSString *)stringFromAmount:(float)amount;

// returns a color using an amount. Green for positive, Red for negative, Grey for zero.
+(UIColor *)colorFromAmount:(float)amount;

// returns the float amount, fixing a possible minus zero
+(float)roundMinus:(float)f;

#pragma mark -
#pragma mark Initializers

// init method
-(id)initWithName:(NSString *)bankName;

#pragma mark -
#pragma mark Player Getters

// returns the player with the given name
-(Player *)playerFromName:(NSString *)playerName;

// returns whether the player already exists or not
-(BOOL)playerExists:(NSString *)playerName;

// returns number of players
-(int)numberOfPlayers;

#pragma mark -
#pragma mark Player Selection

// get player at the given index
-(Player *)playerAtIndex:(int)playerIndex;

// select a player based on index
-(void)selectPlayerAtIndex:(int)index;

// returns the selected player
-(Player *)selectedPlayer;

#pragma mark -
#pragma mark Player Management

// add a player
-(BOOL)addPlayer:(NSString *)playerName;

// remove a player
-(void)deletePlayer:(NSString *)playerName;

#pragma mark -
#pragma mark Player Transaction Management

// processes and adds the transaction to the bank's transactions
-(void)processTransaction:(Transaction *)transaction;

// deletes the transaction given
-(void)deleteTransaction:(Transaction *)transaction;

@end
