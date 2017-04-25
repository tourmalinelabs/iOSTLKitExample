C Getting started with TLKit for iOS

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
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/tourmalinelabs/iOSTLKitSDK.git'

platform :ios, '9.0'

use_frameworks!

pod 'TLKit'
...
```

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
[here](https://s3.amazonaws.com/tlsdk-ios-stage-frameworks/TLKit-7.2.17041800.zip).
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

If you see a lot of errors related to linking, it is possible that 
`libc++` is not being linked for you. To solve this either change one 
file extension from `.m` to `.mm` or add a new empty `c++` file to the 
project.

## Configure Background Modes

Under `Capabilities > Background Modes` check the box next to 
`Location Updates` 

# Using TLKit


The heart of the TLKit is the Context Engine. The engine needs to 
be initialized with a registered user in order to use any of its 
features. 

## Registering and authenticating users.

TLKit needs to be initialized in order to use any of its features and
starting TLKit requires passing an `CKAuthenticationManagerDelegate` instance to
the engine which handles authenticating against the TL Server.

In a production environment authentication should be done between the
Application Server and the TLKit server. This will prevent the API
key from being leaked out as part of SSL proxying attack on the mobile 
device. See the Data Services api on how to register and authenticate a 
user.
 
For initial integration and evaluation purposes or for applications that do not 
have a server component we the `CKDefaultAuth` class which will provide 
registration and authentication services for the TL Server.

Initialization with the `CKDefaultAuth` is covered in the next section.

## Starting, Stopping CKContextKit

An example of initializing the engine with the `CKDefaultAuth` is provided here:

```objc 
#import <TLKit/CKContextKit.h>
...

[CKContextKit initWithApiKey:@"bdf760a8dbf64e35832c47d8d8dffcc0"
                             authMgr:[[CKDefaultAuth alloc]
                                 initWithApiKey:API_KEY
                                         userId:USERNAME
                                           pass:PASSWORD]
                       launchOptions:nil
                   withResultToQueue:dispatch_get_main_queue()
                         withHandler:^(BOOL successful, NSError *error) {
                             if (error) {
                                 NSLog(@"Failed to start TLKit with error: %@",
                                     error);
                                 return;
                             }
                         }];
```     

`CKContextKit` attempts to validate permissions and see other necessary 
conditions are met when initializing the engine. If any of these conditions 
are not met it will fail with an `error` that can be used to debug the 
issue.

One example of where a failure would occur would be location permissions
not being enabled for the application.

Once initialized there is no reason to destroy the engine unless you need to 
set a new `CKAuthenticationManagerDelegate` for a different user or password. In
those cases, the engine can be destroyed as follows:


`CKContextKit` can be destroyed as follows

```objc
[CKContextKit destroyWithResultToQueue:dispatch_get_main_queue()
                           withHandler:^(BOOL successful, NSError *error) {
                            if (error) {
                                NSLog(@"Stopping Contextkit Failed: %@", 
                                    error);
                                return;
                            }
                            NSLog(@"Stopped ContextKit!");
                        }];
```

### Pre-authorize Location Manager access

`CKContextKit` utilizes GPS as one of it's context sensor. As such it is 
best practice to request "Always" authorization from the user for 
accesssing location prior to initializing the engine.

## Monitoring API

By default monitoring is disabled when the Engine is initialized. It needs to be
explicitly enabled to track drives and locations. Enabling is done as follows:
                    
```objectivec
CKContextKit.isMonitoring = YES;
```

Monitoring can be disabled at any time as follows

```objectivec
CKContextKit.isMonitoring = NO;
```

If monitoring is enabled at any point during a drive that drive will be 
recorded.

## Drive Monitoring

Drive monitoring functionality is accessed through the 
`CKActivityManager`

```objc
self.actMgr = [CKActivityManager new];
```

### Starting, Stopping drive monitoring

Register a listener with the drive monitoring service as follows.

```objc
[self.actMgr 
    startDriveMonitoringToQueue:dispatch_get_main_queue()
                    withHandler:^(CKActivityEvent *evt, NSError * err) {
                                // Update UI
                                [weakSelf updateDataSource];
                                NSLog(@"Drive event: %@", evt);
                              }];
```

_Note_: multiple drive events may be received for the same drive as the drive 
progresses and the drive processing updates the drive with more accurate map 
points.

Drive events can be stopped as follows

```objc
[self.actMgr stopDriveMonitoring];
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
[actMgr queryDriveById:driveId
               toQueue:dispatch_get_main_queue() 
           withHandler:^(NSArray *drives, NSError *err) {
               if (!error) {
                   NSLog(@"Found drive %@", drives[0]);
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


