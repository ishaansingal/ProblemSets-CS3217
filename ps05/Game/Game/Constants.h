/*
 A constants file used to prevent magic numbers and strings
 These values are used regularly and have been defined as static constants
 */

#import <Foundation/Foundation.h>
FOUNDATION_EXPORT NSString *const kBackgroundImageName;
FOUNDATION_EXPORT NSString *const kGroundImageName;

FOUNDATION_EXPORT NSString *const kBreathImageName;
FOUNDATION_EXPORT NSString *const kBreathExpiredImagesName;
FOUNDATION_EXPORT NSString *const kWolfBlowImagesName;
FOUNDATION_EXPORT NSString *const kWolfSuckImagesName;
FOUNDATION_EXPORT NSString *const kWolfDieImagesName;
FOUNDATION_EXPORT NSString *const kWolfDeadImageName;

FOUNDATION_EXPORT NSString *const kArrowImageName;
FOUNDATION_EXPORT NSString *const kRedArrowImageName;
FOUNDATION_EXPORT NSString *const kBreathBarImageName;
FOUNDATION_EXPORT NSString *const kWolfImageName;
FOUNDATION_EXPORT NSString *const kWoodImageName;
FOUNDATION_EXPORT NSString *const kIronImageName;
FOUNDATION_EXPORT NSString *const kStrawImageName;
FOUNDATION_EXPORT NSString *const kStoneImageName;
FOUNDATION_EXPORT NSString *const kPigImageName;
FOUNDATION_EXPORT NSString *const kPigCryImageName;
FOUNDATION_EXPORT NSString *const kPigDiedSmokeImagesName;

FOUNDATION_EXPORT NSString *const kHeartImageName;
FOUNDATION_EXPORT NSString *const kScoreImageName;
FOUNDATION_EXPORT NSString *const kFontImageName;
FOUNDATION_EXPORT NSString *const kNumFontImageName;

FOUNDATION_EXPORT double const kViewHeight;
FOUNDATION_EXPORT double const kViewWidth;

FOUNDATION_EXPORT double const kGameareaHeight;
FOUNDATION_EXPORT double const kGameareaWidth;
FOUNDATION_EXPORT double const kGroundHeight;
FOUNDATION_EXPORT double const kGroundWidth;

FOUNDATION_EXPORT double const kBackGroundHeight;
FOUNDATION_EXPORT double const kBackGroundWidth;

FOUNDATION_EXPORT double const kDefaultPigWidth;
FOUNDATION_EXPORT double const kDefaultPigHeight;

FOUNDATION_EXPORT double const kDefaultWolfWidth;
FOUNDATION_EXPORT double const kDefaultWolfHeight;

FOUNDATION_EXPORT double const kDefaultBlockWidth;
FOUNDATION_EXPORT double const kDefaultBlockHeight;

FOUNDATION_EXPORT double const kDefaultArrowWidth;
FOUNDATION_EXPORT double const kDefaultArrowHeight;

FOUNDATION_EXPORT double const kDefaultBreathBarWidth;
FOUNDATION_EXPORT double const kDefaultBreathBarHeight;

FOUNDATION_EXPORT double const kPaletteHeight;
FOUNDATION_EXPORT double const kPaletteWidth;

FOUNDATION_EXPORT double const kPalettePigOriginX;
FOUNDATION_EXPORT double const kPalettePigOriginY;
FOUNDATION_EXPORT double const kPalettePigWidth;
FOUNDATION_EXPORT double const kPalettePigHeight;

FOUNDATION_EXPORT double const kPaletteWolfOriginX;
FOUNDATION_EXPORT double const kPaletteWolfOriginY;
FOUNDATION_EXPORT double const kPaletteWolfWidth;
FOUNDATION_EXPORT double const kPaletteWolfHeight;

FOUNDATION_EXPORT double const kPaletteBlockHeight;
FOUNDATION_EXPORT double const kPaletteBlockWidth;
FOUNDATION_EXPORT double const kPaletteBlockOriginX;
FOUNDATION_EXPORT double const kPaletteBlockOriginY;

FOUNDATION_EXPORT double const kBreathRadius;

FOUNDATION_EXPORT double const kScaleMax;
FOUNDATION_EXPORT double const kScaleMin;

FOUNDATION_EXPORT int const kPowerMultiplier;
FOUNDATION_EXPORT double const kPixelToMeterRatio;
FOUNDATION_EXPORT double const kTimeStep;

FOUNDATION_EXPORT int const kFontStartIndex;
FOUNDATION_EXPORT int const kFontEndIndex;
FOUNDATION_EXPORT int const kFontNumStartIndex;
FOUNDATION_EXPORT int const kFontNumEndIndex;

FOUNDATION_EXPORT int const kPigMaxHealth;
FOUNDATION_EXPORT int const kPigCryHealth;

FOUNDATION_EXPORT int const kStrawMaxHealth;
FOUNDATION_EXPORT int const kWoodMaxHealth;
FOUNDATION_EXPORT int const kStoneMaxHealth;
FOUNDATION_EXPORT int const kIronMaxHealth;

typedef enum {kInPalette, kInGame} GameObjectState;
typedef enum {kStraw = 1, kWood = 2, kStone = 3, kIron = 4} BlockType;
typedef enum {kGameObjectWolf, kGameObjectPig, kGameObjectBlock} GameObjectType;
typedef enum {kRect, kCircle} ShapeType;
typedef enum {kPlayMode, kDesignerMode} GameMode;