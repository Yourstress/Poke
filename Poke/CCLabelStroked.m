//
//  CCLabelTTF.m
//  Poke
//
//  Created by Macbook Pro on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCLabelStroked.h"


@implementation CCLabelStroked

@synthesize strokeSize;
@synthesize strokeColor;

-(id)init
{
	if ( (self = [super init]) )
	{
		// set default stroke size to 1
		strokeSize = 1;
		
		// set default stroke color to black
		strokeColor = ccc3(0, 0, 0);
	}
	
	return self;
}

-(void)setStrokeSize:(float)s
{
	if (strokeSize == s)
		return;
	
	strokeSize = s;
	
	[self applyStroke];
}

-(void)setStrokeColor:(ccColor3B)c
{
	if (strokeColor.r == c.r &&
		strokeColor.g == c.g &&
		strokeColor.b == c.b)
		return;
	
	strokeColor = c;
	
	[self applyStroke];
}

-(void)setString:(NSString*)str
{
	// set the string however it wants to
	[super setString:str];
	
	[self applyStroke];
}

-(void)applyStroke
{
	// make sure we at least have a label
	if (texture_ == nil)
		return;
	
	// apply stroke
	if (stroke != nil)
		[self removeStroke];
	
	stroke = [CCRenderTexture renderTextureWithWidth:self.texture.contentSize.width+strokeSize*2 height:self.texture.contentSize.height+strokeSize*2];
	CGPoint originalPos = [self position];
	ccColor3B originalColor = [self color];
	BOOL originalVisibility = [self visible];
	float originalOpacity = [self opacity];
	[self setOpacity:255];
	[self setColor:strokeColor];
	[self setVisible:YES];
	ccBlendFunc originalBlend = [self blendFunc];
	[self setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(self.texture.contentSize.width * self.anchorPoint.x + strokeSize, self.texture.contentSize.height * self.anchorPoint.y + strokeSize);
	
    //use this for adding stoke to its self...
    CGPoint positionOffset= ccp(self.contentSize.width/2,self.contentSize.height/2);
	
	//	CGPoint position = ccpSub(originalPos, positionOffset);
	
	[stroke begin];
	for (int i=0; i<360; i+=18) // you should optimize that for your needs
	{
		[self setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*strokeSize, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*strokeSize)];
		[self visit];
	}
	[stroke end];
	[self setOpacity:originalOpacity];
	[self setPosition:originalPos];
	[self setColor:originalColor];
	[self setBlendFunc:originalBlend];
	[self setVisible:originalVisibility];
	[stroke setPosition:positionOffset];
	
	[self addChild:stroke z:-1];
}

-(void)removeStroke
{
	[stroke removeFromParentAndCleanup:YES];
	stroke = nil;
}

-(void)setOpacity:(GLubyte)o
{
	if ([self.children count] > 0)
	{
		// set outline opacity
		CCRenderTexture *outline = (CCRenderTexture *)[self.children objectAtIndex:0];
		outline.sprite.opacity = o;
	}
	
	// set self opacity
	[super setOpacity:o];
}

@end
