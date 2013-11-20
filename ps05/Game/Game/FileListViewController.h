/*
This class implements the Load/Delete popup displayed as a popover when the load
 button is tapped. It has a table view to display the list of files in Document 
 directory, and notifies the parent view controller when a selection is made
 */

#import <UIKit/UIKit.h>

//protocol - to notify when a selection is made in the load/delete popup
@protocol TableSelectorDelegate <NSObject>
@optional
- (void)didMakeSelection:(id)selectionString withAction:(NSString*)action;
@end

@interface FileListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property NSArray *allFiles;
//this table view is programatically defined
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<TableSelectorDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIToolbar *actionToolbar;

- (IBAction)loadButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;

- (void)setFiles:(NSArray*)files;
@end
