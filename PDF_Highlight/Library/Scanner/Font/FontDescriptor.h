//
//  FontDescriptor.h
//  PDFTableTest
//
//  Created by eileen on 13/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class FontFile;

typedef enum FontFlags
{
	FontFixedPitch		= 1 << 0,
	FontSerif			= 1 << 1,
	FontSymbolic		= 1 << 2,
	FontScript			= 1 << 3,
	FontNonSymbolic		= 1 << 5,
	FontItalic			= 1 << 6,
	FontAllCap			= 1 << 16,
	FontSmallCap		= 1 << 17,
	FontForceBold		= 1 << 18,
} FontFlags;

@interface FontDescriptor : NSObject

@property(nonatomic, assign) CGRect bounds;
@property(nonatomic, assign) CGFloat ascent;
@property(nonatomic, assign) CGFloat descent;
@property(nonatomic, assign) CGFloat leading;
@property(nonatomic, assign) CGFloat capHeight;
@property(nonatomic, assign) CGFloat xHeight;
@property(nonatomic, assign) CGFloat averageWidth;
@property(nonatomic, assign) CGFloat maxWidth;
@property(nonatomic, assign) CGFloat missingWidth;
@property(nonatomic, assign) CGFloat verticalStemWidth;
@property(nonatomic, assign) CGFloat horizontalStemWidth;
@property(nonatomic, assign) CGFloat italicAngle;
@property(nonatomic, assign) NSUInteger flags;
@property(nonatomic, copy) NSString *fontName;
@property(nonatomic, strong) FontFile* fontFile;

/* Initialize a descriptor using a FontDescriptor dictionary */
- (id)initWithPDFDictionary:(CGPDFDictionaryRef)dict;

/* True if a font is symbolic */
- (BOOL)isSymbolic;

@end
