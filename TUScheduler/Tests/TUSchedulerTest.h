//
//  TUSchedulerTest.h
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

#import <Foundation/Foundation.h>

#import "TUScheduler.h"

extern NSString *const kSerialSchedulerName;
extern NSString *const kConcurrentSchedulerName;
extern NSString *const kQueueName;

extern NSTimeInterval const timeOut;

/**
 @class TUSchedulerTest
 @abstract Base class for concrete TUScheduler tests
 @discussion
    Most of the tests of the concrete implementations of TUSchedulers are exactly the same except for the setUp method.
    This base class implements all the classes testing the APIContract. Tests for GCD and NSOperationQueue schedulers
    inherit from this class and just need to implement the setUp method and any other test which is specific to the 
    implementation (you shouldn't have many of these).
 */

@interface TUSchedulerTest : XCTestCase

// The Subject Under Test, i.e. the scheduler we are testing.
@property (nonatomic) id<TUScheduler> sut;

// These schedulers will be provided by subclasses of this suite:
@property (nonatomic) id<TUScheduler> serialScheduler;
@property (nonatomic) id<TUScheduler> concurrentScheduler;
@property (nonatomic) id<TUScheduler> mainThreadScheduler;

@end
