//
//  CIDType2Font.h
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import "CompositeFont.h"

@interface CIDType2Font : CompositeFont {
    @private
        NSData* cidGidMap;
}

@property(nonatomic, assign) BOOL isIdentity;

@end
