//
//  MoneyTypeTableViewCell.h
//  MoneyExchange
//
//  Created by Pavel Deminov on 30/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoneyTypeTableViewCell : UITableViewCell

@property(nonatomic,assign) BOOL cellSelected;
-(void)setPairSource:(NSString*)source output:(NSString*)output;

@end
