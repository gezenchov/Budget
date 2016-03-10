//
//  PTGApplicationManager.m
//  Budget
//
//  Created by Petar Gezenchov on 10/03/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "PTGApplicationManager.h"

@implementation PTGApplicationManager

+ (instancetype)sharedManager {
    static PTGApplicationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coreDataManager = [PTGCoreDataManager new];
    }
    return self;
}

@end
