//
//  LayerPopoverTransaction.m
//  Poke
//
//  Created by Sour on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPopoverTransaction.h"

@implementation LayerPopoverTransaction

-(id)initWithPosition:(CGPoint)position
{
	if ( (self = [super initWithPosition:position]) )
	{
		// create confirm button
		CCMenuItemImage *buttonConfirm = [CCMenuItemImage itemFromNormalImage:@"PopoverButton.png" selectedImage:@"PopoverButtonDown.png" block:^(id sender)
										  {
											  // process transaction
											  [self processTransaction];
											  
											  // notify
											  if (blockConfirm)
												  blockConfirm(sender);
											  
											  // close
											  [self close];
										  }];
		buttonConfirm.anchorPoint = ccp(0.5,0);
		buttonConfirm.position = ccp(0, -menuButtons.contentSize.height*0.43);
		[menuButtons addChild:buttonConfirm];

		CCLabelStroked *labelConfirm = [CCLabelStroked labelWithString:@"Confirm Transaction" fontName:FontFamilyRegular fontSize:28];
		labelConfirm.strokeSize = 2;
		labelConfirm.position = ccp(buttonConfirm.contentSize.width/2.0, buttonConfirm.contentSize.height/2.0 - 5);
		[buttonConfirm addChild:labelConfirm];
		
		// init transaction amount
		[self setTransactionAmount:0.0];
		
		// init balance titles
		[self setBalanceTitles];
		
		// init number pad
		layerNumberPad = [LayerNumberPad numberPadWithPosition:ccp(-165,0) facingLeft:YES];
		layerNumberPad.delegate = self;
		[layer addChild:layerNumberPad];
	}
	
	return self;
}

-(void)setArrowDirection:(ArrowDirection)arrowDirection
{
	if (transactionNodeArrow)
		[transactionNodeArrow removeFromParentAndCleanup:YES];
	
	// load/position/add the arrow
	transactionNodeArrow = [CCSprite spriteWithFile:@"IconArrow.png"];
	transactionNodeArrow.position = ccp(0, layer.parent.contentSize.height*0.26);
	[layer addChild:transactionNodeArrow];
	
	transactionNodeArrow.flipX = (arrowDirection == ArrowDirectionLeft);
}

-(void)setTransferFromBank
{
	if (transactionNodeFrom)
		[transactionNodeFrom removeFromParentAndCleanup:YES];
	
	transactionNodeFrom = [CCSprite spriteWithFile:@"IconBank.png"];
	transactionNodeFrom.userData = nil;
	transactionNodeFrom.position = ccp(-layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeFrom];
	
	[self setFromPlayerCurrentBalance:st.currentBank.balance];
}

-(void)setTransferFromPlayer:(NSString *)player
{
	if (transactionNodeFrom)
		[transactionNodeFrom removeFromParentAndCleanup:YES];
	
	transactionNodeFrom = [CCSprite spriteWithFile:@"IconPlayer.png"];
	transactionNodeFrom.userData = player;
	transactionNodeFrom.position = ccp(-layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeFrom];
	
	CCLabelStroked *labelName = [CCLabelStroked labelWithString:player fontName:@"TeluguSangamMN" fontSize:26];
	labelName.strokeSize = 2;
	labelName.anchorPoint = ccp(0.5,1);
	labelName.position = ccp(transactionNodeFrom.contentSize.width/2.0, 0);
	[transactionNodeFrom addChild:labelName];
	
	[self setFromPlayerCurrentBalance:[st.currentBank playerFromName:player].balance];
}

-(void)setTransferToBank
{
	if (transactionNodeTo)
		[transactionNodeTo removeFromParentAndCleanup:YES];
	
	transactionNodeTo = [CCSprite spriteWithFile:@"IconBank.png"];
	transactionNodeTo.userData = nil;
	transactionNodeTo.position = ccp(layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeTo];
	
	[self setToPlayerCurrentBalance:st.currentBank.balance];
}

-(void)setTransferToPlayer:(NSString *)player
{
	if (transactionNodeTo)
		[transactionNodeTo removeFromParentAndCleanup:YES];
	
	transactionNodeTo = [CCSprite spriteWithFile:@"IconPlayer.png"];
	transactionNodeTo.userData = player;
	transactionNodeTo.position = ccp(layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeTo];
	
	CCLabelStroked *labelName = [CCLabelStroked labelWithString:player fontName:@"TeluguSangamMN" fontSize:26];
	labelName.strokeSize = 2;
	labelName.anchorPoint = ccp(0.5,1);
	labelName.position = ccp(transactionNodeTo.contentSize.width/2.0, 0);
	[transactionNodeTo addChild:labelName];
	
	[self setToPlayerCurrentBalance:[st.currentBank playerFromName:player].balance];
}

-(void)setTransactionAmount:(float)amount
{
	NSString *strAmount = [NSString stringWithFormat:@"%1.3f", amount];
	
	if (labelTransactionAmount == nil)
	{
		labelTransactionAmount = [CCLabelStroked labelWithString:strAmount fontName:@"TeluguSangamMN" fontSize:38];
		labelTransactionAmount.strokeSize = 2;
		labelTransactionAmount.position = ccp(0,+75);
		[layer addChild:labelTransactionAmount];
	}
	else
	{
		[labelTransactionAmount setString:strAmount];
	}
	
	transactionAmount = amount;
	
	// set new balance for both players
	float fromBalance	= (transactionNodeFrom.userData == nil)	? st.currentBank.balance : [st.currentBank playerFromName:transactionNodeFrom.userData].balance;
	float toBalance		= (transactionNodeTo.userData == nil)	? st.currentBank.balance : [st.currentBank playerFromName:transactionNodeTo.userData].balance;
	[self setFromPlayerNewBalance:fromBalance-amount];
	[self setToPlayerNewBalance:toBalance+amount];
}

-(void)setBalanceTitles
{
	CCLabelStroked *labelCurrentBalanceTitle = [CCLabelStroked labelWithString:@"CURRENT" fontName:FontFamilyRegular fontSize:16];
	labelCurrentBalanceTitle.strokeSize = 2;
	labelCurrentBalanceTitle.position = ccp(0,16);
	[layer addChild:labelCurrentBalanceTitle];
	
	CCLabelStroked *labelNewBalanceTitle = [CCLabelStroked labelWithString:@"NEW" fontName:FontFamilyRegular fontSize:16];
	labelNewBalanceTitle.strokeSize = 2;
	labelNewBalanceTitle.position = ccp(0,-16);
	[layer addChild:labelNewBalanceTitle];
}

-(void)setFromPlayerCurrentBalance:(float)balance
{
	if (!transactionNodeFrom)
		return;
	
	CCLabelStroked *labelCurrentBalance = (CCLabelStroked *)[transactionNodeFrom getChildByTag:1];
	
	if (!labelCurrentBalance)
	{
		labelCurrentBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:25];
		labelCurrentBalance.strokeSize = 2;
		labelCurrentBalance.position = ccp(transactionNodeFrom.contentSize.width/2.0,-52);
		[transactionNodeFrom addChild:labelCurrentBalance z:0 tag:1];
	}
	else
	{
		[labelCurrentBalance setString:[Bank stringFromAmount:balance]];
	}
	
	// current balance changed? new balance changed!
	[self setFromPlayerNewBalance:balance];
}

-(void)setFromPlayerNewBalance:(float)balance
{
	if (!transactionNodeFrom)
		return;
	
	CCLabelStroked *labelNewBalance = (CCLabelStroked *)[transactionNodeFrom getChildByTag:2];
	
	if (!labelNewBalance)
	{
		labelNewBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:25];
		labelNewBalance.strokeSize = 2;
		labelNewBalance.position = ccp(transactionNodeFrom.contentSize.width/2.0,-84);
		[transactionNodeFrom addChild:labelNewBalance z:0 tag:2];
	}
	else
	{
		[labelNewBalance setString:[Bank stringFromAmount:balance]];
	}
}

-(void)setToPlayerCurrentBalance:(float)balance
{
	if (!transactionNodeTo)
		return;
	
	CCLabelStroked *labelCurrentBalance = (CCLabelStroked *)[transactionNodeTo getChildByTag:1];
	
	if (!labelCurrentBalance)
	{
		labelCurrentBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:25];
		labelCurrentBalance.strokeSize = 2;
		labelCurrentBalance.position = ccp(transactionNodeTo.contentSize.width/2.0,-52);
		[transactionNodeTo addChild:labelCurrentBalance z:0 tag:1];
	}
	else
	{
		[labelCurrentBalance setString:[Bank stringFromAmount:balance]];
	}
	
	// current balance changed? new balance changed!
	[self setToPlayerNewBalance:balance];
}

-(void)setToPlayerNewBalance:(float)balance
{
	if (!transactionNodeTo)
		return;
	
	CCLabelStroked *labelNewBalance = (CCLabelStroked *)[transactionNodeTo getChildByTag:2];
	
	if (!labelNewBalance)
	{
		labelNewBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:25];
		labelNewBalance.strokeSize = 2;
		labelNewBalance.position = ccp(transactionNodeTo.contentSize.width/2.0,-84);
		[transactionNodeTo addChild:labelNewBalance z:0 tag:2];
	}
	else
	{
		[labelNewBalance setString:[Bank stringFromAmount:balance]];
	}
}

#pragma mark -
#pragma mark LayerNumberPadDelegate

-(void)numberPadEnteredNumber:(int)number
{
	if (transactionAmount >= 100.0)
		return;
	
	float newAmount;
	
	if (transactionAmount == 0.0)
	{
		newAmount = number/1000.0;
	}
	else
	{
		newAmount = (transactionAmount*10) + number/1000.0;
	}
	
	[self setTransactionAmount:newAmount];
}

-(void)numberPadCleared
{
	[self setTransactionAmount:0.0];
}

-(void)numberPadKD
{
	float newAmount = transactionAmount*1000.0;
	
	if (newAmount >= 100.0)
		return;
	
	[self setTransactionAmount:newAmount];
}

-(void)processTransaction
{
	Transaction *transaction;
	
	// player->player (non-bank, non-bank)
	if (transactionNodeFrom.userData != nil && transactionNodeTo.userData != nil)
		transaction = [Transaction transaction:TransactionTypeTransferTo amount:transactionAmount player:[st.currentBank playerFromName:transactionNodeFrom.userData] playerOther:[st.currentBank playerFromName:transactionNodeTo.userData]];
	// player->bank (non-bank, bank)
	else if (transactionNodeFrom.userData != nil && transactionNodeTo.userData == nil)
		transaction = [Transaction transaction:TransactionTypeCoinOut amount:transactionAmount player:[st.currentBank playerFromName:transactionNodeFrom.userData] playerOther:nil];
	// bank->player (bank, non-bank)
	else if (transactionNodeFrom.userData == nil && transactionNodeTo.userData != nil)
		transaction = [Transaction transaction:TransactionTypeCoinIn amount:transactionAmount player:[st.currentBank playerFromName:transactionNodeTo.userData] playerOther:nil];
	
	// process it
	[st.currentBank processTransaction:transaction];
	
	// play sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundConfirm.mp3"];
}

-(void)setConfirmBlock:(void(^)(id data))block
{
	blockConfirm = [block copy];
}

@end
