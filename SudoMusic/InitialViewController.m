//
//  InitialViewController.m
//  SudoMusic
//
//  Created by Hongyu Li on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import "InitialViewController.h"
#import "QRCodeReaderViewController.h"
#import "SongQueueTableViewController.h"

@interface InitialViewController () <QRCodeReaderDelegate> {
    
}
@property BOOL firstLoad;
@property NSMutableArray *songs;
@property NSMutableArray *artists;
@property NSMutableArray *upvotes;
@property NSMutableArray *downvotes;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sudoPlay bg_ip5size_text.png"]];
    // Do any additional setup after loading the view.
    _songs = [[NSMutableArray alloc] init];
    _artists = [[NSMutableArray alloc] init];
    _upvotes = [[NSMutableArray alloc] init];
    _downvotes = [[NSMutableArray alloc] init];
    _firstLoad = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanAction:(id)sender
{
    static QRCodeReaderViewController *reader = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader                        = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
    });
    reader.delegate = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"Completion with result: %@", resultAsString);
    }];
    
    [self presentViewController:reader animated:YES completion:NULL];
}

- (BOOL) validateURL: (NSString*) candidate {
    NSURL *candidateURL = [NSURL URLWithString:candidate];
    return (candidateURL && candidateURL.scheme && candidateURL.host);
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    BOOL isValidURL = [self validateURL:result];
    if (isValidURL) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:result parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (_firstLoad) {
                NSLog(@"JSON: %@", responseObject);
                
                
                [self dismissViewControllerAnimated:YES completion:^{
                    [self performSegueWithIdentifier:@"AfterScan" sender:responseObject];
                }];
                _firstLoad = NO;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
        }];
    } else {
        // Wrong code
        NSLog(@"Error");
    }
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"AfterScan"]) {
        SongQueueTableViewController *sqtvc = (SongQueueTableViewController *)[segue destinationViewController];
        
        NSMutableArray *songs = [[NSMutableArray alloc] init];
        NSMutableArray *artists = [[NSMutableArray alloc] init];
        NSMutableArray *upvotes = [[NSMutableArray alloc] init];
        NSMutableArray *downvotes = [[NSMutableArray alloc] init];
        NSMutableArray *songIDs = [[NSMutableArray alloc] init];
        
        NSInteger i = 0;
        for (NSMutableDictionary *dict in (NSArray*) sender) {
            NSMutableDictionary *fds = [dict valueForKey:@"fields"];
            NSString* sid = [dict valueForKey:@"pk"];
            NSString* up = [fds valueForKey:@"upvotes"];
            NSString* dw = [fds valueForKey:@"downvotes"];
            NSString* nm = [fds valueForKey:@"name"];
            NSString* at = [fds valueForKey:@"information"];
            
            [songs addObject:nm];
            [artists addObject:at];
            [upvotes addObject:up];
            [downvotes addObject:dw];
            [songIDs addObject:sid];
            
            BOOL playing = [fds valueForKey:@"playing"];
            if (playing) {
                sqtvc.nowPlayingIndex = i;
            }
            i++;
        }
        
        sqtvc.songs = [songs copy];
        sqtvc.artists = [artists copy];
        sqtvc.upvotes = [upvotes copy];
        sqtvc.downvotes = [downvotes copy];
        sqtvc.songIDs = [songIDs copy];
    }
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
}

@end
