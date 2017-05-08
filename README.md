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
have a server component we provide the `CKDefaultAuth` class which will provide 
registration and authentication services for the TL Server.

Initialization with the `CKDefaultAuth` is covered in the next section.

## Initializing and destroying the engine

There are two manners of initializing the engine depending on your needs. An 
automatic drive detection mode where the SDK will automatically detect and 
monitor drives and a manual mode where the SDK will only monitor drives when 
explicitly told to by the application.

The first mode is useful in cases where the user is not interacting with the 
application to start and end drives. While the second mode is useful when the 
user will explicitly start and end drives in the application.

Regardless of the mode it is started in, `CKContextKit` attempts to validate 
permissions and see other necessary conditions are met when initializing the 
engine. If any of these conditions are not met it will fail with an `error` that
can be used to debug the issue.

One example of where a failure would occur would be location permissions
not being enabled for the application.

### Initializing the engine for automatic drive monitoring  

Once started in this mode the engine is able to automatically detect and record 
all drives.

```objc 
[CKContextKit initAutomaticWithApiKey:API_KEY
                              authMgr:[[CKDefaultAuth alloc] 
                                  initWithApiKey:API_KEY 
                                          userId:USERNAME 
                                            pass:PASSWORD]
                        launchOptions:nil
                    withResultToQueue:dispatch_get_main_queue()
                          withHandler:^(BOOL __unused successful, 
                                        NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Failed to start TLKit: %@", error);
                                  return;
                              }
                          }];
}
```     

### Initializing the engine for manual drive monitoring  

```objc 
[CKContextKit initManualWithApiKey:API_KEY
                           authMgr:[[CKDefaultAuth alloc] 
                               initWithApiKey:API_KEY 
                                       userId:USERNAME 
                                         pass:PASSWORD]
                     launchOptions:nil
                 withResultToQueue:dispatch_get_main_queue()
                       withHandler:^(BOOL __unused successful, 
                                     NSError * _Nullable error) {
                           if (error) {
                               NSLog(@"Failed to start TLKit: %@", error);
                               return;
                           }
                       }];
```     

### Destroying an engine.

Once initialized there is no reason to destroy the engine unless you need to 
set a new `CKAuthenticationManagerDelegate` for a different user or password. Or In
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
NSUUID* driveId = [self.activityManager startManualTrip];
```

```objc
[self.activityManager stopManualTrip: driveId];
```

Multiple overlapping manual drives can be started at the same time.


### Registering a drive event listener

The application can register to receive drive start, update and events as 
follows.

Register a listener with the drive monitoring service as follows.

```objc
[self.activityManager 
    listenForDriveEventsToQueue:dispatch_get_main_queue()
                    withHandler:^(CKActivityEvent * _Nullable evt, 
                        NSError * _Nullable error) {
                                          
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

# Trouble Shooting

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
