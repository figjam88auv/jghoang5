//
//  FontFile.h
//  PDFTableTest
//
//  Created by eileen on 14/5/14.
//  Copyright (c) 2014 eileen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontFile : NSObject {
    @private
        NSData* data;
        size_t asciiTextLength;
        NSMutableDictionary* nameMap;
}

@property(nonatomic, strong) NSString* text;

+ (unichar)characterByName:(NSString*)name;
- (id)initWithContentOfURL:(NSURL*)url;
- (id)initWithData:(NSData*)__data;
- (NSString*)stringWithCode:(NSInteger)code;

@end
