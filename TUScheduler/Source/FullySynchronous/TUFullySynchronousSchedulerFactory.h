//
//  TUFullySynchronousSchedulerFactory.h
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
#import "TUSchedulerFactory.h"

/**
 @abstract Factory for Fully Synchronous Schedulers
 @discussion
	This factory is meant to be used in tests. During Unit Testing we don't want to have any async behaviors, semaphores, 
    sleeps, or timeouts. Injecting this factory to SUT means that all the scheduling will be done fully synchronously, 
    so tests can focus on testing the business logic without having to care about the asynchronous behavior.
 */

@interface TUFullySynchronousSchedulerFactory : NSObject <TUSchedulerFactory>

@end
