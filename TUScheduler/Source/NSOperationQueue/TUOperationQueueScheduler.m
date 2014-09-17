//
//  TUOperationQueueScheduler.m
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

#import "TUOperationQueueScheduler.h"

@interface TUOperationQueueScheduler ()

@property (strong, nonatomic) NSOperationQueue *internalQueue;

@end

@implementation TUOperationQueueScheduler

@synthesize name = _name;

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue
{
    self = [super init];
    if (self)
	{
		_internalQueue = operationQueue;
		_name = _internalQueue.name;
    }
    return self;
}

- (instancetype)initWithMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
											   name:(NSString *)name;
{
	NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:maxConcurrentOperationCount];
	[operationQueue setName:name];

	return [self initWithOperationQueue:operationQueue];
}

- (instancetype)initWithName:(NSString *)name;
{
	return [self initWithMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount
												name:name];
}

- (void)scheduleAsync:(TUSchedulerJob)job
{
	NSParameterAssert(job != nil);
	[self.internalQueue addOperationWithBlock:job];
}

- (void)scheduleSync:(TUSchedulerJob)job
{
	NSParameterAssert(job != nil);
	NSBlockOperation *jobWrapper = [NSBlockOperation blockOperationWithBlock:job];
	[self.internalQueue addOperations:@[jobWrapper] waitUntilFinished:YES];
}

@end
