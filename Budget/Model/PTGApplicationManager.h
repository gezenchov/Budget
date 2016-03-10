//
//  PTGApplicationManager.h
//  Budget
//
//  Created by Petar Gezenchov on 10/03/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTGCoreDataManager.h"

@interface PTGApplicationManager : NSObject

@property (nonatomic, strong) PTGCoreDataManager *coreDataManager;

+ (instancetype)sharedManager;

@end
