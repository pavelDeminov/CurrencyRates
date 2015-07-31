//
//  ViewController.m
//  MoneyExchange
//
//  Created by Pavel Deminov on 30/07/15.
//  Copyright (c) 2015 Company. All rights reserved.
//

#import "ViewController.h"
#import "MoneyTypeTableViewCell.h"
#import "APIClient.h"
#import "MBProgressHUD.h"

#define kSource @"kSource"
#define kOutput @"kOutput"
#define lblUpdateColor [UIColor colorWithRed:63.0f/255.0f green:71.0f/255.0f blue:83.0f/255.0f alpha:0.4f]
#define lblUpdateFont [UIFont fontWithName:@"Lato-Black" size:11]

#define lblHistoryColor [UIColor colorWithRed:126.0f/255.0f green:211.0f/255.0f blue:33.0f/255.0f alpha:1.0f]
#define lblHistoryRedColor [UIColor colorWithRed:225.0f/255.0f green:50.0f/255.0f blue:5.0f/255.0f alpha:1.0f]
#define lblHistoryFont [UIFont fontWithName:@"Lato-MediumItalic" size:17]

#define lblRatesColor [UIColor colorWithRed:63.0f/255.0f green:71.0f/255.0f blue:83.0f/255.0f alpha:1.0f]
#define lblRatesFont [UIFont fontWithName:@"Lato-Regular" size:80]

#define lblRatePairColor [UIColor colorWithRed:63.0f/255.0f green:71.0f/255.0f blue:83.0f/255.0f alpha:1.0f]
#define lblRatePairFont [UIFont fontWithName:@"Lato-Bold" size:17]


@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate> {
    
    IBOutlet UIView *middleView;
    BOOL bottomMenuIsShow;
    IBOutlet UITableView *_tableView;
    IBOutlet NSLayoutConstraint *tableViewHeightContraint;
    IBOutlet NSLayoutConstraint *tableViewTopContraint;
    
    IBOutlet NSLayoutConstraint *bottomMenuBottomConstraint;
    IBOutlet NSLayoutConstraint *bottomMenuHeightConstraint;
    
    IBOutlet NSLayoutConstraint *middleViewTopConstraint;
    IBOutlet NSLayoutConstraint *middleViewHeightConstraint;
    
    __strong NSArray *currencyArray;
    __strong NSArray *historyRates;
    __strong NSArray *currentRates;
    __strong NSDate *updateDate;
    
    IBOutlet UILabel *lblRateName;
    IBOutlet UILabel *lblRateValue;
    IBOutlet UILabel *lblRateHistory;
    IBOutlet UILabel *lblUpdated;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    int selectedPairID;
    
    IBOutlet UIButton *btnRefresh;
    
    BOOL historyLoading;
    BOOL currentDataloading;
}


@end

@implementation ViewController

#pragma mark ViewController Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self printAvailableFonts];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissTableView)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissTableView)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    swipe.delegate = self;
    [self.view addGestureRecognizer:swipe];
    
    lblRateValue.text = @"";
    lblUpdated.text = @"";
    lblRateHistory.text = @"";
    
    
    [self fillCurrenciesArray];
    [self layoutScreenViews];
    [self btnRefreshPressed:nil];
    [self updateView];
    
    
//    [[APIClient sharedInstance] apiLiveWithcompletionHandler:^(BOOL succes, NSError *error) {
//        
//    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions

-(IBAction)btnMenuPressed:(id)sender {
    
    bottomMenuIsShow = YES;
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        //tableViewTopContraint.constant =self.view.frame.size.height - tableViewHeightContraint.constant;
        bottomMenuBottomConstraint.constant = - bottomMenuHeightConstraint.constant;
        [self.view layoutIfNeeded];

        
    } completion:^(BOOL finished) {
        

        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            tableViewTopContraint.constant =self.view.frame.size.height-[self statusBarHeight] - tableViewHeightContraint.constant;
             middleViewTopConstraint.constant = (self.view.frame.size.height - [self statusBarHeight]-tableViewHeightContraint.constant - middleViewHeightConstraint.constant)*0.5f;
            //bottomMenuBottomConstraint.constant = - bottomMenuHeightConstraint.constant;
            [self.view layoutIfNeeded];
            
            
        } completion:^(BOOL finished) {
            
        }];

        
    }];
    
}

-(IBAction)btnRefreshPressed:(id)sender {
    
    btnRefresh.hidden = YES;
    [activityIndicator startAnimating];
    [self loadHistoryRates];
    [self loadCurrentRates];
    
}

#pragma mark Private

-(float)statusBarHeight {
    
    return 20;
}

-(void) layoutScreenViews {
    
    tableViewTopContraint.constant = (int)self.view.frame.size.height-[self statusBarHeight];
    int viewMaxHeight = self.view.frame.size.height-[self statusBarHeight]  - middleViewHeightConstraint.constant - [self statusBarHeight];
    int tableMaxHeight = 44*currencyArray.count;
    tableViewHeightContraint.constant = viewMaxHeight>tableMaxHeight ? tableMaxHeight : viewMaxHeight;
    _tableView.scrollEnabled =viewMaxHeight>tableMaxHeight ? NO : YES;

    
    middleViewTopConstraint.constant = (self.view.frame.size.height-[self statusBarHeight] - bottomMenuHeightConstraint.constant - middleViewHeightConstraint.constant)*0.5f;
    
}

-(void)dismissTableView {
    
    if (bottomMenuIsShow) {
        
        bottomMenuIsShow = NO;
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            tableViewTopContraint.constant =self.view.frame.size.height-[self statusBarHeight];
             middleViewTopConstraint.constant = (self.view.frame.size.height-[self statusBarHeight] -bottomMenuHeightConstraint.constant - middleViewHeightConstraint.constant)*0.5f;
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                bottomMenuBottomConstraint.constant = 0;
                [self.view layoutIfNeeded];
                
            } completion:^(BOOL finished) {
                
            }];
            
        }];
        
    }
    
}

-(void) fillCurrenciesArray {
    
    NSArray  *dictArray = @[
                            @{kSource:@"USD",kOutput:@"RUB"},
                            @{kSource:@"USD",kOutput:@"EUR"},
                            @{kSource:@"EUR",kOutput:@"USD"},
                            @{kSource:@"EUR",kOutput:@"RUB"},
                            @{kSource:@"RUB",kOutput:@"USD"},
                            @{kSource:@"RUB",kOutput:@"EUR"},
                            ];
    
    currencyArray = dictArray;
    
}

-(void) loadHistoryRates {
    
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    historyLoading = YES;
    [[APIClient sharedInstance] getRates:@"USD" outputCurrency:@"EUR,RUB" FromDate:yesterday WithcompletionHandler:^(BOOL succes, NSDictionary *quotes, NSError *error) {
        historyLoading = NO;
        if (succes) {
           
            historyRates = [self getRatesFromDict:quotes];
            
            
        } else {
            
            NSLog(@"%@",error);
        }
        
        [self updateView];
        
    }];
    
    
}

-(void) loadCurrentRates {
    
    currentDataloading = YES;
    [[APIClient sharedInstance] getRates:@"USD" outputCurrency:@"EUR,RUB" WithcompletionHandler:^(BOOL succes, NSDictionary *quotes, NSError *error) {
        currentDataloading = NO;
        if (succes) {
            
            currentRates = [self getRatesFromDict:quotes];
            updateDate = [NSDate date];;
            
        } else {
            
            NSLog(@"%@",error);
            
        }
        
        [self updateView];
        
    }];
    
    
}


-(NSArray*) getRatesFromDict:(NSDictionary*)dict {
    
   // NSMutableArray *array = [NSMutableArray new];
    
    NSNumber *USDEUR =dict[@"USDEUR"];
    NSNumber *USDRUB =dict[@"USDRUB"];
    NSNumber *EURUSD =@( 1.0f/[USDEUR floatValue] );
    NSNumber *EURRUB =@( [USDRUB floatValue]/[USDEUR floatValue] );
    NSNumber *RUBUSD =@( 1.0f/[USDRUB floatValue] );
    NSNumber *RUBEUR =@( [USDEUR floatValue]/[USDRUB floatValue] );
    
    NSArray *array = @[USDRUB,USDEUR,EURUSD,EURRUB,RUBUSD,RUBEUR];
    
    return array;
    
}

-(void) updateView {
    
    
    NSDictionary *dict =currencyArray[selectedPairID];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:dict[kSource]];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [self colorImage:[UIImage imageNamed:@"arrow"] color:lblRatePairColor] ;
    
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    [attributedString insertAttributedString:attrStringWithImage atIndex:attributedString.length];
    [attributedString insertAttributedString:[[NSMutableAttributedString alloc] initWithString:dict[kOutput]] atIndex:attributedString.length];
    
    [attributedString addAttributes:@{
                                     NSFontAttributeName : lblRatePairFont,
                                     NSForegroundColorAttributeName : lblRatePairColor,
                                     }
                              range:NSMakeRange(0, attributedString.length)];
    
    lblRateName.attributedText  = attributedString;
    
    if (currentRates !=nil && currentRates.count>selectedPairID) {
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:3];
        [formatter setMinimumFractionDigits:3];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                initWithString:[formatter stringFromNumber:currentRates[selectedPairID]]
                                                attributes:
                                                @{
                                                  NSFontAttributeName : lblRatesFont,
                                                  NSForegroundColorAttributeName : lblRatesColor,
                                                  NSKernAttributeName : @(-4.0f)
                                                  }];
        
        
        lblRateValue.attributedText  = attributedString;
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"hh:mm"];
        NSString *dateString = [dateFormat stringFromDate:updateDate];
        
        attributedString = [[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"updated",nil),dateString]
         attributes:
         @{
           NSFontAttributeName : lblUpdateFont,
           NSForegroundColorAttributeName : lblUpdateColor,
           NSKernAttributeName : @(2.0f)
           }];
        
        lblUpdated.attributedText = attributedString;

        
        //lblUpdated.text =[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"updated",nil),dateString];
        UIColor *historyColor = lblHistoryColor;
        if (historyRates !=nil && historyRates.count>selectedPairID) {
            
            NSNumber *curRate =currentRates[selectedPairID];
            NSNumber *hisRate =historyRates[selectedPairID];
            float percentFloat = 1-([hisRate floatValue] / [curRate floatValue]);
            int percentInt = (percentFloat * 100) ;
            NSDictionary *dict =currencyArray[selectedPairID];
            NSString *currencyName = [self currencyWithAbbreviation:dict[kSource]];
            NSString *percentName = [self percentName:abs(percentInt) ];
            NSString *historyText = @"";
            if (percentInt>0) {
                historyText =[NSString stringWithFormat:@"%@ %@\n%@ %i %@",
                                      NSLocalizedString(@"Since yesterday", nil),
                                      currencyName,
                                      NSLocalizedString(@"grow by", nil),
                                      abs(percentInt),
                                      percentName];
                
            }
            else if (percentInt<0) {
                historyColor = lblHistoryRedColor;

                historyText =[NSString stringWithFormat:@"%@ %@\n%@ %i %@",
                                      NSLocalizedString(@"Since yesterday", nil),
                                      currencyName,
                                      NSLocalizedString(@"fell by", nil),
                                      abs(percentInt),
                                      percentName];
                
            }
            else {
                if (percentFloat > 0) {
                    
                    historyText =[NSString stringWithFormat:@"%@ %@\n%@",
                                          NSLocalizedString(@"Since yesterday", nil),
                                          currencyName,
                                          NSLocalizedString(@"grow less than 1 percent", nil)];
                    
                    
                }
                else if (percentFloat < 0) {
                    historyColor = lblHistoryRedColor;
                    historyText =[NSString stringWithFormat:@"%@ %@\n%@",
                                          NSLocalizedString(@"Since yesterday", nil),
                                          currencyName,
                                          NSLocalizedString(@"fell less than 1 percent", nil)];
                    
                }
                else {
                   
                    historyText =[NSString stringWithFormat:@"%@ %@\n%@",
                                          NSLocalizedString(@"Since yesterday", nil),
                                          currencyName,
                                          NSLocalizedString(@"not changed", nil)];
                    
                }
                
                
            }
            
            NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                    initWithString:historyText
                                                    attributes:
                                                    @{
                                                      NSFontAttributeName : lblHistoryFont,
                                                      NSForegroundColorAttributeName : historyColor,
                                                      }];
            
            lblRateHistory.attributedText = attributedString;
            
            
            
        }
        
    }
    
    if (currentDataloading == NO && historyLoading == NO) {
        
        btnRefresh.hidden = NO;
        [activityIndicator stopAnimating];
    }
    
    
    
}

-(NSString*)currencyWithAbbreviation:(NSString*)abbr {
    
   if ([abbr isEqualToString:@"USD"]) return NSLocalizedString(@"dollar",nil);
   else if ([abbr isEqualToString:@"RUB"]) return NSLocalizedString(@"ruble",nil);
   else if ([abbr isEqualToString:@"EUR"]) return  NSLocalizedString(@"euro",nil);

    return nil;

    
}

-(NSString*)percentName:(int)_value {
    
    int value = _value % 10 ;
    
    if (value ==1) {
        
        return NSLocalizedString(@"percent",nil);
    } else if (value >1 && value <5) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString:@"ru"]) {
            return NSLocalizedString(@"percentsAdditional",nil);
        } else {
            return NSLocalizedString(@"percents",nil);
        }
        
    } else {
        return NSLocalizedString(@"percents",nil);
    }
    
}

- (void) printAvailableFonts {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *family in familyNames) {
        NSArray *fonts = [UIFont fontNamesForFamilyName:family];
        if (fonts) {
            [dict setObject:fonts forKey:family];
        }
    }
    
    NSLog(@"fonts = %@", dict);
}

- (UIImage *)colorImage:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

#pragma mark - Table view data source and delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currencyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoneyTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MoneyTypeTableViewCell class]) forIndexPath:indexPath];
    
    NSDictionary *dict =currencyArray[indexPath.row];
    
    [cell setPairSource:dict[kSource] output:dict[kOutput]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self dismissTableView];
    selectedPairID = indexPath.row;
    NSDictionary *dict =currencyArray[indexPath.row];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithString:[NSString stringWithFormat:@"%@-%@",dict[kSource],dict[kOutput]]
                                            attributes:
                                            @{
                                              NSFontAttributeName : lblRatePairFont,
                                              NSForegroundColorAttributeName : lblRatePairColor,
                                              //NSKernAttributeName : @(-4.0f)
                                              }];
    
    
    lblRateName.attributedText  = attributedString;
    
    [self updateView];
    
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

@end
