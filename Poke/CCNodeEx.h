//
//  CCNodeEx.h
//  Poke
//
//  Created by Sour on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCNode (Custom)

-(void)setOpacityRecursive:(GLubyte)o;

-(CGPoint)centerPoint;

-(CGPoint)centerPointInWorldSpace;

-(BOOL)touchInNode:(CGPoint)worldPoint;

@end
