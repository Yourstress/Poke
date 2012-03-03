//
//  LayerNumberPad.h
//  Poke
//
//  Created by Sour on 12/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Standard.h"

@protocol LayerNumberPadDelegate <NSObject>
@required
-(void)numberPadEnteredNumber:(int)number;
-(void)numberPadCleared;
-(void)numberPadKD;
@end

@interface LayerNumberPad : CCLayer
{
	CCMenu *menuButtons;
}

@property (nonatomic, assign) id<LayerNumberPadDelegate> delegate;

+(id)numberPadWithPosition:(CGPoint)position facingLeft:(BOOL)facingLeft;

-(id)initWithPosition:(CGPoint)position facingLeft:(BOOL)facingLeft;

-(void)addNumpadButtons;

@end
