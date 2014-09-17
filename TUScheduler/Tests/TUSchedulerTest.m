//
//  TUSchedulerTest.m
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

#import "TUSchedulerTest.h"

#import "TUAsyncTestSentinel.h"

NSString *const kSerialSchedulerName = @"com.tuenti.SerialScheduler.Test";
NSString *const kConcurrentSchedulerName = @"com.tuenti.ConcurrentScheduler.Test";
NSString *const kQueueName = @"com.tuenti.aQueue.name";

NSTimeInterval const timeOut = 2.0f; // 2 seconds timeout should be more than enough...

@implementation TUSchedulerTest

#pragma mark - Scheduler Creation Tests

- (void)testCanCreateSerialScheduler
{
	// when
	self.sut = self.serialScheduler;
    
	// then
	assertThat(self.sut, is(notNilValue()));
	assertThat(self.sut, hasProperty(@"name", kSerialSchedulerName));
}

- (void)testCanCreateConcurrentScheduler
{
	// when
	self.sut = self.concurrentScheduler;
    
	// then
	assertThat(self.sut, is(notNilValue()));
	assertThat(self.sut, hasProperty(@"name", kConcurrentSchedulerName));
}

#pragma mark - Sanity Tests

- (void)testScheduler_scheduleSyncNilJob_throwsException
{
	// given
	self.sut = self.serialScheduler;
	BOOL throwsException = NO;
    
	// when
	@try {
		[self.sut scheduleSync:nil];
	}
	@catch (NSException *exception) {
		throwsException = YES;
	}
    
	// then
	assertThatBool(throwsException, is(equalToBool(YES)));
}

- (void)testScheduler_scheduleAsyncNilJob_throwsException
{
	// given
	self.sut = self.serialScheduler;
	BOOL throwsException = NO;
    
	// when
	@try {
		[self.sut scheduleAsync:nil];
	}
	@catch (NSException *exception) {
		throwsException = YES;
	}
    
	// then
	assertThatBool(throwsException, is(equalToBool(YES)));
}

#pragma mark - Synchronous Scheduling Tests

- (void)testScheduler_scheduleSync_executesJobImmediately
{
	// given
	self.sut = self.serialScheduler;
	__block BOOL jobWasExecuted = NO;
    
	// when
	[self.sut scheduleSync:^{
		jobWasExecuted = YES;
	}];
    
	// then
	assertThatBool(jobWasExecuted, is(equalToBool(YES)));
}

#pragma mark - Asynchronous Scheduling Tests

- (void)testScheduler_scheduleAsync_doesNotExecuteJobSynchronously
{
	// given
	self.sut = self.serialScheduler;
	__block BOOL timedOut = NO;
	TUAsyncTestSentinel *sentinel = [[TUAsyncTestSentinel alloc] init];
    
	// when
	[self.sut scheduleAsync:^{
		// If scheduled synchronously, this will time out
		[sentinel waitForConditionWithTimeOut:timeOut successBlock:nil timeOutBlock:^{
			timedOut = YES;
		}];
	}];
	[sentinel fulfillCondition];
    
	// then
	assertThatBool(timedOut, is(equalToBool(NO)));
}

- (void)testScheduler_scheduleAsync_executesJobBeforeTimeOut
{
	// given
	self.sut = self.serialScheduler;
	TUAsyncTestSentinel *sentinel = [[TUAsyncTestSentinel alloc] init];
    
	// when
	[self.sut scheduleAsync:^{
		[sentinel fulfillCondition];
	}];
	[sentinel waitForConditionWithTimeOut:timeOut];
    
	// then
	assertThatBool(sentinel.condition, is(equalToBool(YES)));
}


#pragma mark - Thread Targeting Tests

- (void)testSerialScheduler_scheduleAsync_jobsExecuteInBackgroundThread
{
	// given
	self.sut = self.serialScheduler;
	__block BOOL inMainThread = YES;
	TUAsyncTestSentinel *sentinel = [[TUAsyncTestSentinel alloc] init];
    
	// when
	[self.sut scheduleAsync:^{
		inMainThread = [NSThread isMainThread];
		[sentinel fulfillCondition];
	}];
	[sentinel waitForConditionWithTimeOut:timeOut];
    
	// then
	assertThatBool(sentinel.condition, is(equalToBool(YES)));
	assertThatBool(inMainThread, is(equalToBool(NO)));
}

- (void)testConcurrentScheduler_scheduleAsync_jobsExecuteInBackgroundThread
{
	// given
	self.sut = self.concurrentScheduler;
	__block BOOL inMainThread = YES;
	TUAsyncTestSentinel *sentinel = [[TUAsyncTestSentinel alloc] init];
    
	// when
	[self.sut scheduleAsync:^{
		inMainThread = [NSThread isMainThread];
		[sentinel fulfillCondition];
	}];
	[sentinel waitForConditionWithTimeOut:timeOut];
    
	// then
	assertThatBool(sentinel.condition, is(equalToBool(YES)));
	assertThatBool(inMainThread, is(equalToBool(NO)));
}

- (void)testMainThreadScheduler_scheduleAsync_jobsExecuteInMainThread
{
	// given
	self.sut = self.mainThreadScheduler;
	__block BOOL inMainThread = NO;
    
	TUAsyncTestSentinel *sentinel = [[TUAsyncTestSentinel alloc] init];
    
	// when
	[self.sut scheduleAsync:^{
		inMainThread = [NSThread isMainThread];
		[sentinel fulfillCondition];
	}];
    
	[sentinel waitForConditionWithTimeOut:timeOut];
    
	// then
	assertThatBool(sentinel.condition, is(equalToBool(YES)));
	assertThatBool(inMainThread, is(equalToBool(YES)));
}

#pragma mark - All Jobs Completion Tests

- (void)testScheduler_scheduleSeveralJobs_allJobsAreExecuted
{
	// given
	self.sut = self.serialScheduler;
    
	// when
	TUAsyncTestSentinel *sentinel1 = [[TUAsyncTestSentinel alloc] init];
	TUAsyncTestSentinel *sentinel2 = [[TUAsyncTestSentinel alloc] init];
    
	[self.sut scheduleAsync:^{
		[sentinel1 fulfillCondition];
	}];
	[self.sut scheduleAsync:^{
		[sentinel2 fulfillCondition];
	}];
    
	[sentinel1 waitForConditionWithTimeOut:timeOut];
	[sentinel2 waitForConditionWithTimeOut:timeOut];
    
	// then
	assertThatBool(sentinel1.condition, is(equalToBool(YES)));
	assertThatBool(sentinel2.condition, is(equalToBool(YES)));
}

@end
