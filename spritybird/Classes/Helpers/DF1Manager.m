//
//  DF1Manager.m
//  spritybird
//
//  Created by Sandeep Mistry on 2014-09-27.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "DF1Manager.h"

@implementation DF1Manager

- (id)initWithDelegate:(id<DF1ManagerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        self.df1s = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self.delegate df1Manager:self didChangeState:central.state];
}

- (void)startScan
{
    [self.centralManager scanForPeripheralsWithServices:@[] options:@{
                                                                      CBCentralManagerScanOptionAllowDuplicatesKey: @YES
                                                                      }];
}

- (void)stopScan
{
    [self.centralManager stopScan];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//     NSLog(@"advertisementData: %@", advertisementData);
    
    for (DF1* df1 in self.df1s) {
        if (df1.peripheral == peripheral) {
            return;
        }
    }
    
    if ([advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString:@"df1"]) {        
        DF1 *df1 = [[DF1 alloc] initWithPeripheral:peripheral];
        
        [self.df1s addObject:df1];
        
        [self.delegate df1Manager:self didDiscover:df1];
    }
}

- (void)connect:(DF1 *)df1
{
    NSLog(@"connect: %@", df1.uuid);
    
    [self.centralManager connectPeripheral:df1.peripheral options:@{
                                                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES
                                                                    }];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    for (DF1* df1 in self.df1s) {
        if (df1.peripheral == peripheral) {
            [self.delegate df1Manager:self didConnect:df1];
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    for (DF1* df1 in self.df1s) {
        if (df1.peripheral == peripheral) {
            [self.delegate df1Manager:self didDisconnect:df1];
            break;
        }
    }
}

@end
