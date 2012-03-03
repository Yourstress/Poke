//
//  CCLabelTTF.h
//  Poke
//
//  Created by Macbook Pro on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCLabelStroked : CCLabelTTF
{
	CCRenderTexture *stroke;
}

@property (nonatomic, assign) float strokeSize;
@property (nonatomic, assign) ccColor3B strokeColor;

-(void)applyStroke;

-(void)removeStroke;

@end
