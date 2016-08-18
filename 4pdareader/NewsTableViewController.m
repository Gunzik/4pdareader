//
//  NewsTableViewController.m
//  4pdareader
//
//  Created by Nikita Kuznetsov on 17.08.16.
//  Copyright © 2016 Nikita Kuznetsov. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsTableViewCell.h"
#import "RSSItem.h"
#import "RSSParser.h"
#import "UIView+RNActivityView.h"
#import "DetailViewController.h"
#import "FMDatabase+SharedInstance.h"


@interface NewsTableViewController ()

@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refresh];
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:@"Потяните для обновления"
                                                                      attributes: @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:titleString];
    [refresh addTarget:self action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    refresh.tintColor = [UIColor blackColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.tableView setContentOffset:CGPointMake(0, 0 - refresh.frame.size.height)];
}



-(void)loadData {
    
    NSURL *urlxml = [NSURL URLWithString:@"http://4pda.ru/feed/rss/"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlxml];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    [self.navigationController.view.rn_activityView setupDefaultValues];
    [self.navigationController.view showActivityView];
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
         _data = feedItems;
         [self.tableView reloadData];
     }
                              failure:^(NSError *error) {
         NSLog(@"%@", error);
         self.navigationController.view.rn_activityView.detailsLabelText = error.localizedDescription;
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NewsTableViewCell";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    RSSItem *item = [self.data objectAtIndex:indexPath.row];

    cell.labelTitle.text = item.title;
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    cell.labelPostDate.text =   [formatter stringFromDate:item.pubDate];
    
    return cell;
}

-(void)loadFavorite {
    FMDatabase *database = [FMDatabase sharedInstance];
    
    NSMutableArray *results = [NSMutableArray array];
    FMResultSet *resultSet = [database executeQuery:@"SELECT * FROM news"];
    while ([resultSet next])
    {
        RSSItem *item = [[RSSItem alloc] init];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        item.title = [resultSet stringForColumn:@"title_news"];
        item.link = [NSURL URLWithString:[[resultSet stringForColumn:@"link_news"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        item.commentsLink = [NSURL URLWithString:[[resultSet stringForColumn:@"comments_news"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        item.pubDate = [self getDateFromString:([resultSet stringForColumn:@"pubDate_news"])];
        NSLog(@"%@",[resultSet stringForColumn:@"pubDate_news"]);
        item.content = [resultSet stringForColumn:@"htmlpath_news"];
        [results addObject:item];
    }
    self.data = results;
    [self.tableView reloadData];
}

-(NSDate *)getDateFromString:(NSString *)pstrDate {
    
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dtPostDate = [df1 dateFromString:pstrDate];
    return dtPostDate;
}

-(void)refreshView:(UIRefreshControl *)refresh {
    
    [self.tableView setContentOffset:CGPointMake(0, 0 - refresh.frame.size.height)];
    [refresh beginRefreshing];
    NSAttributedString *titleStringUpd = [[NSAttributedString alloc] initWithString:@"Обновление..."
                                                                         attributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:titleStringUpd];
    if (self.SegmentControll.selectedSegmentIndex == 0) {
        [self loadData];
    }
    else if (self.SegmentControll.selectedSegmentIndex == 1) {
        [self loadFavorite];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Последнее обновление %@",
                             [formatter stringFromDate:[NSDate date]]];
    NSAttributedString *lastUpdatedAtr = [[NSAttributedString alloc] initWithString:lastUpdated
                                                                         attributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithAttributedString:lastUpdatedAtr];
    [refresh endRefreshing];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    expectedLength = MAX([response expectedContentLength], 1);
    currentLength = 0;
    self.navigationController.view.rn_activityView.mode = RNActivityViewModeDeterminate;
    self.navigationController.view.rn_activityView.labelText = @"Загрузка";
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    currentLength += [data length];
    self.navigationController.view.rn_activityView.progress = currentLength / (float)expectedLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.navigationController.view.rn_activityView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    self.navigationController.view.rn_activityView.mode = RNActivityViewModeCustomView;
    self.navigationController.view.rn_activityView.labelText = @"Загружено";
    [self.navigationController.view hideActivityViewWithAfterDelay:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.navigationController.view.rn_activityView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
    self.navigationController.view.rn_activityView.mode = RNActivityViewModeCustomView;
    [self.navigationController.view hideActivityViewWithAfterDelay:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.SegmentControll.selectedSegmentIndex == 0) {
        [self loadData];
    }
    else if (self.SegmentControll.selectedSegmentIndex == 1) {
        [self loadFavorite];
    }
    
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([[segue identifier] isEqualToString:@"newsSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath) {
            NSLog(@"%ld",(long)indexPath.row);
            RSSItem *item = [self.data objectAtIndex:indexPath.row];
            [segue.destinationViewController setDetail:item];
            NSLog(@"%@",item.title);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


}

- (IBAction)actionSegmentControll:(id)sender {
    
    if (self.SegmentControll.selectedSegmentIndex == 0) {
        [self loadData];
    }
    else if (self.SegmentControll.selectedSegmentIndex == 1) {
        [self loadFavorite];
    }
}


@end
