//
//  TUAsyncTestSentinel.m
//
//  Copyright (c) 2014 Tuenti Technologies S.L. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "TUAsyncTestSentinel.h"

#include <libkern/OSAtomic.h>

@implementation TUAsyncTestSentinel

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		_condition = NO;
    }
    return self;
}

- (void)fulfillCondition
{
	_condition = YES;
}

- (void)resetCondition
{
	_condition = NO;
}

- (void)waitForConditionWithTimeOut:(NSTimeInterval)timeout
{
	[self waitForConditionWithTimeOut:timeout
						 successBlock:nil
						 timeOutBlock:nil];
}

- (void)waitForConditionWithTimeOut:(NSTimeInterval)timeout
					   successBlock:(void(^)(void))successBlock
					   timeOutBlock:(void(^)(void))timeoutBlock
{
	NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
	while(!_condition && ([(NSDate *)[NSDate date] compare:expiryDate] != NSOrderedDescending))
	{
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
		OSMemoryBarrier();
	}

	if (_condition && successBlock != nil)
	{
		successBlock();
	}
	else if (!_condition && timeoutBlock != nil)
	{
		timeoutBlock();
	}
}

@end
