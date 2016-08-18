//
//  NewsTableViewController.h
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"


@interface NewsTableViewController : UITableViewController
{
    RSSItem *dataItem;
    long long expectedLength;
    long long currentLength;
}

@property (strong,nonatomic) NSArray *data;

@property (weak, nonatomic) IBOutlet UIRefreshControl *refreshView;

- (IBAction)actionSegmentControll:(id)sender;

@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentControll;

@end
