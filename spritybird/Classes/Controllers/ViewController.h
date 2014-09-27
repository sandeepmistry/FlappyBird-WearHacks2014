//
//  ViewController.h
//  spritybird
//
//  Created by Alexis Creuzot on 09/02/2014.
//  Copyright (c) 2014 Alexis Creuzot. All rights reserved.
//

#import "Scene.h"

#import "DF1Manager.h"

@interface ViewController : UIViewController<SceneDelegate, DF1ManagerDelegate, DF1Delegate>

@property (nonatomic, strong) DF1Manager *df1Manager;
@property (nonatomic, strong) DF1 *df1;

@end
