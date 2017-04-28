//
//  LocationCell.m
//  TLKitExample
//
//  Created by Cédric MALKA on 27/04/2017.
//  Copyright © 2017 TL. All rights reserved.
//

#import "LocationCell.h"
#import "CKLocation+Format.h"

@interface LocationCell ()
// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelState;
@end

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Public

- (void)configureCellWithLocation:(CKLocation *)location {
    self.labelLocation.text = location.formattedLocation;
    self.labelTime.text     = location.formattedTime;
    self.labelAddress.text  = location.formattedAddress;
    self.labelState.text    = location.formattedState;
}

@end
