//
//  FontCollection.h
//  PDFTableTest
//
//  Created by eileen on 13/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class Font;

@interface FontCollection : NSObject {
    @private
        NSMutableDictionary* fontMap;
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Return the specified font */
- (Font*)getFontByName:(NSString*)name;

@end
