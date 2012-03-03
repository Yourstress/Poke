//
//  NodePlayer.h
//  Poke
//
//  Created by Sour on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"

@interface NodePlayer : CCMenuItemImage
{
	float currentBalance;
	
	CCLabelStroked *name;
	CCLabelStroked *balance;
}

+(id)playerWithName:(NSString *)playerName block:(void(^)(id sender))block;

-(id)initWithName:(NSString *)playerName block:(void(^)(id sender))block;

-(void)setName:(NSString *)playerName;

-(void)setBalance:(float)amount;

@end
