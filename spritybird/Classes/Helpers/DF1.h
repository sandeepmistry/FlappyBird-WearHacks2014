//
//  DF1.h
//  spritybird
//
//  Created by Sandeep Mistry on 2014-09-27.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class DF1;

@protocol DF1Delegate

- (void)df1DidSetup:(DF1 *)df1;
- (void)df1:(DF1 *)df1 didUpdateX:(float)x y:(float)y z:(float)z;


@end

@interface DF1 : NSObject <CBPeripheralDelegate>

- (id)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)setup;

- (NSString *)uuid;


@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, weak) id<DF1Delegate> delegate;

@property (nonatomic, strong) CBCharacteristic *ledCharacteristic;
@property (nonatomic, strong) CBCharacteristic *configCharacteristic;
@property (nonatomic, strong) CBCharacteristic *enableCharacteristic;
@property (nonatomic, strong) CBCharacteristic *data8Characteristic;

@end
