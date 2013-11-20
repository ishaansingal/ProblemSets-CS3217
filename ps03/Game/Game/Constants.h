/*
 A constants file used to prevent magic numbers and strings
 These values are used regularly and have been defined as static constants
 */

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kWolfImageName;
FOUNDATION_EXPORT NSString *const kWoodImageName;
FOUNDATION_EXPORT NSString *const kIronImageName;
FOUNDATION_EXPORT NSString *const kStrawImageName;
FOUNDATION_EXPORT NSString *const kStoneImageName;
FOUNDATION_EXPORT NSString *const kPigImageName;

FOUNDATION_EXPORT double const kDefaultPigWidth;
FOUNDATION_EXPORT double const kDefaultPigHeight;

FOUNDATION_EXPORT double const kDefaultWolfWidth;
FOUNDATION_EXPORT double const kDefaultWolfHeight;

FOUNDATION_EXPORT double const kDefaultBlockWidth;
FOUNDATION_EXPORT double const kDefaultBlockHeight;

FOUNDATION_EXPORT double const kPalettePigWidth;
FOUNDATION_EXPORT double const kPalettePigHeight;

FOUNDATION_EXPORT double const kPaletteWolfWidth;
FOUNDATION_EXPORT double const kPaletteWolfHeight;

FOUNDATION_EXPORT double const kPaletteBlockHeight;
FOUNDATION_EXPORT double const kPaletteBlockWidth;

FOUNDATION_EXPORT double const kPalettePigOriginX;
FOUNDATION_EXPORT double const kPalettePigOriginY;

FOUNDATION_EXPORT double const kPaletteWolfOriginX;
FOUNDATION_EXPORT double const kPaletteWolfOriginY;

FOUNDATION_EXPORT double const kPaletteBlockOriginX;
FOUNDATION_EXPORT double const kPaletteBlockOriginY;

FOUNDATION_EXPORT double const kScaleMax;
FOUNDATION_EXPORT double const kScaleMin;

typedef enum {kInPalette, kInGame} GameObjectState;
typedef enum {kStraw = 1, kWood = 2, kStone = 3, kIron = 4} BlockType;
typedef enum {kGameObjectWolf, kGameObjectPig, kGameObjectBlock} GameObjectType;
