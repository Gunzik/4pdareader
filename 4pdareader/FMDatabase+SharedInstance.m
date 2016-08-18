//
//  FMDatabase+SharedInstance.m
//  Cook in owen
//
//  Created by Nikita Kuznetsov on 15.09.14.
//  Copyright (c) 2014 Nikita Kuznetsov. All rights reserved.
//


#import "FMDatabase+SharedInstance.h"


static FMDatabase *sDatabase = nil;


@implementation FMDatabase (SharedInstance)

+ (FMDatabase *)sharedInstance
{
    return sDatabase;
}

+ (void)setSharedInstance:(FMDatabase *)sharedInstance
{
    sDatabase = sharedInstance;
}


@end
