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
		CCMenuItemImage *buttonConfirm = [CCMenuItemImage itemFromNormalImage:@"PopoverButton.png" selectedImage:@"PopoverButtonDown.png" target:self selector:@selector(onButtonConfirm:)];
		buttonConfirm.anchorPoint = ccp(0.5,0);
		buttonConfirm.position = ccp(0, -menuButtons.contentSize.height*0.43);
		[menuButtons addChild:buttonConfirm];

		CCLabelStroked *labelConfirm = [CCLabelStroked labelWithString:@"Confirm Transaction" fontName:FontFamilyRegular fontSize:Scaled(28)];
		labelConfirm.strokeSize = Scaled(2);
		labelConfirm.position = ccp(buttonConfirm.contentSize.width/2.0, buttonConfirm.contentSize.height/2.0 - 5);
		[buttonConfirm addChild:labelConfirm];

		// init text field
		[self initTextField];
		
		// init transaction amount
		[self setTransactionAmount:0.0];
		
		// init balance titles
		[self setBalanceTitles];
		
		// init number pad
		layerNumberPad = [LayerNumberPad numberPadWithPosition:ccp(Scaled(-165),0) facingLeft:YES];
		layerNumberPad.delegate = self;
		[layer addChild:layerNumberPad];
		
		// move it to the right on iphone, for keyboard
		if (!iPad)
		{
			id action = [CCMoveBy actionWithDuration:0.25 position:ccp(165/4.0,0)];
			action = [CCEaseSineOut actionWithAction:action];
			[self runAction:action];
		}
	}
	
	return self;
}

-(void)dealloc
{
	[textFieldName release];
	[blockConfirm release];
	
	[super dealloc];
}

-(void)initTextField
{
	CGPoint pt = [menuButtons convertToWorldSpace:CGPointZero];
	CGRect rectTextField = CGRectMake(pt.x, pt.y-Scaled(85), Scaled(302), Scaled(106));
	rectTextField.origin = [[CCDirector sharedDirector] convertToGL:rectTextField.origin];
	
	textFieldName = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, rectTextField.size.width, rectTextField.size.height)];
	[textFieldName setBackgroundColor:[UIColor colorWithRed:0.011765 green:0.137255 blue:0.239216 alpha:1]];
	[textFieldName setTextColor:[UIColor whiteColor]];
	[textFieldName setFont:[UIFont fontWithName:@"Verdana" size:Scaled(18)]];
	[textFieldName setCenter:rectTextField.origin];
	[textFieldName setTextAlignment:UITextAlignmentLeft];
	[textFieldName setReturnKeyType:UIReturnKeyDone];
	textFieldName.delegate = self;
	
	[[[CCDirector sharedDirector] openGLView] addSubview:textFieldName];
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
	
	// add minus badge
	CCSprite *badgeMinus	= [CCSprite spriteWithFile:@"BadgeMinus.png"];
	badgeMinus.position = ccp(transactionNodeFrom.contentSize.width*0.9, transactionNodeFrom.contentSize.height*0.9);
	[transactionNodeFrom addChild:badgeMinus];
}

-(void)setTransferFromPlayer:(NSString *)player
{
	if (transactionNodeFrom)
		[transactionNodeFrom removeFromParentAndCleanup:YES];
	
	transactionNodeFrom = [CCSprite spriteWithFile:@"IconPlayer.png"];
	transactionNodeFrom.userData = player;
	transactionNodeFrom.position = ccp(-layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeFrom];
	
	CCLabelStroked *labelName = [CCLabelStroked labelWithString:player fontName:@"TeluguSangamMN" fontSize:Scaled(26)];
	labelName.strokeSize = Scaled(2);
	labelName.anchorPoint = ccp(0.5,1);
	labelName.position = ccp(transactionNodeFrom.contentSize.width/2.0, 0);
	[transactionNodeFrom addChild:labelName];
	
	[self setFromPlayerCurrentBalance:[st.currentBank playerFromName:player].balance];
	
	// add minus badge
	CCSprite *badgeMinus	= [CCSprite spriteWithFile:@"BadgeMinus.png"];
	badgeMinus.position = ccp(transactionNodeFrom.contentSize.width*0.9, transactionNodeFrom.contentSize.height*0.9);
	[transactionNodeFrom addChild:badgeMinus];
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
	
	// add plus badge
	CCSprite *badgePlus		= [CCSprite spriteWithFile:@"BadgePlus.png"];
	badgePlus.position = ccp(transactionNodeTo.contentSize.width*0.9, transactionNodeTo.contentSize.height*0.9);
	[transactionNodeTo addChild:badgePlus];
}

-(void)setTransferToPlayer:(NSString *)player
{
	if (transactionNodeTo)
		[transactionNodeTo removeFromParentAndCleanup:YES];
	
	transactionNodeTo = [CCSprite spriteWithFile:@"IconPlayer.png"];
	transactionNodeTo.userData = player;
	transactionNodeTo.position = ccp(layer.parent.contentSize.width*0.25, layer.parent.contentSize.height*0.22);
	[layer addChild:transactionNodeTo];
	
	CCLabelStroked *labelName = [CCLabelStroked labelWithString:player fontName:@"TeluguSangamMN" fontSize:Scaled(26)];
	labelName.strokeSize = Scaled(2);
	labelName.anchorPoint = ccp(0.5,1);
	labelName.position = ccp(transactionNodeTo.contentSize.width/2.0, 0);
	[transactionNodeTo addChild:labelName];
	
	[self setToPlayerCurrentBalance:[st.currentBank playerFromName:player].balance];
	
	// add plus badge
	CCSprite *badgePlus		= [CCSprite spriteWithFile:@"BadgePlus.png"];
	badgePlus.position = ccp(transactionNodeTo.contentSize.width*0.9, transactionNodeTo.contentSize.height*0.9);
	[transactionNodeTo addChild:badgePlus];
}

-(void)setTransactionAmount:(float)amount
{
	NSString *strAmount = [NSString stringWithFormat:@"%1.3f", amount];
	
	if (labelTransactionAmount == nil)
	{
		labelTransactionAmount = [CCLabelStroked labelWithString:strAmount fontName:@"TeluguSangamMN" fontSize:Scaled(38)];
		labelTransactionAmount.strokeSize = Scaled(2);
		labelTransactionAmount.position = ccp(0,Scaled(75));
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
	CCLabelStroked *labelCurrentBalanceTitle = [CCLabelStroked labelWithString:@"CURRENT" fontName:FontFamilyRegular fontSize:Scaled(16)];
	labelCurrentBalanceTitle.strokeSize = Scaled(2);
	labelCurrentBalanceTitle.position = ccp(0,Scaled(16));
	[layer addChild:labelCurrentBalanceTitle];
	
	CCLabelStroked *labelNewBalanceTitle = [CCLabelStroked labelWithString:@"NEW" fontName:FontFamilyRegular fontSize:Scaled(16)];
	labelNewBalanceTitle.strokeSize = Scaled(2);
	labelNewBalanceTitle.position = ccp(0,Scaled(-16));
	[layer addChild:labelNewBalanceTitle];
}

-(void)setFromPlayerCurrentBalance:(float)balance
{
	if (!transactionNodeFrom)
		return;
	
	CCLabelStroked *labelCurrentBalance = (CCLabelStroked *)[transactionNodeFrom getChildByTag:1];
	
	if (!labelCurrentBalance)
	{
		labelCurrentBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:Scaled(25)];
		labelCurrentBalance.strokeSize = Scaled(2);
		labelCurrentBalance.position = ccp(transactionNodeFrom.contentSize.width/2.0,Scaled(-52));
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
		labelNewBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:Scaled(25)];
		labelNewBalance.strokeSize = Scaled(2);
		labelNewBalance.position = ccp(transactionNodeFrom.contentSize.width/2.0,Scaled(-84));
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
		labelCurrentBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:Scaled(25)];
		labelCurrentBalance.strokeSize = Scaled(2);
		labelCurrentBalance.position = ccp(transactionNodeTo.contentSize.width/2.0,Scaled(-52));
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
		labelNewBalance = [CCLabelStroked labelWithString:[Bank stringFromAmount:balance] fontName:@"TeluguSangamMN" fontSize:Scaled(25)];
		labelNewBalance.strokeSize = Scaled(2);
		labelNewBalance.position = ccp(transactionNodeTo.contentSize.width/2.0,Scaled(-84));
		[transactionNodeTo addChild:labelNewBalance z:0 tag:2];
	}
	else
	{
		[labelNewBalance setString:[Bank stringFromAmount:balance]];
	}
}

-(void)close
{
	// remove text field
	[textFieldName removeFromSuperview];
	
	[super close];
}

#pragma mark -
#pragma mark Node Overrides

-(void)setPosition:(CGPoint)position
{
	if (textFieldName)
	{
		CGPoint ptDiff = ccpSub(position_, position);

		textFieldName.center = ccp(textFieldName.center.x-ptDiff.x,
								   textFieldName.center.y+ptDiff.y);
	}
	
	[super setPosition:position];
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
	
	transaction.note = textFieldName.text;
	
	// process it
	[st.currentBank processTransaction:transaction];
	
	// play sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"SoundConfirm.mp3"];
}

-(void)setConfirmBlock:(void(^)(id data))block
{
	blockConfirm = [block copy];
}

#pragma mark -
#pragma mark UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
	if (!iPad)
	{
		id action = [CCMoveBy actionWithDuration:0.25 position:ccp(0,100)];
		action = [CCEaseSineOut actionWithAction:action];
		[self runAction:action];
	}
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
	if (!iPad)
	{
		id action = [CCMoveBy actionWithDuration:0.25 position:ccp(0,-100)];
		action = [CCEaseSineOut actionWithAction:action];
		[self runAction:action];
	}
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	// return on "Done"
	if ([text isEqual:@"\n"])
	{
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}


#pragma mark -
#pragma mark Actions

-(void)onButtonConfirm:(id)sender
{
    // disable this
    [sender setIsEnabled:NO];
    
    // process transaction
    [self processTransaction];
    
    // notify
    if (blockConfirm)
        blockConfirm(sender);
    
    // close
    [self close];
}

@end
