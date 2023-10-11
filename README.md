# Getting started with TLKit for iOS

This document contains a quick start guide for integrating `TLKit`
into your iOS application.

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

platform :ios, '11.0'

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
While Cocoapods is the recommended method for Adding `TLKit` to a project it can
also be added manually. This also requires manually adding it's dependent frameworks,
configuring linking, and configuring background modes.

### Adding the TLKit framework
A zip file containing the framework can be downloaded from
[here](https://s3.amazonaws.com/tlsdk-ios-stage-frameworks/TLKit-22.3.23101001.zip).
Once unzipped the XCFramework file can be added to an existing project by dragging the
framework into that project, or following the
[instructions provided Apple](https://developer.apple.com/library/ios/recipes/xcode_help-structure_navigator/articles/Adding_a_Framework.html).

### Dependent frameworks

In project configuration under
`General > Linked Frameworks and Libraries` add the following
dependencies

* `TLKit.xcframework`
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

`TLKit` needs to be initialized with some information and a trip detection mode 
in order to use any of its features. 

## Initialization

Because of `TLKit` integration, your app will be able to automatically restart in background in different circumstances: significant location changes, geofence event, device reboot, app update, crash... 
When the app starts the AppDelegate's 

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions
```

method is called. It is the integrator responsability to know if `TLKit` was previously running.
If that was the case you must call `[TLKit initWithApiKey:...]` to reauthenticate the user.
This is very important to initialize `TLKit` as quickly as possible to ensure that the keep alive mechanism is effectively set before iOS decides to kill or suspend the app. 
You must not defer the initialization because you need a network reponse or you wait another thread to dispatch some information.

For being able to do that you will probably have to store locally all the starting parameters you need like:
- the API key
- the cloud area (US or EU)
- the user credentials (username and password or hashed id)
- the monitoring mode (Automatic, Manual or Unmonitored)
- the user information (first name, last name, external id, group identifiers to join in case you use the `TLLaunchOptions`...)

### API key

You have to provide an API key associated to your company's account.

### Area

You have to specify the `TLCloudArea`, the default one should always be the US area `TLCloudAreaUS`. If you have been told to do so use the european area `TLCloudAreaEU` instead.

### User credentials

There are two types of user creadentials that can be used to initialize `TLKit`:
  1. A SHA-256 hash of some user id. Currently only hashes of emails are allowed
  but other TL approved ids could be used.
  2. An application specific username and password.

The first type is appropriate for cases where the SDK is used only for data collection. The second type is useful in cases where the application wants to access the per user data and provide password protected access to it to it's users.

### User information (TLLaunchOptions)

Additional information can be passed when initializing `TLKit` such as:
- first name, 
- last name, 
- external identifier, 
- group identifiers to join 

For that we use the `TLLaunchOptions` object like below:

First we capture the launch options dictionary from the `AppDelegate` for passing it later to `TLKit`. This dictionary contains information such as app launch reason (location changes, user launch, remote notification...).

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    
    self.appLaunchOptions = launchOptions;
    
    // call TLKit initialization if needed ...
}
```

Before `TLKit` initialization, create a dictionary containing the `TLLaunchOptions` and the app's launch options dictionary using respectively `TLLaunchOptionsKey` and `TLAppDelegateLaunchOptionsKey` keys:

```objc
// TLLaunchOptions 
TLLaunchOptions *tlLaunchOptions = TLLaunchOptions.new;
tlLaunchOptions.firstname = @"Bob";
tlLaunchOptions.lastname = @"Smith";
tlLaunchOptions.externalId = @"my-company-identifier-xyz";
[tlLaunchOptions addGroupExternalIds:@[@"team_blue", @"team_green"] 
                             toOrgId:123];

NSMutableDictionary *launchOptions = NSMutableDictionary.dictionary;
launchOptions[TLLaunchOptionsKey] = tlLaunchOptions;
if (self.appLaunchOptions != nil) { 
    launchOptions[TLAppDelegateLaunchOptionsKey] = self.appLaunchOptions;
}

// then pass launctOptions to `TLKit`...
```

### Automatic and manual modes

`TLKit` can be initialized for either automatic trip detection where the SDK
will automatically detect and monitor trips or a manual trip detection where
the SDK will only monitor trips when explicitly told to by the application.

The first mode is useful in cases where the user is not interacting with the
application to start and end trips. While the second mode is useful when the
user will explicitly start and end trips in the application.

## Example initialization with SHA-256 hash in automatic mode

The below example demonstrates initialization with just a SHA-256 hash using `TLDigest` helper.

Once started in this mode `TLKit` is able to automatically detect and record
all trips.

```objc
NSString *hashedId = [TLDigest sha256:@"iosexample@tourmalinelabs.com"];

[TLKit initWithApiKey:API_KEY
                 area:TLCloudAreaUS
             hashedId:hashedId
          authHandler:^(TLAuthenticationStatus status, NSError *_Nullable error) {
            ...
          }
                 mode:TLMonitoringModeAutomatic
        launchOptions:launchOptions
    withResultToQueue:dispatch_get_main_queue()
          withHandler:^(BOOL successful, NSError *error) {
            if (error) {
                NSLog(@"Failed to start TLKit: %@", error);
                return;
            }
        }];
```

## Destroying TLKit.

Once initialized there is no reason to destroy `TLKit` unless you need to
authenticate a different user. Or in those cases, `TLKit` can be destroyed as follows:

```objc
[TLKit destroyWithResultToQueue:dispatch_get_main_queue()
                        withHandler:^(BOOL successful, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"Stopping TLKit Failed: %@", error);
                                return;
                            }
                            NSLog(@"Stopped TLKit!");
                        }];
```

### Pre-authorize Location Manager access

`TLKit` utilizes GPS as one of it's context sensor. As such it is
best practice to request "Always" authorization from
the user for accesssing location prior to initializing `TLKit`.

_Note_: iOS 14 introduced location permissions precise vs. approximate location.
This is necessary to have Precise Locations allowed to record trips.

### Pre-authorize Motion & Fitness access

`TLKit` uses Motion & Fitness data to:
- Improve trip start and end detection.
- Increase driving behavior event accuracy.
- Reduce battery consumption.

Although this is not mandatory this is highly recommended to request
Motion & Fitness authorization prior to initializing `TLKit`.

## Trip Monitoring

Trip monitoring functionality is accessed through the `TLActivityManager`

```objc
self.actMgr = [TLActivityManager new];
```

### Starting and stopping manual trips

If `TLKit` was initialized into manual mode, trips can be started and
stopped as follows.

```objc
NSUUID *tripId = [self.activityManager startManualTrip];
```

```objc
[self.actMgr stopManualTrip:tripId];
```

Multiple overlapping manual trips can be started at the same time.

### Registering a trip event listener

The application can register to receive trip start, update and events as
follows.

Register a listener with the trip monitoring service as follows.

```objc
[self.actMgr listenForTripEventsToQueue:dispatch_get_main_queue()
                            withHandler:^(TLActivityEvent *evt, NSError *error) {
                                // handle error
                                if (error) {
                                    NSLog(@"Failed to register lstnr: %@", error);
                                    return;
                                }
                                NSLog(@"New TLActivityEvent: %@", evt);
                            }];
```

_Note_: multiple trip events may be received for the same trip as the trip
progresses and the trip processing updates the trip with more accurate map
points.

Trip events can be stopped as follows

```objc
[self.actMgr stopListeningForTripEvents];
```

### Querying previous trips

Once started all trips will be recorded for querying either by date:

```objc
#import <TLKit/TLKit.h>
...

[self.actMgr queryTripsFromDate:[NSDate distantPast]
                         toDate:[NSDate distantFuture]
                      withLimit:100
                        toQueue:dispatch_get_main_queue()
                    withHandler:^(NSArray *trips, NSError *error) {
                        if (!error) {
                            NSLog(@"Got trips: %@", trips);
                        }
                    }];
```    

or by id:

```objc    
NSUUID *tripId = ...;
[self.actMgr queryTripById:tripId
                   toQueue:dispatch_get_main_queue()
               withHandler:^(NSArray *trips, NSError *err) {
                if (!error) {
                    NSLog(@"Found trip %@", trips[0]);
                }
                }];
```   

## Telematics monitoring

Telematics monitoring functionality is accessed through the `TLActivityManager` as well.
(see Trip monitoring above).

### Registering a telematics event listener

The application can register to receive telematics events as follows.

```objc
[self.actMgr
    listenForTelematicsEventsToQueue:dispatch_get_main_queue()
                         withHandler:^(TLTelematicsEvent *evt,
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

_Note_: like for the trips monitoring multiple telematics events may be received for the same trip.

Telematics events can be stopped as follows

```objc
[self.actMgr stopListeningForTelematicsEvents];
```

### Querying telematics events for a specific trip

Query telematics events for a specific trip as follows.

```objc
#import <TLKit/TLKit.h>
...
NSUUID *tripId = ...;
[self.actMgr
    queryTelematicsEventsForTrip:tripId
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

`TLKit` provides its own location manager class `TLLocationManager` which
provides low power location monitoring.

Instantiation of the manager is as follows.

```objc
#import <TLKit/TLKit.h>
...
TLLocationManager *locMgr = TLLocationManager.new;
```

### Listening for location updates

An example of using the manager to receive location updates is provided below.

A listener must be registered to begin receiving location updates as follows:

```objc
[locMgr listenForLocationEventsToQueue:dispatch_get_main_queue()
                           withHandler:^(TLLocation *location) {
                               NSLog(@"New location update %@", 
                                  location.description);
                           } 
                           completion:^(BOOL successful, NSError* error) {
                               if (successful) {
                                   NSLog(@"Started Location updates!");
                               }
                          }];
```

A listener can be unregistered as follows:

```objc
[locMgr stopListeningForLocationEvents];
```    


### Querying location history

`TLLLocationManager` provides the ability to query past locations via
`queryLocations` method. The query locations method can be used as follows:

```objc    
NSDate *start = ...
NSDate *end = ...
[locMgr queryLocationsFromDate:start
                        toDate:end
                     withLimit:30
                       toQueue:dispatch_get_main_queue()
                   withHandler:^(NSArray *locs, NSError *error ) {
                       NSLog(@"DB Query Result:");
                       for (id l in locs) { NSLog(@"%@\n", l); }
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

Your TLKit Cocoapod is out of date it can be updated as follows:

```bash
pod update TLKit
```
