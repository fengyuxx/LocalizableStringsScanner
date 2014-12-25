//
//  FileScanner.m
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

#import "FileScanner.h"


@implementation FileScanner

- (void)enumeratorAtPath:(NSString *)path fileFinder:(void(^)(NSURL *url, BOOL *stop))finder{
    NSArray *keys = @[FileScannerNameKey,
                      FileScannerPathKey,
                      FileScannerIsDirKey,];
    
    NSDirectoryEnumerator *en = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL *url, NSError *error) {
        NSLog(@"enumerator error\n%@\nat:%@", error, url);
        exit(0);
        return NO;
    }];
    
    NSURL *subpath;
    BOOL isDir;
    BOOL stop = NO;
    while(subpath = [en nextObject]){
        [[NSFileManager defaultManager] fileExistsAtPath:[subpath path] isDirectory:&isDir];
        if(isDir){
            [self enumeratorAtPath:[subpath path] fileFinder:finder];
        }else{
            if(finder) finder(subpath, &stop);
        }
        if(stop) break;
    }
}

@end
