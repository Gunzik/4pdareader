//
//  DetailViewController.h
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSItem.h"

@interface DetailViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
    BOOL inFavorite;
    long long expectedLength;
    long long currentLength;
}

@property (nonatomic,strong) RSSItem *detail;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *favorites;


- (IBAction)actionFavorites:(id)sender;

@end
