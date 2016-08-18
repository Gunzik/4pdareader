//
//  DetailViewController.m
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//

#import "DetailViewController.h"
#import "CommentsViewController.h"
#import "UIView+RNActivityView.h"
#import "FMDatabase+SharedInstance.h"


@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDetail:(RSSItem *)detail {
    
    _detail = detail;
}

-(void)loadData {
    
    [self.navigationController.view.rn_activityView setupDefaultValues];
    [self.navigationController.view showActivityView];
    self.navigationItem.title = _detail.title;
    [self.webView loadRequest:[NSURLRequest requestWithURL:_detail.link]];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    self.navigationController.view.rn_activityView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.navigationController.view.rn_activityView.mode = RNActivityViewModeCustomView;
    self.navigationController.view.rn_activityView.labelText = @"Загружено";
    [self.navigationController.view hideActivityViewWithAfterDelay:0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
 
    self.navigationController.view.rn_activityView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    self.navigationController.view.rn_activityView.mode = RNActivityViewModeCustomView;
    [self.navigationController.view hideActivityViewWithAfterDelay:1];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"commentsSegue"]) {
        
        CommentsViewController *controller = segue.destinationViewController;
        controller.commentUrl = _detail.commentsLink;
        NSLog(@"%@",_detail.commentsLink);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self checkFavorite];
}

- (IBAction)actionFavorites:(id)sender {
    
    [self checkFavorite];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Действия" delegate:self cancelButtonTitle:@"Отменить" destructiveButtonTitle:nil otherButtonTitles:_favorites, nil];
    [actionSheet showInView:self.view];
    

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [self checkFavorite];
        
        NSData *data = [NSData dataWithContentsOfURL:_detail.link];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filename = _detail.title;
        
        filename = [filename stringByAppendingString:@"_htmlfile.html"];
        
        NSString *fhtmlname = filename;
        
        NSString *htmlFilePath = [documentsDirectory stringByAppendingPathComponent:filename];
        NSInteger rowsCount = 0;
        FMDatabase *database = [FMDatabase sharedInstance];
        NSMutableArray *parameterid = [NSMutableArray arrayWithCapacity:1];
        [parameterid addObject:_detail.link];
        FMResultSet *resultSet = [database executeQuery:@"SELECT COUNT(*) FROM news WHERE link_news = (?)" withArgumentsInArray:parameterid];
        if ([resultSet next]) {
            rowsCount = [resultSet intForColumnIndex:0];
        }
        if (rowsCount > 0) {
            NSMutableArray *parameter = [NSMutableArray arrayWithCapacity:1];
            [parameter addObject:_detail.link];
            BOOL updateResult = [database executeUpdate:@"DELETE FROM news WHERE link_news = (?)" withArgumentsInArray:parameter];
            if (!updateResult) {
                NSLog(@"error delete: %@", [database lastError]);
            }
            else {
                if([[NSFileManager defaultManager] fileExistsAtPath:fhtmlname]){
                        [[NSFileManager defaultManager] removeItemAtPath:fhtmlname error:nil];
                }
                NSLog(@"DELETE OK");
            }
        } else {
   
            
                BOOL isSucess = [data writeToFile:htmlFilePath atomically:YES];
                if (isSucess) {
                    
                    NSLog(@"create");
                } else {
                    
                    NSLog(@"not create");
                }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
            NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:1];
            [parameters addObject:_detail.title];
            [parameters addObject:_detail.link];
            [parameters addObject:_detail.commentsLink];
            [parameters addObject: [formatter stringFromDate:_detail.pubDate]];
            [parameters addObject:fhtmlname];
            
            BOOL updateResult = [database executeUpdate:@"INSERT OR REPLACE INTO news (title_news, link_news,comments_news, pubDate_news, htmlpath_news) VALUES (?,?,?,?,?)" withArgumentsInArray:parameters];
            if (!updateResult) {
                
                NSLog(@"error insert: %@", [database lastError]);
                NSLog(@"%@",_detail.title);
            } else {
                
                NSLog(@"INSERT OK");
                [self checkFavorite];
            }
        }
    }
}

-(void)checkFavorite {
    
    NSInteger rowsCount = 0;
    FMDatabase *database = [FMDatabase sharedInstance];
    NSMutableArray *parameter = [NSMutableArray arrayWithCapacity:1];
    [parameter addObject:_detail.link];
    FMResultSet *resultSet = [database executeQuery:@"SELECT COUNT(*) FROM news WHERE link_news = (?)" withArgumentsInArray:parameter];
    if ([resultSet next]) {
        rowsCount = [resultSet intForColumnIndex:0];
    }
    if (rowsCount > 0) {
        _favorites = @"Удалить из избранного";
        inFavorite = YES;

        [self.navigationController.view.rn_activityView setupDefaultValues];
        [self.navigationController.view showActivityView];
        self.navigationItem.title = _detail.title;
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:_detail.content];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
        
        NSLog(@"%@",_detail.content);

    }
    if (rowsCount <= 0) {
        
        [self loadData];
        _favorites = @"В избранное";
        inFavorite = NO;
    }
    
}


@end
