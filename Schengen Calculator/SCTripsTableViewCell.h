//
//  SCTripsTableViewCell.h
//  Schengen Calculator
//
//  Created by Vit on 22.06.15.
//  Copyright (c) 2015 ELTIMA LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTripsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateInLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOutLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
