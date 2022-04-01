# Getting started with TLKit for iOS

This document contains a quick start guide for integrating `TLKit`
into your iOS application. More detailed documentation of the APIs can
be found in the `docs` folder. The API documents can be opened by
opening the file `docs/index.html` in your web browser.

# Sample Project

Checkout our sample project `TLKitExample` for a simple working example of
how developers can use `TLKit`.

# Integrating TLKit framework into a project

## Option 1: CocoaPods

We recommand installing `TLKit` using [CocoaPods](http://cocoapods.org/), which
provides a simple dependency management system that automates the error-prone
process of manually configuring libraries. First make sure you have `CocoaPods`
installed (you will also need to have Ruby installed):

```
sudo gem install cocoapods
pod setup
```

Now create an empty file in the root of your project directory, and name it
`Podfile` or just run the following command:

```
pod init
```

Open and edit the `Podfile` as follow:

```ruby
source 'https://github.com/tourmalinelabs/iOSTLKitSDK.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

pod 'TLKit'
...
```

_Note_:  sources declaration order matters. To avoid pod conflicts with other public
repositories, please ensure to declare `https://github.com/tourmalinelabs/iOSTLKitSDK.git` first.

Finally, save and close the `Podfile` and run `pod install` to setup your
`CocoaPods` environment and import `TLKit` into your project. Make sure to start
working from the `.xcworkspace` file that `CocoaPods` automatically creates, not
 the `.xcodeproj` you may have had open.

That's it! You can start coding!

## Option 2: Manual installation

While Cocoapods are the recommended method for Adding TLKit to a project it can
also be adde. This also requires manually adding it's dependent frameworks,
configuring linking, and configuring background modes.

### Adding the TLKit framework
A zip file containing the framework can be downloaded from
[here](https://s3.amazonaws.com/tlsdk-ios-stage-frameworks/TLKit-17.4.22032800.zip).
Once unzipped the file can be added to an existing project by dragging the
framework into that project, or following the
[instructions provided Apple](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_a_Framework.html).

### Dependent frameworks

In project configuration under
`General > Linked Frameworks and Libraries` add the following
dependencies

* `TLKit.framework`
* `SystemConfiguration.framework`
* `CoreMotion.framework`
* `CoreLocation.framework`
* `Security.framework`
* `libstdc++.tbd`
* `libz.tbd`

### Linking  

For each target using `TLKit`, in the configuration under
`Build Settings > Other Linker Flags` make sure the following flags are
set `-lm -all_load -ObjC`

If you see errors related to linking, it is possible that
`libc++` is not being linked for you. To solve this either change one
file extension from `.m` to `.mm` or add a new empty `c++` file to the
project.

If you see errors related to duplicated symbols or similar linking
errors this could be caused by the above linking flags. In this case just try
to replace `-lm -all_load -ObjC` with `-force_load TLKit.framework/Versions/A/TLKit`

## Configure Background Modes

Under `Capabilities > Background Modes` check the box next to
`Location Updates`

# Using TLKit

The heart of the TLKit is the Context Engine. The engine needs to
be initialized with some user information and a drive detection mode in order to
use any of its features.

## User information

There are two types of user information that can be used to initialize the
engine:
  1. A SHA-256 hash of some user id. Currently only hashes of emails are allowed
  but other TL approved ids could be used.
  2. An application specific username and password.

The first type of user info is appropriate for cases where the SDK is used only
for data collection. The second type is useful in cases where the application
wants to access the per user information and provide password protected access
to it to it's users.

## Automatic and manual modes

The engine can be initialized for either automatic drive detection where the SDK
will automatically detect and monitor drives or a manual drive detection where
the SDK will only monitor drives when explicitly told to by the application.

The first mode is useful in cases where the user is not interacting with the
application to start and end drives. While the second mode is useful when the
user will explicitly start and end drives in the application.

## Example initialization with SHA-256 hash in automatic mode

The below examples demonstrate initialization with just a SHA-256 hash. The
example application provides code for generating this hash.

Once started in this mode the engine is able to automatically detect and record
all drives.

```objc
NSString *hashedId = [self hashedId:@"iosexample@tourmalinelabs.com"];

[CKContextKit initWithApiKey:API_KEY
                    hashedId:hashedId
                        mode:CKMonitoringModeAutomatic
               launchOptions:nil
           withResultToQueue:dispatch_get_main_queue()
                 withHandler:^(BOOL successful, NSError *error) {
                     if (error) {
                         NSLog(@"Failed to start TLKit: %@", error);
                         return;
                     }
                 }];
```


## Trouble shooting
At initialization, `CKContextKit` attempts to validate  permissions and see
other necessary conditions are met when initializing the engine. If any of these
conditions are not met it will fail with an `error` that can be used to debug
the issue.

One example of where a failure would occur would be location permissions
not being enabled for the application.

### Destroying an engine.

Once initialized there is no reason to destroy the engine unless you need to
set a new `CKAuthenticationManagerDelegate` for a different user or password. Or In
those cases, the engine can be destroyed as follows:

`CKContextKit` can be destroyed as follows

```objc
[CKContextKit destroyWithResultToQueue:dispatch_get_main_queue()
                           withHandler:^(BOOL successful, NSError *error) {
                            if (error) {
                                NSLog(@"Stopping ContextKit Failed: %@",
                                    error);
                                return;
                            }
                            NSLog(@"Stopped ContextKit!");
                        }];
```

### Pre-authorize Location Manager access

`CKContextKit` utilizes GPS as one of it's context sensor. As such it is
best practice to request "Always" authorization from
the user for accesssing location prior to initializing the engine.

_Note_: iOS 14 introduced location permissions precise vs. approximate location.
This is necessary to have Precise Locations allowed to record drives.

### Pre-authorize Motion & Fitness access

`CKContextKit` uses Motion & Fitness data to:
- Improve drive start and end detection.
- Increase driving behavior event accuracy.
- Reduce battery consumption.

Although this is not mandatory this is highly recommended to request
Motion & Fitness authorization prior to initializing the engine.

## Drive Monitoring

Drive monitoring functionality is accessed through the
`CKActivityManager`

```objc
self.actMgr = [CKActivityManager new];
```

### Starting and stopping manual drives

If the engine was initialized into manual mode, drives can be started and
stopped as follows.

```objc
NSUUID *driveId = [self.activityManager startManualTrip];
```

```objc
[self.actMgr stopManualTrip: driveId];
```

Multiple overlapping manual drives can be started at the same time.


### Registering a drive event listener

The application can register to receive drive start, update and events as
follows.

Register a listener with the drive monitoring service as follows.

```objc
[self.actMgr
    listenForDriveEventsToQueue:dispatch_get_main_queue()
                    withHandler:^(CKActivityEvent *evt, NSError *error) {
                        // handle error
                        if (error) {
                            NSLog(@"Failed to register lstnr: %@", error);
                            return;
                        }

                        NSLog(@"New CKActivityEvent: %@", evt);
                    }];
```

_Note_: multiple drive events may be received for the same drive as the drive
progresses and the drive processing updates the drive with more accurate map
points.

Drive events can be stopped as follows

```objc
[self.actMgr stopListeningForDriveEvents];
```

### Querying previous drives

Once started all drives will be recorded for querying either by date:

```objc
#import <TLKit/CKContextKit.h>
...

[self.actMgr queryDrivesFromDate:[NSDate distantPast]
                          toDate:[NSDate distantFuture]
                       withLimit:100
                         toQueue:dispatch_get_main_queue()
                     withHandler:^(NSArray *drives, NSError *error) {
                         if (!error) {
                             NSLog(@"Got drives: %@", drives);
                         }
                     }];
```    

or by id:

```objc    
NSUUID *driveId = ...;
[self.actMgr queryDriveById:driveId
                    toQueue:dispatch_get_main_queue()
                withHandler:^(NSArray *drives, NSError *err) {
                    if (!error) {
                        NSLog(@"Found drive %@", drives[0]);
                    }
                }];
```   

## Telematics monitoring

Telematics monitoring functionality is accessed through the `CKActivityManager` as well.
(see Drive monitoring above).

### Registering a telematics event listener

The application can register to receive telematics events as follows.

```objc
[self.actMgr
    listenForTelematicsEventsToQueue:dispatch_get_main_queue()
                         withHandler:^(CKTelematicsEvent *evt,
                            NSError *error) {
                            if (error) {
                                NSLog(@"Telematics event failed with error %@",
                                    error);
                            } else {
                                NSLog(@"Telematics event: %@",
                                    evt.description);
                            }
                        }];
```

_Note_: like for the drive monitoring multiple telematics events may be received for the same
drive.

Telematics events can be stopped as follows

```objc
[self.actMgr stopListeningForTelematicsEvents];
```

### Querying telematics events for a specific drive

Query telematics events for a specific drive as follows.

```objc
#import <TLKit/CKContextKit.h>
...
NSUUID *driveId = ...;
[self.actMgr
    queryTelematicsEventsForTrip:driveId
                         toQueue:dispatch_get_main_queue()
                     withHandler:^(NSArray *results, NSError *error) {
                         if (error) {
                             NSLog(@"Telematics query failed with error %@",
                                 error);
                         } else {
                             NSLog(@"Got telematics events: %@",
                                 results);
                         }
                     }];

```

## Low power location monitoring

`TLKit` provides its own location manager class `CKLocationManager` which
provides low power location monitoring.

Instantiation of the manager is as follows.

```objc
#import <TLKit/CKContextKit.h>
...
CKLocationManager *locMgr = [CKLocationManager new];
```

### Registering for location updates

An example of using the manager to receive location updates is provided below.

A listener must be registered to begin receiving location updates as follows:

```objc
[locMgr startUpdatingLocationsToQueue:dispatch_get_main_queue()
                          withHandler:^(CKLocation *location) {
                              NSLog(@"New location update %@", [location description]);
                          }
                           completion:^(BOOL successful, NSError* error) {
                               if (successful) {
                                   NSLog(@"Started Location updates!");
                               }
                          }];
```

A listener can be unregistered as follows:

```objc
[locMgr stopUpdatingLocation];
```    


### Querying location history

`CKLocationManager` provides the ability to query past locations via
`queryLocations` method. The query locations method can be used as follows:

```objc    
[locMgr queryLocationsFromDate:[NSDate distantPast]
                        toDate:[NSDate distantFuture]
                     withLimit:30
                       toQueue:dispatch_get_main_queue()
                   withHandler:^(NSArray *locs, NSError *error ) {
                       NSLog( @"DB Query Result:" );
                       for ( id l in locs ) { NSLog(@"%@\n", l); }
                   }];
```

_Note_: This will only include locations that were recorded while a listener
was registered as stated in the previous section.

# Trouble Shooting

## Crash Reporting

As crashes may happen and disturb the activity recording, it is important to monitor the app health by using a crash reporter. To give integrators the choice of tools as well as to avoid dependency conflicts, TLKit does not embed any crash reporting tool into the sdk. We highly recommend that integrators install a third-party crash reporting library such as Firebase Crashlytics, Sentry, etc.

At Tourmaline Labs we are using Firebase Crashlytics in our own apps:
https://firebase.google.com/docs/crashlytics/get-started

_Note:_ TLKit is built with bitcode enabled then your app will contain the symbols at compilation time.

## Out of date TLKit Cocoapod
Errors like
```
No visible @interface for 'CKActivityManager' declares the selector 'stopManualTrip:'
```
or
```
No known class method for selector 'initAutomaticWithApiKey:authMgr:launchOptions:withResultToQueue:withHandler:'
```
Your TLKit Cocoapod is out of date it can be updated as follows:

```bash
pod update TLKit
```
