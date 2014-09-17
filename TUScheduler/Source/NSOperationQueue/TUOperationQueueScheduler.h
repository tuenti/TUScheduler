//
//  TUOperationQueueScheduler.h
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

/**
 @class TUOperationQueueScheduler
 @abstract Scheduler based on NSOperationQueues.
 @discussion 
    This scheduler uses NSOperationQueue API to schedule jobs. Each TUOperationQueueScheduler maintains its own internal
    operation queue.
 */
@interface TUOperationQueueScheduler : NSObject <TUScheduler>

/**
 @abstract Designated initializer of TUOperationQueueScheduler
 */
- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

/**
 @abstract Initializer of TUOperationQueueScheduler providing a maxConcurrentOperationCount and a name for the
 scheduler.
 */
- (instancetype)initWithMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
											   name:(NSString *)name;

/**
 @abstract Uses the default value for maxConcurrentOperationCount recommended by Apple:
 (NSOperationQueueDefaultMaxConcurrentOperationCount).
 */
- (instancetype)initWithName:(NSString *)name;

@end
