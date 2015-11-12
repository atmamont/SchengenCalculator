//
//  mainVisaCalc.m
//  SchengenVisaCalc
//
//  Created by atMamont on 22.04.15.
//  Copyright (c) 2015 Andrey Mamchenko. All rights reserved.
//

#import "MainVisaCalc.h"

// private interface
@interface MainVisaCalc()


@end


@implementation MainVisaCalc

const int DAYS_WINDOW = 180;
const int MAX_DAYS = 90;

// getter
- (NSDate *)entryDate
{
    if (!_entryDate) {
        _entryDate = [[NSDate alloc] init];
    }
    
    return _entryDate;
    
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableArray *) trips // getter with lazy init
{
    if (!_trips) _trips = [[NSMutableArray alloc] init];
    return _trips;
}

- (void) addTrip: (NSDate *) startDate and: (NSDate*) endDate named:(NSString *)name
{

    Trip *newTrip = [[Trip alloc]init];
    newTrip.startDate = startDate;
    newTrip.endDate = endDate;
    newTrip.name = name;
    
    //[self.trips addObject:(newTrip)];
    // trying to find correct place to insert new trip
    NSUInteger newIndex = -1;
    for (Trip *trip in self.trips){
        if ([trip.startDate compare:newTrip.startDate] == NSOrderedAscending)
        {
            // assuming array always sorted by startDate
            newIndex = [self.trips indexOfObject:trip];
            break;
        }
    }
    if (newIndex != -1)
        [self.trips insertObject:newTrip atIndex:newIndex];
    else
        [self.trips addObject:(newTrip)];
    
    
}

// MAIN LOGIC HERE
/*
- (NSInteger) getTotalRemainingDays{
    
    // step 1. count remaining days in 90 day interval for the moment of entry
    // step 2. count remaining days in loop while extending 180 days window with remaining days count
    
    NSTimeInterval interval90 = MAX_DAYS * 60 * 60 * 24;
    NSTimeInterval interval180 = DAYS_WINDOW * 60 * 60 * 24;
    
    NSDate* startDate90 = [[NSDate alloc] initWithTimeInterval:-interval90
                                                     sinceDate:self.entryDate];
    
    NSDate* endDate90 = self.entryDate; //  was NOW earlier
    
    NSDate* earliestDate = nil;

    NSInteger daysCounted = 0;
    for (Trip *trip in self.trips)
    {
        NSInteger daysCount90_ = [trip getTripDurationBetweenDates:startDate90 and:endDate90];
        daysCounted += daysCount90_;
        
        if (!daysCount90_) continue; // trip is out of 90 day interval
        if (!earliestDate) {
            earliestDate = startDate90;
        }
            else if ([[earliestDate earlierDate:startDate90] isEqualToDate:earliestDate])
            {
                earliestDate = startDate90;
            }
    }
    
    if (!daysCounted) return 90;
    
    NSLog(@"Used days in 90-day period: %ld", daysCounted);
    NSLog(@"First trip date: %@", earliestDate);
    
    NSInteger daysAvailableLoop = daysCounted;
    NSInteger daysAvailablePrevious = 0;
    
    while (YES) {
        // end date - adding daysCounted days to planned entry date
        NSTimeInterval daysCountedSeconds = daysAvailableLoop * 60 * 60 * 24;
        NSDate* endDate180 = [[NSDate alloc] initWithTimeInterval:daysCountedSeconds
                                                        sinceDate:self.entryDate];
        
        NSDate* startDate180 = [[NSDate alloc] initWithTimeInterval:-interval180
                                                          sinceDate:endDate180];
        NSLog(@"New start date: %@", startDate180);
        NSLog(@"New end date: %@", endDate180);
        
        NSInteger totalDaysCount = 0;
   
        for (Trip *trip in self.trips)
        {
            NSInteger currentTripDays = [trip getTripDurationBetweenDates:startDate180 and:endDate180];
            NSLog(@"%@, lasted %ld days", trip, (long)currentTripDays);
            totalDaysCount += currentTripDays;
        }
        
        NSLog(@"Total used days %ld", totalDaysCount);
        
        
        daysAvailableLoop = MAX_DAYS - totalDaysCount;
        NSLog(@"Remaining days %ld", daysAvailableLoop);
        if (daysAvailableLoop == daysAvailablePrevious) {
            break;
        }
        else{
            daysAvailablePrevious = daysAvailableLoop;
        }
        
    }
    
    return daysAvailableLoop;

    // counting available days in new calculated winow
//    NSTimeInterval daysAvailableLoopSeconds = daysAvailableLoop * 60 * 60 * 24;
//    endDate180 = [[NSDate alloc] initWithTimeInterval:daysAvailableLoopSeconds
//                                                    sinceDate:self.entryDate];
//    
//    startDate180 = [[NSDate alloc] initWithTimeInterval:-interval180
//                                                      sinceDate:endDate180];
//    
//    totalDaysCount = 0;
//    for (Trip *trip in self.trips)
//    {
//        NSInteger currentTripDays = [trip getTripDurationBetweenDates:startDate180 and:endDate180];
//        NSLog(@"Trip %@ days %ld", trip.name, (long)currentTripDays);
//        totalDaysCount += currentTripDays;
//    }
//
//    return MAX_DAYS - totalDaysCount;
    
} */

- (NSInteger)getTotalRemainingDays {
 
    NSTimeInterval interval180 = DAYS_WINDOW * 60 * 60 * 24;
    NSInteger daysSpentPresent = 0;
    NSInteger remainingDays;

    do {
        NSDate* endDate180 = [[NSDate alloc] initWithTimeInterval:60*60*24*daysSpentPresent sinceDate: self.entryDate];
        NSDate* startDate180 = [[NSDate alloc] initWithTimeInterval:-interval180 sinceDate:endDate180];
        
        NSInteger daysSpentPast = 0;
        for (Trip *trip in self.trips)
        {
            NSInteger daysCount = [trip getTripDurationBetweenDates:startDate180 and:endDate180];
            daysSpentPast += daysCount;
        }
        
        remainingDays = 90 - (daysSpentPast + daysSpentPresent);
        daysSpentPresent += remainingDays;
    } while (remainingDays > 0);

//    mmnt 12/11/2015
//    return daysSpentPresent;
    return fmax(daysSpentPresent,0);
}

- (Trip *)intersectionTrip:(NSDate *)startDate and:(NSDate *)endDate currentTrip:(Trip *)currentTrip{
    // return intersection Trip * if any
    
    for (Trip *trip in self.trips) {

        // mmnt 12/11/2015
        // check if there is a trip "in process"
        if (currentTrip!=nil && currentTrip == trip) continue;
        if ((trip.endDate == nil) && ( [startDate compare:trip.startDate] != NSOrderedAscending || [endDate compare:trip.endDate] != NSOrderedAscending )) {
         return trip;
        }
        
        // compare if startDate is in between other trip startDate-endDate range
        if (
            ([startDate compare:trip.startDate] != NSOrderedAscending) &&          // later or equal than trip.startDate
            (([startDate compare:trip.endDate] == NSOrderedAscending) || trip.endDate == nil)
            )           // and earlier than trip.endDate
            return trip;
        
        // check if endDate is in between another trip time interval
        if (([endDate compare:trip.startDate] == NSOrderedDescending) &&
            ([endDate compare:trip.endDate] != NSOrderedDescending))
            return trip;
        
        // compare if startDate is earlier than trip startDate and endDate is later than trip endDate
        if (
            ([startDate compare:trip.startDate] == NSOrderedAscending) &&          // earlier than trip.startDate
            ([endDate compare:trip.endDate] != NSOrderedAscending)
            )           // and earlier than trip.endDate
            return trip;
        
    }
    return nil;
}

- (BOOL)hasTripInProcess {
    for (Trip *trip in self.trips) {
        if (trip.endDate == nil) return YES;
    }
    return NO;
}

- (NSDate *)tripInProcessEntryDate {
    for (Trip *trip in self.trips) {
        if (trip.endDate == nil) return trip.startDate;
    }
    return nil;
}

@end
