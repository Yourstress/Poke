//
//  Transaction.h
//  Poke
//
//  Created by Macbook Pro on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ccTypes.h"

#define FormatDate(date)  [NSDateFormatter localizedStringFromDate:timeStamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]

typedef enum
{
	TransactionDirectionNil,
	TransactionDirectionIn,
	TransactionDirectionOut,
}	TransactionDirection;

typedef enum
{
	TransactionCurrencyTypeNil,
	TransactionCurrencyTypeCoin,
	TransactionCurrencyTypeCash,
}	TransactionCurrencyType;

typedef enum
{
	TransactionTypeNil				= -1,
	TransactionTypeCashIn			= 0,
	TransactionTypeCashOut			= 1,
	TransactionTypeCoinIn			= 2,
	TransactionTypeCoinOut			= 3,
	TransactionTypeCashInCoinOut	= 4,
	TransactionTypeCoinInCashOut	= 5,
	TransactionTypeTransferFrom		= 6,
	TransactionTypeTransferTo		= 7,
}	TransactionType;

@class Player;
@interface Transaction : NSObject <NSCoding>
{
}

@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Player *playerOther;
@property (nonatomic, readonly) TransactionType type;
@property (nonatomic, readonly) float amount;
@property (nonatomic, retain) NSDate *timeStamp;

#pragma mark -
#pragma mark Static methods

// returns a string describing a transaction
+(NSString *)stringFromTransaction:(TransactionType)t;

#pragma mark -
#pragma mark Initializers

// initialize a transaction
+(id)transaction:(TransactionType)t amount:(float)a player:(Player *)p;

// initialize a transfer transaction
+(id)transaction:(TransactionType)t amount:(float)a player:(Player *)p1 playerOther:(Player *)p2;

// init
-(id)initWithTransaction:(TransactionType)t amount:(float)a player1:(Player *)p1 player2:(Player *)p2;

#pragma mark -
#pragma mark Data

// get net amount
-(float)netAmount;

// get color from balance
-(UIColor *)colorFromBalance;

// get string from transaction parties
-(NSString *)stringFromTransactionParties;

// get string from transaction
-(NSString *)stringFromTransactionAmount;

#pragma mark -
#pragma mark Timestamps

// returns a short timestamp
-(NSString *)shortTimeStamp;

// returns a long timestamp
-(NSString *)longTimeStamp;

@end
