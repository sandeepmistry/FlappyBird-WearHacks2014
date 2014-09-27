//
//  DF1.m
//  spritybird
//
//  Created by Sandeep Mistry on 2014-09-27.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "DF1.h"

@interface NSUUID (Short)

+ (NSUUID *)uuidFromShort:(uint16_t)s;

@end

@implementation CBUUID (Short)

+ (CBUUID *)uuidFromShort:(uint16_t)s
{
    char t[16];
    t[0] = ((s >> 8) & 0xff);
    t[1] = (s & 0xff);
    // if you do all 16 bytes, you get weird results.
    // possibly because the UUID is not exactly in the first 2 butes?
    // NSData *data = [[NSData alloc] initWithBytes:t length:16];
    NSData *data = [[NSData alloc] initWithBytes:t length:2];
    return [CBUUID UUIDWithData:data];
}

@end

@implementation DF1

- (id)initWithPeripheral:(CBPeripheral *)peripheral
{
    if (self = [super init]) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;        
    }
    
    return self;
}

- (void)setup
{
    CBUUID *accelUuid = [CBUUID uuidFromShort:0xaa10];
    CBUUID *testUuid = [CBUUID uuidFromShort:0xaa60];
    
    [self.peripheral discoverServices:@[
                                         accelUuid,
                                         testUuid
                                         ]];
}

- (NSString *)uuid
{
    return self.peripheral.identifier.UUIDString;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in self.peripheral.services) {
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBUUID *ledUuid = [CBUUID uuidFromShort:0xaa62];
    CBUUID *configUuid = [CBUUID uuidFromShort:0xaa11];
    CBUUID *enableUuid = [CBUUID uuidFromShort:0xaa12];
    CBUUID *data8Uuid = [CBUUID uuidFromShort:0xaa13];
    
    for (CBCharacteristic* characteristic in service.characteristics) {
//        NSLog(@"characteristic = %@", characteristic);
        
        if ([characteristic.UUID isEqual:ledUuid]) {
            self.ledCharacteristic = characteristic;
        } else if ([characteristic.UUID isEqual:configUuid]) {
            self.configCharacteristic = characteristic;
        } else if ([characteristic.UUID isEqual:enableUuid]) {
            self.enableCharacteristic = characteristic;
        } else if ([characteristic.UUID isEqual:data8Uuid]) {
            self.data8Characteristic = characteristic;
        }
    }
    
    if (self.ledCharacteristic != nil &&
        self.configCharacteristic != nil &&
        self.enableCharacteristic != nil &&
        self.data8Characteristic != nil) {
        
        uint8_t zero = 0;
//        uint8_t one = 1;
//        uint8_t two = 2;
//        
        NSData *configData = [NSData dataWithBytes:&zero length:sizeof(zero)];
//        NSData *enableData = [NSData dataWithBytes:&one length:sizeof(one)];
//        NSData *ledData = [NSData dataWithBytes:&two length:sizeof(two)];
//        
        [self.peripheral writeValue:configData forCharacteristic:self.configCharacteristic type:CBCharacteristicWriteWithResponse];
//
//        [self.peripheral writeValue:enableData forCharacteristic:self.enableCharacteristic type:CBCharacteristicWriteWithResponse];
//        
//
//        
        [self.peripheral setNotifyValue:YES forCharacteristic:self.data8Characteristic];
//
//                [self.peripheral writeValue:ledData forCharacteristic:self.ledCharacteristic type:CBCharacteristicWriteWithResponse];
        
        [self.delegate df1DidSetup:self];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    NSLog(@"value = %@", characteristic.value);
    
    static float oldZ = 0;
    static float oldDeltaZ = 0;
    
    NSData *data = self.data8Characteristic.value;
    
    const int8_t* rawBytes = data.bytes;
    
    int8_t rawX = rawBytes[0];
    int8_t rawY = rawBytes[1];
    int8_t rawZ = rawBytes[2];
    
    float x = rawX / 64.0;
    float y = rawY / 64.0;
    float z = rawZ / 64.0;
    
//    NSLog(@"%f %f %f", x, y, z);
    
//    NSLog(@"%f", z);
    
    float deltaZ = (oldZ - z);
    
    if (oldDeltaZ > 0 && deltaZ < 0) {
        NSLog(@"FLAPPPPP");
    }
    
    oldZ = z;
    
    oldDeltaZ = deltaZ;
    
//    NSLog(@"%f", deltaZ);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (characteristic == self.configCharacteristic) {
        uint8_t one = 1;
        NSData *enableData = [NSData dataWithBytes:&one length:sizeof(one)];
        
         [self.peripheral writeValue:enableData forCharacteristic:self.enableCharacteristic type:CBCharacteristicWriteWithResponse];
    } else if (characteristic == self.enableCharacteristic) {
        uint8_t two = 2;
        NSData *ledData = [NSData dataWithBytes:&two length:sizeof(two)];
        
        [self.peripheral writeValue:ledData forCharacteristic:self.ledCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}


@end
