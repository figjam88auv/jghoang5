//
//  Type0Font.h
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "CompositeFont.h"

@interface Type0Font : CompositeFont {
    @private
        NSMutableArray* descendantFonts;
}

@end
