//
//  VCBaseEntityDataSource
//  Demo
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

#import "ETDataManager.h"

@implementation VCBaseEntityDataSource

@synthesize entityName = _entityName;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (id)initWithEntityName:(NSString *)anEntityName {
    self = [super init];
    if (self) {
		_entityName = [anEntityName retain];
    }
    return self;
}

- (void)dealloc {
	[_fetchedResultsController release], _fetchedResultsController = nil;
    [_entityName release], _entityName = nil;
    [super dealloc];
}

#pragma mark - Private Methods



#pragma mark - Public Methods

- (void)fetchWithPredicate:(NSPredicate *)predicate
		   sortDescriptors:(NSArray *)sortDescriptors
			sectionKeyPath:(NSString *)sectionKeyPath
{
	NSManagedObjectContext *managedObjectContext = [[ETDataManager sharedInstance] masterManagedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.entityName];
	[fetchRequest setResultType:NSManagedObjectResultType];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setFetchBatchSize:20];
	
	if (_fetchedResultsController) {
		DebugLog(@"This should not happen. ##############");
		[_fetchedResultsController release], _fetchedResultsController = nil;
	}
	_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																	managedObjectContext:managedObjectContext
																	  sectionNameKeyPath:sectionKeyPath
																			   cacheName:nil];
	_fetchedResultsController.delegate = self;

	[fetchRequest release], fetchRequest = nil;
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
		abort();
	}

	if ([self.delegate respondsToSelector:@selector(didFinishLoadingDataSource:)]) {
		[self.delegate didFinishLoadingDataSource:self];
	}
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
	switch (type) {
		case NSFetchedResultsChangeInsert:
			if ([self.delegate respondsToSelector:@selector(dataSource:didInsertObject:atIndexPath:)]) {
				[self.delegate dataSource:self didInsertObject:anObject atIndexPath:newIndexPath];
			}
			break;
		case NSFetchedResultsChangeDelete:
			if ([self.delegate respondsToSelector:@selector(dataSource:didDeleteObject:atIndexPath:)]) {
				[self.delegate dataSource:self didDeleteObject:anObject atIndexPath:indexPath];
			}
			break;
		case NSFetchedResultsChangeUpdate:
			if ([self.delegate respondsToSelector:@selector(dataSource:didUpdateObject:atIndexPath:)]) {
				[self.delegate dataSource:self didUpdateObject:anObject atIndexPath:indexPath];
			}
			break;
		case NSFetchedResultsChangeMove:
			if ([self.delegate respondsToSelector:@selector(dataSource:didMoveObject:fromIndexPath:toIndexPath:)]) {
				[self.delegate dataSource:self didMoveObject:anObject fromIndexPath:indexPath toIndexPath:newIndexPath];
			}
			break;
			
		default:
			DebugLog(@"WTF");
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
        case NSFetchedResultsChangeInsert:
			if ([self.delegate respondsToSelector:@selector(dataSource:didInsertSectionAtIndex:)]) {
				[self.delegate dataSource:self didInsertSectionAtIndex:sectionIndex];
			}
            break;
        case NSFetchedResultsChangeDelete:
			if ([self.delegate respondsToSelector:@selector(dataSource:didDeleteSectionAtIndex:)]) {
				[self.delegate dataSource:self didDeleteSectionAtIndex:sectionIndex];
			}
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            break;

        default:
			DebugLog(@"WTF");
			break;
    }
}

@end
