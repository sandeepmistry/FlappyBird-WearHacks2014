//
//  DF1Manager.h
//  spritybird
//
//  Created by Sandeep Mistry on 2014-09-27.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#include "DF1.h"

@class DF1Manager;

@protocol DF1ManagerDelegate

- (void)df1Manager:(DF1Manager *)manager didChangeState:(CBCentralManagerState)state;
- (void)df1Manager:(DF1Manager *)manager didDiscover:(DF1*)df1;

- (void)df1Manager:(DF1Manager *)manager didConnect:(DF1 *)df1;
- (void)df1Manager:(DF1Manager *)manager didDisconnect:(DF1 *)df1;

@end

@interface DF1Manager : NSObject <CBCentralManagerDelegate>

- (id)initWithDelegate:(id<DF1ManagerDelegate>)delegate;

- (void)startScan;
- (void)stopScan;

- (void)connect:(DF1*)df1;
//- (void)disconnect:(DF1*)df1;

@property (nonatomic, strong) CBCentralManager* centralManager;
@property (nonatomic, weak) id<DF1ManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *df1s;

@end
