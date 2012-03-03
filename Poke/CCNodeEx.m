//
//  CCNodeEx.m
//  Poke
//
//  Created by Sour on 12/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCNodeEx.h"


@implementation CCNode (Custom)

-(void)setOpacityRecursive:(GLubyte)o
{
	// set current node
	if ([self respondsToSelector:@selector(setOpacity:)])
		[((CCNode<CCRGBAProtocol> *)self) setOpacity:o];
	
	// set all children
	for (CCNode *node in self.children)
		[node setOpacityRecursive:o];
}

-(CGPoint)centerPoint
{
	return ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);
}

-(CGPoint)centerPointInWorldSpace
{
	return [self convertToWorldSpace:[self centerPoint]];
}

-(BOOL)touchInNode:(CGPoint)worldPoint
{
	CGRect rect		= CGRectMake(self.position.x-(self.contentSize.width*self.anchorPoint.x*self.scaleX),
								 self.position.y-(self.contentSize.height*self.anchorPoint.y*self.scaleY),
								 self.contentSize.width*self.scaleX,
								 self.contentSize.height*self.scaleY);
	
	CGPoint rotPt	= ccpRotateByAngle(worldPoint, self.position, CC_DEGREES_TO_RADIANS(self.rotation));
	
	return CGRectContainsPoint(rect, rotPt);
}

@end
