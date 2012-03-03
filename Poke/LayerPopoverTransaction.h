//
//  LayerPopoverTransaction.h
//  Poke
//
//  Created by Sour on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"
#import "LayerPopover.h"
#import "LayerNumberPad.h"

typedef enum
{
	ArrowDirectionRight,
	ArrowDirectionLeft,
}	ArrowDirection;

@class LayerNumberPad;

@interface LayerPopoverTransaction : LayerPopover <LayerNumberPadDelegate>
{
	CCSprite *transactionNodeFrom;
	CCSprite *transactionNodeTo;
	CCSprite *transactionNodeArrow;
	
	CCLabelStroked *labelTransactionAmount;
	
	LayerNumberPad *layerNumberPad;
	
	float transactionAmount;
	
	
	void (^blockConfirm)(id data);
}

-(void)setArrowDirection:(ArrowDirection)arrowDirection;

-(void)setTransferFromBank;

-(void)setTransferFromPlayer:(NSString *)player;

-(void)setTransferToBank;

-(void)setTransferToPlayer:(NSString *)player;

-(void)setTransactionAmount:(float)amount;

-(void)setBalanceTitles;

-(void)setFromPlayerCurrentBalance:(float)balance;

-(void)setFromPlayerNewBalance:(float)balance;

-(void)setToPlayerCurrentBalance:(float)balance;

-(void)setToPlayerNewBalance:(float)balance;

-(void)processTransaction;

-(void)setConfirmBlock:(void(^)(id data))block;

@end
