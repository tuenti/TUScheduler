//
//  TUSerialSchedulerTest.m
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

    // Class under test
#import "TUGCDScheduler.h"

#import "TUSchedulerTest.h"

#define gcdSerialScheduler	 [TUGCDScheduler serialSchedulerWithName:kSerialSchedulerName]
#define gcdConcurrentScheduler [TUGCDScheduler concurrentSchedulerWithName:kConcurrentSchedulerName]
#define gcdMainThreadScheduler [[TUGCDScheduler alloc] initWithDispatchQueue:dispatch_get_main_queue()]

@interface TUGCDSchedulerTest : TUSchedulerTest
@end

@implementation TUGCDSchedulerTest

- (void)setUp
{
	[super setUp];
	self.serialScheduler     = gcdSerialScheduler;
    self.concurrentScheduler = gcdConcurrentScheduler;
    self.mainThreadScheduler = gcdMainThreadScheduler;
}

- (void)testCanCreateSchedulerWithCustomQueue
{
	// given
	NSString *aName = kQueueName;
	dispatch_queue_t aQueue = dispatch_queue_create(aName.UTF8String, DISPATCH_QUEUE_SERIAL);

	// when
	self.sut = [[TUGCDScheduler alloc] initWithDispatchQueue:aQueue];

	// then
	assertThat(self.sut, is(notNilValue()));
	assertThat(self.sut, hasProperty(@"name", kQueueName));
}

@end
