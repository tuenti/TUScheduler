//
//  TUOperationQueueSchedulerTest.m
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
#import "TUOperationQueueScheduler.h"

#import "TUSchedulerTest.h"

#define opQueueSerialScheduler	 [[TUOperationQueueScheduler alloc] initWithMaxConcurrentOperationCount:1 name:kSerialSchedulerName]
#define opQueueConcurrentScheduler [[TUOperationQueueScheduler alloc] initWithName:kConcurrentSchedulerName]
#define opQueueMainThreadScheduler [[TUOperationQueueScheduler alloc] initWithOperationQueue:[NSOperationQueue mainQueue]]

@interface TUOperationQueueSchedulerTest : TUSchedulerTest
@end

@implementation TUOperationQueueSchedulerTest

- (void)setUp
{
	[super setUp];
	self.serialScheduler     = opQueueSerialScheduler;
    self.concurrentScheduler = opQueueConcurrentScheduler;
    self.mainThreadScheduler = opQueueMainThreadScheduler;
}

- (void)testCanCreateSchedulerWithCustomQueue
{
	// given
	NSOperationQueue *aQueue = [[NSOperationQueue alloc] init];
	[aQueue setName:kQueueName];

	// when
	self.sut = [[TUOperationQueueScheduler alloc] initWithOperationQueue:aQueue];

	// then
	assertThat(self.sut, is(notNilValue()));
	assertThat(self.sut, hasProperty(@"name", kQueueName));
}

@end
