//
//  VCBaseEntityDataSource.m
//  VCBaseEntityDataSource
//
//  Copyright (C) 2011 by Vinay Chavan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "VCBaseEntityDataSource.h"

@interface VCBaseEntityDataSource ()
@property (strong, nonatomic) NSString *entityName;

@end


@implementation VCBaseEntityDataSource

@synthesize entityName = _entityName;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (id)initWithEntityName:(NSString *)anEntityName {
    self = [super init];
    if (self) {
		self.entityName = anEntityName;
    }
    return self;
}

- (void)dealloc {
	_fetchedResultsController.delegate = self;
}

#pragma mark - Private Methods

- (void)saveManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext == nil) {
		return;
	}

    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [managedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            DebugLog(@"Could not save new context due to %@", error);
        }
    }];

	[self saveManagedObjectContext:managedObjectContext.parentContext];
}


#pragma mark - Public Methods

- (void)fetchWithPredicate:(NSPredicate *)predicate
		   sortDescriptors:(NSArray *)sortDescriptors
			sectionKeyPath:(NSString *)sectionKeyPath
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
	[fetchRequest setResultType:NSManagedObjectResultType];
	if (predicate) {
		[fetchRequest setPredicate:predicate];
	}
	if (sortDescriptors) {
		[fetchRequest setSortDescriptors:sortDescriptors];
	}
	[fetchRequest setFetchBatchSize:20];

	if (_fetchedResultsController) {
		DebugLog(@"This should not happen. ##############");
		RELEASE_SAFELY(_fetchedResultsController);
	}
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																	managedObjectContext:managedObjectContext
																	  sectionNameKeyPath:sectionKeyPath
																			   cacheName:nil];
	_fetchedResultsController.delegate = self;

	RELEASE_SAFELY(fetchRequest);
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	return [_fetchedResultsController objectAtIndexPath:indexPath];
}

- (id)sections
{
	return [_fetchedResultsController sections];
}

- (void)updatePredicate:(NSPredicate *)predicate
{
	[_fetchedResultsController.fetchRequest setPredicate:predicate];

	[self reloadData];
}

- (void)reloadData
{
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		DebugLog(@"%@", [error localizedDescription]);
		//abort();
	}

	if ([self.delegate respondsToSelector:@selector(didFinishLoadingDataSource:)]) {
		[self.delegate didFinishLoadingDataSource:self];
	}
}

- (void)save
{
	[self saveManagedObjectContext:self.fetchedResultsController.managedObjectContext];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if ([self.delegate respondsToSelector:@selector(willBeginUpdatingDataSource:)]) {
		[self.delegate willBeginUpdatingDataSource:self];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if ([self.delegate respondsToSelector:@selector(didFinishUpdateDataSource:)]) {
		[self.delegate didFinishUpdateDataSource:self];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	if ([self.delegate respondsToSelector:@selector(dataSource:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
		[self.delegate dataSource:self
				  didChangeObject:anObject
					  atIndexPath:indexPath
					forChangeType:type
					 newIndexPath:newIndexPath];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if ([self.delegate respondsToSelector:@selector(dataSource:didChangeSection:atIndex:forChangeType:)]) {
		[self.delegate dataSource:self
				 didChangeSection:sectionInfo
						  atIndex:sectionIndex
					forChangeType:type];
	}
}

@end
