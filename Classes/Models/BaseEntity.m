//
//  BaseEntity.m
//  Senbei
//
//  Created by Adrian on 1/20/10.
//  Copyright (c) 2010, akosma software / Adrian Kosmaczewski
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by akosma software.
//  4. Neither the name of the akosma software nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY ADRIAN KOSMACZEWSKI ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ADRIAN KOSMACZEWSKI BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "BaseEntity.h"
#import "GTMNSString+HTML.h"

@implementation BaseEntity

@synthesize name = _name;
@synthesize objectId = _objectId;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;
@synthesize formatter = _formatter;
@synthesize photoURL = _photoURL;

@dynamic commentableTypeName;

#pragma mark -
#pragma mark Class methods

+ (NSString *)stringValueForElement:(NSString *)elementName 
                      parentElement:(TBXMLElement *)element
{
    TBXMLElement *attribute = [TBXML childElementNamed:elementName parentElement:element];
    NSString *value = @"";
    if (attribute != nil)
    {
        value = [[TBXML textForElement:attribute] gtm_stringByUnescapingFromHTML];
    }
    return value;
}

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithTBXMLElement:(TBXMLElement *)element
{
    if (self = [super init])
    {
        self.formatter = [[[NSDateFormatter alloc] init] autorelease];
        [self.formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

        NSString *value = [BaseEntity stringValueForElement:@"id" parentElement:element];
        self.objectId = [value intValue];

        value = [BaseEntity stringValueForElement:@"created-at" parentElement:element];
        self.createdAt = [self.formatter dateFromString:value];

        value = [BaseEntity stringValueForElement:@"updated-at" parentElement:element];
        self.updatedAt = [self.formatter dateFromString:value];

        self.name = [BaseEntity stringValueForElement:@"name" parentElement:element];
    }
    return self;
}

- (void)dealloc
{
    self.formatter = nil;
    self.createdAt = nil;
    self.updatedAt = nil;
    self.name = nil;
    self.photoURL = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Overridable properties

- (NSString *)commentableTypeName
{
    return NSStringFromClass([self class]);
}

@end
