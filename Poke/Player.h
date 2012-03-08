//
//  Player.h
//  Poke
//
//  Created by Macbook Pro on 10/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Transaction;
@interface Player : NSObject <NSCoding>
{
}

@property (nonatomic, retain)			NSString *name;
@property (nonatomic, readonly)			float balance;
@property (nonatomic, retain, readonly)	NSMutableArray *transactions;

#pragma mark -
#pragma mark Initializers

// create new player by name
+(id)playerWithName:(NSString *)playerName;;

// initialize player by name.
-(id)initWithName:(NSString *)playerName;

#pragma mark -
#pragma mark Balance Management

-(float)balanceFromDate:(NSTimeInterval)dateStart toDate:(NSTimeInterval)dateEnd;

#pragma mark -
#pragma mark Transaction Management

// processes a transaction for this player
-(void)processTransaction:(Transaction *)transaction;

// deletes a transaction
-(void)deleteTransaction:(Transaction *)transaction;

@end
