//
//  TUSerialScheduler.m
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

#import "TUGCDScheduler.h"

@interface TUGCDScheduler ()

@property (nonatomic) dispatch_queue_t internalQueue;

@end

@implementation TUGCDScheduler

@synthesize name = _name;

+ (instancetype)serialSchedulerWithName:(NSString *)name
{
	dispatch_queue_t dispatchQueue = dispatch_queue_create(name.UTF8String, DISPATCH_QUEUE_SERIAL);
	return [[self alloc] initWithDispatchQueue:dispatchQueue];
}

+ (instancetype)concurrentSchedulerWithName:(NSString *)name
{
	dispatch_queue_t dispatchQueue = dispatch_queue_create(name.UTF8String, DISPATCH_QUEUE_CONCURRENT);
	return [[self alloc] initWithDispatchQueue:dispatchQueue];
}

- (instancetype)initWithDispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self = [super init];
    if (self)
	{
		_internalQueue = dispatchQueue;
		const char *queueLabel = dispatch_queue_get_label(_internalQueue);
		_name = [NSString stringWithUTF8String:queueLabel];
    }
    return self;
}

- (void)scheduleAsync:(TUSchedulerJob)job
{
	NSParameterAssert(job != nil);
	dispatch_async(self.internalQueue, job);
}

- (void)scheduleSync:(TUSchedulerJob)job
{
	NSParameterAssert(job != nil);
	dispatch_sync(self.internalQueue, job);
}

@end
