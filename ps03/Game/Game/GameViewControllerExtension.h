/*
 The extension of GameViewController that implements the save, load and reset
 Since it has access to the properties of the super class, it modifies it as
 the buttons are pressed and allocates new values.
 It also updates the uiview accordingly
 */

#import "GameViewController.h"

@interface GameViewController (GameViewControllerExtension)
- (IBAction)buttonPressed:(id)sender;

- (void)save;
// REQUIRES: game in designer mode
// EFFECTS: game objects are saved

- (void)load;
// MODIFIES: self (game objects)
// REQUIRES: game in designer mode
// EFFECTS: game objects are loaded

- (void)reset;
// MODIFIES: self (game objects)
// REQUIRES: game in designer mode
// EFFECTS: current game objects are deleted and palette contains all objects

@end
