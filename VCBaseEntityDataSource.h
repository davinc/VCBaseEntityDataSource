//
//  VCBaseEntityDataSource.h
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol VCBaseDataSourceDelegate;

/** This is a base class of other entity data sources, This class is responsible for handling core data manipulation and sorting. This class hides implementaion of NSFetchedResultsController from caller */
@interface VCBaseEntityDataSource : NSObject <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *_fetchedResultsController;
}

@property (nonatomic, readonly) NSString *entityName;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) id<VCBaseDataSourceDelegate> delegate;

/** Returns instance of baseDataSource for passed entity
 * @param anEntityName Entity name for which data source is initialized
 * @return Instance if successful, else nil
 */
- (id)initWithEntityName:(NSString *)anEntityName;

/** Performs fetch request on core data for initialized entity.
 * @param predicate Predicate to be applied for fetch request
 * @param sortDescriptors Sort descriptors to be applied for fetch request
 * @param managedObjectContext Managed Object Context to be used for fetch request
 */
- (void)fetchWithPredicate:(NSPredicate *)predicate
		   sortDescriptors:(NSArray *)sortDescriptors
			sectionKeyPath:(NSString *)sectionKeyPath
	  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

/** Sets new predicate to fetch data
 * @param predicate Predicate to be applied for fetch request
 */
- (void)updatePredicate:(NSPredicate *)predicate;

/** Returns object at indexPath
 * @param indexPath indexPath of the object to be fetched
 * @return object if found, nil otherwise
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (id)sections;

- (void)reloadData;

- (void)save;

@end


@protocol VCBaseDataSourceDelegate <NSObject>

// To be called by classes that inherit this base class
@optional
- (void)didFinishLoadingDataSource:(VCBaseEntityDataSource *)aDataSource;
- (void)dataSource:(VCBaseEntityDataSource *)aDataSource didFailWithError:(NSError *)anError;
- (void)willBeginUpdatingDataSource:(VCBaseEntityDataSource *)aDataSource;
- (void)didFinishUpdateDataSource:(VCBaseEntityDataSource *)aDataSource;

// Will be called by me!, though you can override at your own risk
@optional
- (void)dataSource:(VCBaseEntityDataSource *)dataSource didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(VCBaseEntityDataSource *)dataSource didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;

@end
