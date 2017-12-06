/*******************************************************************************
 * Copyright 2016 Tourmaline Labs, Inc. All rights reserved.
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
 ******************************************************************************/

#import "DriveCell.h"
#import "CKDrive+Format.h"

#import <TLKit/CKDrive.h>
#import <TLKit/CKActivityManager.h>

@interface DriveCell ()
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
@property (weak,   nonatomic) IBOutlet UIButton *buttonStopManualDrive;
// Internal
@property (strong, nonatomic) CKDrive *drive;
// IBActions
- (IBAction)onButtonStopManualDrive:(id)sender;
// Private
- (void)commonInitializer;
@end

@implementation DriveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInitializer];
}

#pragma mark - Public

- (void)configureCellWithDrive:(CKDrive *)drive active:(BOOL)active {
    self.drive                   = drive;
    self.labelDriveId.text       = drive.formattedID;
    self.labelActivityType.text  = drive.formattedType;
    self.labelActivityState.text = drive.formattedState;
    self.labelAnalysisState.text = drive.formattedAnalysisState;
    self.labelDistance.text      = drive.formattedDistance;
    self.labelStartTime.text     = drive.formattedStartTime;
    self.labelEndTime.text       = drive.formattedEndTime;
    self.labelStartLocation.text = drive.formattedStartLocation;
    self.labelEndLocation.text   = drive.formattedEndLocation;
    self.labelStartAddress.text  = drive.formattedStartAddress;
    self.labelEndAddress.text    = drive.formattedEndAddress;
    // hides the stop button for non active manual drive
    self.buttonStopManualDrive.hidden = !active;
}

#pragma mark - IBActions

- (IBAction)onButtonStopManualDrive:(id __unused)sender {
    [CKActivityManager.new stopManualTrip:self.drive.id];
}

#pragma mark - Private

- (void)commonInitializer {
    self.buttonStopManualDrive.layer.cornerRadius  = 4.0f;
    self.buttonStopManualDrive.layer.masksToBounds = YES;
}

@end
