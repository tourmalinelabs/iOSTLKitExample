//
//  DriveCell.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKDrive;

NS_ASSUME_NONNULL_BEGIN

@interface DriveCell : UITableViewCell
- (void)configureCellWithDrive:(CKDrive *)drive active:(BOOL)active;
@end

NS_ASSUME_NONNULL_END
