//
//  LayerPopoverTable.m
//  Poke
//
//  Created by Macbook Pro on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LayerPopoverTable.h"

@implementation LayerPopoverTable

+(id)popoverWithPosition:(CGPoint)position title:(NSString *)title items:(NSArray *)i block:(void(^)(id data))b
{
	return [[[self alloc] initWithPosition:position title:title items:i block:b] autorelease];
}

-(id)initWithPosition:(CGPoint)position title:(NSString *)title items:(NSArray *)i block:(void(^)(id data))b
{
	if ( (self = [super initWithPosition:position]) )
	{
		// set the block and data
		block = [b copy];
		items = i;
		
		CCNode *spBody = [self getChildByTag:1];

		// init table
		table = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, PopoverHalfWidth*2, PopoverHalfHeight*2) style:UITableViewStyleGrouped] autorelease];
		table.delegate = self;
		table.dataSource = self;
		table.separatorStyle = UITableViewCellSeparatorStyleNone;
		table.separatorColor = [UIColor clearColor];
		table.backgroundView = nil;
		[table setBackgroundColor:[UIColor clearColor]];
		CCUIViewWrapper *uiTable = [CCUIViewWrapper wrapperForUIView:table];
		[self addChild:uiTable z:1000];
		uiTable.contentSize = CGSizeMake(PopoverHalfWidth*2, PopoverHalfHeight*2 - 65);
		uiTable.position = ccp(spBody.position.x, spBody.position.y - (spBody.anchorPoint.y*spBody.contentSize.height) + 220);
		uiTable.opacity = 120;
		
		// set the title
		[self setTitle:title];
	}
	
	return self;
}

-(void)addTitleBarButton:(ButtonType)buttonType block:(void(^)(id data))b
{
	CCMenuItemImage *button;
	
	switch (buttonType)
	{
		case ButtonTypeAdd:
			button = [CCMenuItemImage itemFromNormalImage:@"IconAdd.png" selectedImage:@"IconAddDown.png" block:b];
			break;
		case ButtonTypeDetails:
			button = [CCMenuItemImage itemFromNormalImage:@"IconDetails.png" selectedImage:@"IconDetailsDown.png" block:b];
			break;
		default:
			return;
	}
	
	button.anchorPoint = ccp(1,1);
	button.position = ccp(PopoverHalfWidth,PopoverHalfHeight-2);
	[menuButtons addChild:button];
	
	// since we're adding a button, recenter label
	labelTitle.position = ccpSub(labelTitle.position, ccp(button.contentSize.width*0.4,0));
}

-(void)refreshItems
{
	[table reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return [items count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *item = [items objectAtIndex:indexPath.row];
	
	// fill the table with strings
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
		
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		
	// set text
	cell.textLabel.text = (NSString *)item;
		
	// set text color and alignment
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.textAlignment = UITextAlignmentCenter;

	// set shadow
	[cell.textLabel setShadowOffset:CGSizeMake(0, 2)];
	[cell.textLabel setShadowColor:[UIColor blackColor]];
		
	// set transparent background
	cell.backgroundView = nil;
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// get the selected cell
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	// execute block with cell text
	block(cell.textLabel.text);
}

@end
