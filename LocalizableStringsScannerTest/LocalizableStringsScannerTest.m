//
//  LocalizableScannerTest.m
//  LocalizableScan
//
//  Copyright (c) 2014 Elvin Gao
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  1. The above copyright notice and this permission notice shall be included
//     in all copies or substantial portions of the Software.
//
//  2. This Software cannot be used to archive or collect data such as (but not
//     limited to) that of events, news, experiences and activities, for the
//     purpose of any concept relating to diary/journal keeping.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "LocalizableScanner.h"
#import <RegexKitLite/RegexKitLite.h>

@interface LocalizableScannerTest : XCTestCase

@end

@implementation LocalizableScannerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegex{
    NSString *regex = @"NSLocalizedString\\(@(\".*?\"),";
    NSString *string = @"NSLocalizedString(@\"AA_bbb\", nil);NSLocalizedString(@\"AA_bccc\", nil);";
    [string enumerateStringsMatchedByRegex:regex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        for(NSInteger i=1; i < captureCount; i++){
            NSString *string = capturedStrings[i];
            NSLog(@"%@", string);
        }
    }];
}

- (void)testScanner{
    NSString *path = @"";
    NSString *localizableFile = @"";
    [[LocalizableScanner scanner] scanPath:path withLocalizableFile:localizableFile];
}



@end
