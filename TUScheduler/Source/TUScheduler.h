//
//  TUScheduler.h
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

/**
 @abstract Convenience typedef to describe jobs that can be scheduled.
 */
typedef void(^TUSchedulerJob)(void);


/**
 @protocol TUScheduler

 @abstract Abstract API for scheduling async jobs.
 
 @discussion
    Schedulers provide an abstract API to submits jobs that must be executed, usually in background. The idea
 	is to hide the underlying concurrency API (GDC, NSOperationQueues, etc.), and to be able to plug fully synchronous
 	schedulers when needed (i.e. in tests).
 	Each scheduler has a unique name. This is useful for identifying the scheduler during debugging. If you don't
 	provide a name on initialization, a unique name will be generated for you.
 */

@protocol TUScheduler <NSObject>

/**
 @abstract Used to identify the scheduler. Must be unique. Usefull for debugging.
 */
@property (nonatomic, readonly) NSString *name;


/**
 @abstract Schedules a job for asynchronous executing.
 @parameter job. The job to be scheduled. The result of passing nil/NULL in this parameter is undefined.
 */
- (void)scheduleAsync:(TUSchedulerJob)job;


/**
 @abstract Schedules a job to be executed synchrounously.
 @parameter job. The job to be scheduled. The result of passing nil/NULL in this parameter is undefined.
 */
- (void)scheduleSync:(TUSchedulerJob)job;

@end
