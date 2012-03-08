//
//  Session.h
//  Poke
//
//  Created by Macbook Pro on 11/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Transaction;
@interface Session : NSObject <NSCoding>
{
	NSMutableArray *transactions;	// session transactions
}

// constructor
+(id)session;

// add a transaction to the session
-(void)addTransaction:(Transaction *)transaction;

// remove a transaction from the session
-(void)removeTransaction:(Transaction *)transaction;

// returns a specific transaction
-(Transaction *)transactionAtIndex:(int)index;

// returns the last transaction
-(Transaction *)lastTransaction;

// returns number of transactions
-(int)numberOfTransactions;

// returns the name of the session
-(NSString *)name;

@end
