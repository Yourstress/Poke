//
//  LayerPopoverTable.h
//  Poke
//
//  Created by Macbook Pro on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayerPopover.h"

typedef enum
{
	ButtonTypeAdd,
	ButtonTypeDetails,
}	ButtonType;

@interface LayerPopoverTable : LayerPopover <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *table;
	
	NSArray *items;
	void (^block)(id data);
}

+(id)popoverWithPosition:(CGPoint)position title:(NSString *)title items:(NSArray *)i block:(void(^)(id data))block;

-(id)initWithPosition:(CGPoint)position title:(NSString *)title items:(NSArray *)i block:(void(^)(id data))block;

-(void)addTitleBarButton:(ButtonType)buttonType block:(void(^)(id data))b;

-(void)refreshItems;

@end
