//
//  NSFileManager+DoNotBackup.m
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import "NSFileManager+DoNotBackup.h"

#include <sys/xattr.h>

@implementation NSFileManager (DoNotBackup)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return error == nil;
}

@end
