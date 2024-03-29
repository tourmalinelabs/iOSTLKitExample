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

#import "TelematicsCell.h"
#import "TLTelematicsEvent+Format.h"

@interface TelematicsCell ()
// IBOutlets
@property (weak, nonatomic) IBOutlet UILabel *labelTripId;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;
@property (weak, nonatomic) IBOutlet UILabel *labelCoordinate;
@property (weak, nonatomic) IBOutlet UILabel *labelSpeed;
@property (weak, nonatomic) IBOutlet UILabel *labelSeverity;
@end

@implementation TelematicsCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configureCellWithTelematicsEvent:(TLTelematicsEvent *)event {
    self.labelTripId.text     = event.formattedTripID;
    self.labelType.text       = event.formattedType;
    self.labelTime.text       = event.formattedTime;
    self.labelDuration.text   = event.formattedDuration;
    self.labelCoordinate.text = event.formattedCoordinate;
    self.labelSpeed.text      = event.formattedSpeed;
    self.labelSeverity.text   = event.formattedSeverity;
}

@end
