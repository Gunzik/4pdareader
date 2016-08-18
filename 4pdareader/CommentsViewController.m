//
//  CommentsViewController.m
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//


#import "CommentsViewController.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"%@",_commentUrl);
    [self.webView loadRequest:[NSURLRequest requestWithURL:_commentUrl]];
}

- (IBAction)actionClose:(id)sender {
    
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
