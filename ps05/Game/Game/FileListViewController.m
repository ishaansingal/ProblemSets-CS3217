//
//  FileListViewController.m
//  Game
//
//  Created by Ishaan Singal on 1/3/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "FileListViewController.h"

@interface FileListViewController ()
@property NSString *selectedFile;
@end

@implementation FileListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //initialize a custom tableview to display all the list of files saved on the screen
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

//sets its property self.allfiles and sets the correct size of the table
- (void)setFiles:(NSArray*)files {
    self.allFiles = files;
  CGFloat numOfFiles = [self.allFiles count];
    int cellHeight = 42;
    CGFloat tableHeight = numOfFiles * cellHeight;
    //set the size of the tableview based on the number of cells in it
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, tableHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.allFiles count] == 0) {
        self.actionToolbar.hidden = YES;
    }
    else {
        self.actionToolbar.hidden = NO;
        
    }
    return [self.allFiles count];
}

//the data source, where the row value is set accordingly
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    cell.textLabel.text = [self.allFiles objectAtIndex:indexPath.row];
    
    
    return cell;
}

//the delegate to set its property of selected value to the correct value
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFile = [self.allFiles objectAtIndex:indexPath.row];
}

//if the load button is pressed, send the deletate to the parent view controller
- (IBAction)loadButtonPressed:(id)sender {
    if (self.selectedFile != nil) {
        [self.delegate didMakeSelection:self.selectedFile withAction:@"Load"];
    }
}

//if the delete button is pressed, send the deletate to the parent view controller
- (IBAction)deleteButtonPressed:(id)sender {
    if (self.selectedFile != nil) {
        [self.delegate didMakeSelection:self.selectedFile withAction:@"Delete"];
    }
}

//if the cancel button is pressed, send the deletate to the parent view controller
- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate didMakeSelection:self.selectedFile withAction:@"Cancel"];
}




- (void)viewDidUnload {
    [self setTableView:nil];
    [self setActionToolbar:nil];
    [super viewDidUnload];
}
@end
