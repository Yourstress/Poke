//
//  NodePlayer.m
//  Poke
//
//  Created by Sour on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NodePlayer.h"

@implementation NodePlayer

+(id)playerWithName:(NSString *)playerName block:(void(^)(id sender))block
{
	return [[[self alloc] initWithName:playerName block:block] autorelease];
}

-(id)initWithName:(NSString *)playerName block:(void(^)(id sender))block
{
	if ( (self = [super initFromNormalImage:@"IconPlayer.png" selectedImage:@"IconPlayerDown.png" disabledImage:@"IconPlayerDown.png" block:block]) )
	{
		self.normalImage.position = ccp(0,Scaled(60));
		self.selectedImage.position = ccp(0,Scaled(60));
		
		// add player name
		name = [CCLabelStroked labelWithString:playerName fontName:FontFamilyRegular fontSize:Scaled(24)];
		name.strokeSize = Scaled(3);
		[self addChild:name z:0 tag:0];
		
		// add player balance
		balance = [CCLabelStroked labelWithString:@"0.000 KD" fontName:FontFamilyRegular fontSize:Scaled(22)];
		balance.strokeSize = Scaled(3);
		[self addChild:balance z:0 tag:1];
		
		// the name
		name.position = ccp(self.contentSize.width/2.0, Scaled(52));
		name.anchorPoint = ccp(0.5,1);
		
		// the balance
		balance.position = ccp(self.contentSize.width/2.0, Scaled(-6));
		balance.anchorPoint = ccp(0.5,0);
		
		// make it wider than the actual icon
		self.contentSize = CGSizeMake(self.contentSize.width, Scaled(144));
		
		// save the player name
		self.userData = playerName;
	}
	
	return self;
}

-(void)setName:(NSString *)playerName
{
	[name setString:playerName];
}

-(void)setBalance:(float)amount
{
	if (currentBalance == amount)
		return;
	
	currentBalance = amount;
	
	[balance setString:[Bank stringFromAmount:amount]];
}

@end
