//
//  LocationCell.h
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKLocation;

NS_ASSUME_NONNULL_BEGIN

@interface LocationCell : UITableViewCell
- (void)configureCellWithLocation:(CKLocation *)location;
@end

NS_ASSUME_NONNULL_END
