//
//  MoneyTypeTableViewCell.m
//  MoneyExchange
//
//  Created by Pavel Deminov on 30/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "MoneyTypeTableViewCell.h"
#import "UIImage+Color.h"

#define SelectedColor [UIColor colorWithRed:255/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
#define SelectedFont [UIFont fontWithName:@"Lato-Black" size:28]

#define NoSelectedPairColor [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.7f]
#define NoSelectedPairFont [UIFont fontWithName:@"Lato-Regular" size:28]

@interface MoneyTypeTableViewCell () {
    IBOutlet UILabel *lblCurrencyPair;
    __strong NSString *_source;
    __strong NSString *_output;
}

@end

@implementation MoneyTypeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self updateView];
    // Configure the view for the selected state
}

-(void)setPairSource:(NSString*)source output:(NSString*)output {
    
    _source = source;
    _output = output;
    [self updateView];
    
}


-(void) updateView {
    
    if (_source.length == 0 || _output.length ==0) return;
    

    
    NSMutableAttributedString *attributedString;
    if (self.selected) {
        
        attributedString = [[NSMutableAttributedString alloc] initWithString:_source];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage colorImage:[UIImage imageNamed:@"arrowBig"] color:SelectedColor];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [attributedString insertAttributedString:attrStringWithImage atIndex:attributedString.length];
        [attributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:_output] atIndex:attributedString.length];
        
        [attributedString addAttributes:@{
                                          NSFontAttributeName : SelectedFont,
                                          NSForegroundColorAttributeName : SelectedColor,
                                          }
                                  range:NSMakeRange(0, attributedString.length)];
        
    } else {
        
        attributedString = [[NSMutableAttributedString alloc] initWithString:_source];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage colorImage:[UIImage imageNamed:@"arrowBig"] color:NoSelectedPairColor];
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [attributedString insertAttributedString:attrStringWithImage atIndex:attributedString.length];
        [attributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:_output] atIndex:attributedString.length];
        
        [attributedString addAttributes:@{
                                          NSFontAttributeName : NoSelectedPairFont,
                                          NSForegroundColorAttributeName : NoSelectedPairColor,
                                          }
                                  range:NSMakeRange(0, attributedString.length)];
        
        
    }
    
    
    
     lblCurrencyPair.attributedText  = attributedString;
    
}

@end
