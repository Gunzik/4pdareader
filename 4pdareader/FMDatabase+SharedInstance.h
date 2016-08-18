//
//  FMDatabase+SharedInstance.h
//  Cook in owen
//
//  Created by Nikita Kuznetsov on 15.09.14.
//  Copyright (c) 2014 Nikita Kuznetsov. All rights reserved.
//



#import "FMDatabase.h"



@interface FMDatabase (SharedInstance)


+ (FMDatabase *)sharedInstance;

+ (void)setSharedInstance:(FMDatabase *)sharedInstance;


@end
