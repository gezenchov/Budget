//
//  NSFileManager+DoNotBackup.h
//  Budget
//
//  Created by Petar Gezenchov on 19/02/2016.
//  Copyright © 2016 PTG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DoNotBackup)

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

@end
