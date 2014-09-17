//
//  TUSchedulerFactory.h
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
 @protocol TUSchedulerFactory
 
 @abstract
 	Abstract factory for creating Schedulers of different families
 
 @discussion
 	Concrete factories conforming to this protocol can produce valid instances of TUSchedulers. Each concrete
 	implementation of this abstract factory produces shcedulers of a different family (GCD, NSOperationQueue,
 	FullySynchrounous, etc.).
 	The tipical use of schedulers involves injecting a scheduler factory into a class, so the class can create its
 	schedulers on demand.
 */

@protocol TUSchedulerFactory <NSObject>

/**
 @abstract Returns an instance of a serial scheduler with the given unique name.
 @discussion This method returns an instance of a serial scheduler.
 @parameter name. The name of the scheduler. Must be unique.
 */
- (id<TUScheduler>)serialSchedulerWithName:(NSString *)name;

/**
 @abstract
 	Returns an instance of a concurrent scheduler with the given unique name and a default number of max concurrent jobs.
 @discussion
 	This method returns an instance of a concurrent scheduler with a given name. Tha max number of concurrent operations
 	that can be executed at the same time is set to a default value. This value would be automatically calculated by the
 	OS depending on the available resources and the system load.
 @parameter name. The name of the scheduler. Must be unique.
 */
- (id<TUScheduler>)concurrentSchedulerWithName:(NSString *)name;

/**
 @abstract Returns an instance of a scheduler for the main thread.
 @discussion
 	This method returns an instance of a scheduler that executes jobs in the main thread. This is an special case: the
 	only one in which the target thread of a scheduler is know for users of the scheduler.
 */
- (id<TUScheduler>)mainThreadScheduler;

@end
