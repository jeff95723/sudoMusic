//
//  SongQueueTableViewController.m
//  SudoMusic
//
//  Created by Hongyu Li on 2/7/15.
//  Copyright (c) 2015 Jeffrey Liu. All rights reserved.
//

#import "SongQueueTableViewController.h"
#import "MyMusicViewController.h"

@interface SongQueueTableViewController () <MPMediaPickerControllerDelegate>

@property MPMediaPickerController *picker;
@property NSData* selectedSong;
@property NSURL* selectedURL;
@property NSURL* toURL;
@property TSLibraryImport *importHelper;
@property NSString *selectedSongName;
@property NSString *selectedSongArtist;
@property NSString *selectedSongFileExt;
@property NSMutableArray *MYsongs;
@property NSMutableArray *MYartists;
@property NSMutableArray *MYupvotes;
@property NSMutableArray *MYdownvotes;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation SongQueueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setHidesBackButton:YES];
    
    self.saveButton.enabled = NO;
    self.saveButton.alpha = 0;
//    self.songname.text = @"None.";
//    self.artistname.text = @"None.";
//    [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _MYsongs = [[NSMutableArray alloc] init];
    _MYartists = [[NSMutableArray alloc] init];
    _MYupvotes = [[NSMutableArray alloc] init];
    _MYdownvotes = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:_server parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *TMPsongs = [[NSMutableArray alloc] init];
        NSMutableArray *TMPartists = [[NSMutableArray alloc] init];
        NSMutableArray *TMPupvotes = [[NSMutableArray alloc] init];
        NSMutableArray *TMPdownvotes = [[NSMutableArray alloc] init];
        NSMutableArray *TMPsongIDs = [[NSMutableArray alloc] init];
        
        NSInteger i = 0;
        for (NSMutableDictionary *dict in (NSArray*) responseObject) {
            NSMutableDictionary *fds = [dict valueForKey:@"fields"];
            NSString* sid = [dict valueForKey:@"pk"];
            NSString* up = [fds valueForKey:@"upvotes"];
            NSString* dw = [fds valueForKey:@"downvotes"];
            NSString* nm = [fds valueForKey:@"name"];
            NSString* at = [fds valueForKey:@"information"];
            
            [TMPsongs addObject:nm];
            [TMPartists addObject:at];
            [TMPupvotes addObject:up];
            [TMPdownvotes addObject:dw];
            [TMPsongIDs addObject:sid];
            
            BOOL playing = [fds valueForKey:@"playing"];
            if (playing) {
                _nowPlayingIndex = i;
            }
            i++;
        }
        
        self.songs = [TMPsongs copy];
        self.artists = [TMPartists copy];
        self.upvotes = [TMPupvotes copy];
        self.downvotes = [TMPdownvotes copy];
        self.songIDs = [TMPsongIDs copy];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.tableView reloadData];
        
    }];
}

- (IBAction)addMusicPressed:(id)sender {
    if (!self.picker) {
        self.picker = [[MPMediaPickerController alloc]
                       initWithMediaTypes:MPMediaTypeMusic];
        self.picker.prompt = NSLocalizedString(@"Select song", NULL);
        self.picker.allowsPickingMultipleItems = NO;
        self.picker.delegate = self;
    }
    
    if (!self.importHelper) {
        self.importHelper = [[TSLibraryImport alloc] init];
    }
    
    
    
    [self presentViewController:self.picker animated:YES completion:nil];
}

- (void)saveButtonPressed {
    NSLog(@"Saving start.");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"name": self.selectedSongName, @"information": self.selectedSongArtist};
    AFHTTPRequestOperation *op = [manager POST:@"http://10.0.0.6:8000/users/sample/upload" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:self.toURL] name:@"song" fileName:[NSString stringWithFormat:@"%@-%@.%@",_selectedSongName,_selectedSongArtist,_selectedSongFileExt] mimeType:@"audio/x-m4a"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:self.toURL error:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:self.toURL error:nil];
    }];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op start];
    [_MYsongs addObject:_selectedSongName];
    NSLog(@"mysongs in save: %@", _MYsongs);
    [_MYartists addObject:_selectedSongArtist];
    [_MYupvotes addObject:@"0"];
    [_MYdownvotes addObject:@"0"];
}



- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *theChosenSong = [[mediaItemCollection items]objectAtIndex:0];
    NSString *songTitle = [theChosenSong valueForProperty:MPMediaItemPropertyTitle];
    NSString *artist = [theChosenSong valueForProperty:MPMediaItemPropertyArtist];
    NSString *album = [theChosenSong valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    
    //then just get the assetURL
    NSURL *assetURL = [theChosenSong valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset  *songAsset  = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    self.selectedURL = songAsset.URL;
    self.saveButton.enabled = YES;
    self.selectedSong = [NSData dataWithContentsOfURL:songAsset.URL];
    NSString *fileExt = [TSLibraryImport extensionForAssetURL:self.selectedURL];
    self.selectedSongFileExt= fileExt;
    NSLog(@"URL: %@", fileExt);
    self.selectedSongArtist = songTitle;
    self.selectedSongName = artist;
    
    
    
    //Now that you have this, either just write the asset (or part of) to disk, access the asset directly, send the written asset to another device etc
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.toURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@-%@.%@", documentsDirectory,songTitle, artist, fileExt]];
    
    [self.importHelper importAsset:self.selectedURL toURL:self.toURL completionBlock:^(TSLibraryImport *import) {
    }];
    NSLog(@"Songtitle: %@", songTitle);
    NSLog(@"Artist: %@", artist);
    NSLog(@"NSURL: %@", songAsset.URL);
    NSLog(@"Selected data length: %lu", (unsigned long)_selectedSong.length);
    [self dismissViewControllerAnimated:YES completion:^{
        [self saveButtonPressed];
        NSLog(@"mysongs in save: %@", _MYsongs);
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.songs) {
        NSLog(@"songs count: %lu", (unsigned long)self.songs.count);
        return self.songs.count;
    } else {
        return 10;
    }
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongCell" forIndexPath:indexPath];
    
    UILabel *songLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *artistLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *upvoteLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *downvoteLabel = (UILabel *)[cell viewWithTag:4];
    upvoteLabel.alpha = 0;
    downvoteLabel.alpha = 0;
    
    if (indexPath.row == _nowPlayingIndex) {
        upvoteLabel.alpha = 1;
        upvoteLabel.text = @"►";
    }
//    UIButton *upvote = (UIButton *)[cell viewWithTag:5];
//    UIButton *downvote = (UIButton *)[cell viewWithTag:6];
    
    if (self.songs && self.artists && self.upvotes && self.downvotes && self.songIDs) {
        songLabel.text = [self.songs objectAtIndex:indexPath.row];
        artistLabel.text = [self.artists objectAtIndex:indexPath.row];
//        upvoteLabel.text = [self.upvotes objectAtIndex:indexPath.row];
//        downvoteLabel.text = [self.downvotes objectAtIndex:indexPath.row];
//        NSString *sid = [self.songIDs objectAtIndex:indexPath.row];
//        [upvote addTarget:self action:@selector(upvotePressedWithSID:ChangeLabel:Sender:) forControlEvents:UIControlEventTouchUpInside];
//        [downvote addTarget:self action:@selector(downvotePressedWithSID:ChangeLabel:Sender:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        songLabel.text = @"Song name: ";
        artistLabel.text = @"Artist name: ";
    }
//
    return cell;
}

//-(void) upvotePressedWithSID: (NSString*) sid ChangeLabel: (UILabel*) label Sender: (UIButton *) sender {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"sid": sid};
//    [manager POST:@"http://10.0.0.36:8000/users/sample/upvote" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        NSInteger pastUP = [label.text integerValue];
//        label.text = [NSString stringWithFormat:@"%ld", (pastUP-1)];
//        sender.enabled = NO;
//    }];
//    
//    NSInteger pastUP = [label.text integerValue];
//    label.text = [NSString stringWithFormat:@"%ld", (pastUP+1)];
//    sender.enabled = NO;
//}
//
//
//-(void) downvotePressedWithSID: (NSString*) sid ChangeLabel: (UILabel*) label Sender: (UIButton *) sender {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"sid": sid};
//    [manager POST:@"http://10.0.0.36:8000/users/sample/downvote" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//        NSInteger pastDOWN = [label.text integerValue];
//        label.text = [NSString stringWithFormat:@"%ld", (pastDOWN-1)];
//        sender.enabled = NO;
//    }];
//    
//    NSInteger pastDOWN = [label.text integerValue];
//    label.text = [NSString stringWithFormat:@"%ld", (pastDOWN+1)];
//    sender.enabled = NO;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"goToMyMusic"]) {
        MyMusicViewController *mmvc = [segue destinationViewController];
        mmvc.songs = [_MYsongs copy];
        mmvc.artists = [_MYartists copy];
        mmvc.upvotes = [_MYupvotes copy];
        mmvc.downvotes = [_MYdownvotes copy];
    }
}

@end
