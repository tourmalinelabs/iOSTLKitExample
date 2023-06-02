/* *****************************************************************************
 * Copyright 2023 Tourmaline Labs, Inc. All rights reserved.
 * Confidential & Proprietary - Tourmaline Labs, Inc. ("TLI")
 *
 * The party receiving this software directly from TLI (the "Recipient")
 * may use this software as reasonably necessary solely for the purposes
 * set forth in the agreement between the Recipient and TLI (the
 * "Agreement"). The software may be used in source code form solely by
 * the Recipient's employees (if any) authorized by the Agreement. Unless
 * expressly authorized in the Agreement, the Recipient may not sublicense,
 * assign, transfer or otherwise provide the source code to any third
 * party. Tourmaline Labs, Inc. retains all ownership rights in and
 * to the software
 *
 * This notice supersedes any other TLI notices contained within the software
 * except copyright notices indicating different years of publication for
 * different portions of the software. This notice does not supersede the
 * application of any third party copyright notice to that third party's
 * code.
 * ****************************************************************************/

#import "TripCell.h"
#import "TLTrip+Format.h"

#import <TLKit/TLTrip.h>
#import <TLKit/TLActivityManager.h>

@interface TripCell ()
// IBOutlets
@property (weak,   nonatomic) IBOutlet UILabel  *labelDriveId;
@property (weak,   nonatomic) IBOutlet UILabel  *labelActivityType;
@property (weak,   nonatomic) IBOutlet UILabel  *labelActivityState;
@property (weak,   nonatomic) IBOutlet UILabel  *labelAnalysisState;
@property (weak,   nonatomic) IBOutlet UILabel  *labelDistance;
@property (weak,   nonatomic) IBOutlet UILabel  *labelStartTime;
@property (weak,   nonatomic) IBOutlet UILabel  *labelEndTime;
@property (weak,   nonatomic) IBOutlet UILabel  *labelStartLocation;
@property (weak,   nonatomic) IBOutlet UILabel  *labelEndLocation;
@property (weak,   nonatomic) IBOutlet UILabel  *labelStartAddress;
@property (weak,   nonatomic) IBOutlet UILabel  *labelEndAddress;
@end

@implementation TripCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Public

- (void)configureCellWithTrip:(TLTrip *)trip {
    self.labelDriveId.text       = trip.formattedID;
    self.labelActivityType.text  = trip.formattedType;
    self.labelActivityState.text = trip.formattedState;
    self.labelAnalysisState.text = trip.formattedAnalysisState;
    self.labelDistance.text      = trip.formattedDistance;
    self.labelStartTime.text     = trip.formattedStartTime;
    self.labelEndTime.text       = trip.formattedEndTime;
    self.labelStartLocation.text = trip.formattedStartLocation;
    self.labelEndLocation.text   = trip.formattedEndLocation;
    self.labelStartAddress.text  = trip.formattedStartAddress;
    self.labelEndAddress.text    = trip.formattedEndAddress;
}

@end
