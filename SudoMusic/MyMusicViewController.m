//
//  MyMusicViewController.m
//  SudoMusic
//
//  Created by Jeffrey Liu on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import "MyMusicViewController.h"

@interface MyMusicViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSLog(@"songs: %@", _songs);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MySongCell"];
    UILabel *songLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *upvoteLabel = (UILabel *)[cell viewWithTag:4];
    UILabel *downvoteLabel = (UILabel *)[cell viewWithTag:5];
    upvoteLabel.alpha = 0;
    downvoteLabel.alpha = 0;
    
    if (self.songs && self.artists && self.upvotes && self.downvotes) {
        songLabel.text = [self.songs objectAtIndex:indexPath.row];
        artistLabel.text = [self.artists objectAtIndex:indexPath.row];
    } else {
        songLabel.text = @"Song name: ";
        artistLabel.text = @"Artist name: ";
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
