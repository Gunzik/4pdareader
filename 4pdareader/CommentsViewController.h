//
//  CommentsViewController.h
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UIViewController

- (IBAction)actionClose:(id)sender;

@property (nonatomic, strong) NSURL *commentUrl;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
