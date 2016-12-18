//
//  AYVariableFlowLayout.m
//  AYVariableFlowLayout
//
//  Created by Andrey Yastrebov on 17.12.16.
//  Copyright © 2016 Andrey Yastrebov. All rights reserved.
//

#import "AYVariableFlowLayout.h"
#import "AYVariableLayoutAttributes.h"

@interface AYVariableFlowLayout ()
@property (nonatomic, weak) id<AYVariableDelegateFlowLayout> delegate;

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *allItemAttributes;
@property (nonatomic, strong) NSMutableArray<NSArray *> *sectionItemAttributes;

@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
@property (nonatomic, strong) NSMutableArray *unionRects;

@property (nonatomic) CGFloat contentHeight;
@end

@implementation AYVariableFlowLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

#pragma mark - Init

- (void)commonInit {
}

- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Methods to Override

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.allItemAttributes removeAllObjects];
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    CGFloat cvWidth = self.collectionView.bounds.size.width;
    
    if (self.allItemAttributes.count == 0) {
        
        __block CGFloat xOffset = 0;
        __block CGFloat yOffset = 0;
        
        for (NSUInteger section = 0; section < numberOfSections; section++) {
            
            CGFloat verticalPadding =
            [self.delegate collectionView:self.collectionView
                                   layout:self
         verticalPaddingForSectionAtIndex:section];
            
            CGFloat horizontalPadding =
            [self.delegate collectionView:self.collectionView
                                   layout:self
       horizontalPaddingForSectionAtIndex:section];
            
            UIEdgeInsets sectionInsets =
            [self.delegate collectionView:self.collectionView
                                   layout:self
                   insetForSectionAtIndex:section];
            
            CGFloat headerHeight =
            [self.delegate collectionView:self.collectionView
                                   layout:self
                 heightForHeaderInSection:section];
            
            // Header
            if (headerHeight > 0) {
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                              withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                attributes.frame = CGRectMake(0, yOffset, cvWidth, headerHeight);
                yOffset += headerHeight;
                yOffset += sectionInsets.top;
                
                [self.allItemAttributes addObject:attributes];
            }
            
            NSUInteger items = [self.collectionView numberOfItemsInSection:section];
            NSMutableArray<AYVariableLayoutAttributes *> *itemAttributes = [NSMutableArray arrayWithCapacity:items];
            
            __block NSUInteger row = 0;
            __block NSUInteger rowIndex = 0;
            CGFloat itemMaxHeight = 0;
            
            // Items
            for (NSUInteger item = 0; item < items; item++) {
                
                if (item == 0) {
                    xOffset = sectionInsets.left;
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                
                CGSize size =
                [self.delegate collectionView:self.collectionView
                                       layout:self
                       sizeForItemAtIndexPath:indexPath];
                
                if (xOffset + size.width > cvWidth - sectionInsets.right) {
                    xOffset = sectionInsets.left;
                    row++;
                    rowIndex = 0;
                    
                    if (item != 0) {
                        
                        NSUInteger previousRowFirstItemIndex =
                        [itemAttributes indexOfObjectPassingTest:^BOOL(AYVariableLayoutAttributes *obj, NSUInteger idx, BOOL *stop) {
                            return (obj.row == (row - 1)) && obj.rowIndex == 0;
                        }];
                        
                        yOffset += itemAttributes[previousRowFirstItemIndex].size.height;
                        yOffset += verticalPadding;
                    }
                }
                
                __block CGRect frame = CGRectMake(xOffset, yOffset, size.width, size.height);
                
                if (row > 0) {
                    NSIndexSet *previousRowIndexes = [itemAttributes indexesOfObjectsPassingTest:^BOOL(AYVariableLayoutAttributes *obj, NSUInteger idx, BOOL *stop) {
                        return obj.row == (row - 1);
                    }];
                    
                    [itemAttributes enumerateObjectsAtIndexes:previousRowIndexes
                                                      options:NSEnumerationConcurrent
                                                   usingBlock:^(AYVariableLayoutAttributes *obj, NSUInteger idx, BOOL *stop) {
                                                       if (CGRectIntersectsRect(obj.frame, frame)) {
                                                           
                                                           // First, try to move it right
                                                           CGFloat newOffset = CGRectGetMaxX(obj.frame);
                                                           newOffset += horizontalPadding;
                                                           
                                                           if (xOffset + size.width > cvWidth - sectionInsets.right) {
                                                               // Can't move right, let's go down
                                                               xOffset = sectionInsets.left;
                                                               row++;
                                                               rowIndex = 0;
                                                               
                                                               yOffset += size.height;
                                                               yOffset += verticalPadding;
                                                               
                                                           } else {
                                                               xOffset = newOffset;
                                                               frame.origin.x = newOffset;
                                                           }
                                                       }
                                                   }];
                }
                
                AYVariableLayoutAttributes *attributes = [AYVariableLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = frame;
                attributes.row = row;
                attributes.rowIndex = rowIndex;
                
                xOffset += size.width;
                xOffset += horizontalPadding;
                
                [itemAttributes addObject:attributes];
                [self.allItemAttributes addObject:attributes];
                
                if (size.height > itemMaxHeight) {
                    itemMaxHeight = size.height;
                }
                
                // if last object in section
                if (item == items - 1) {
                    yOffset += itemMaxHeight;
                }
            }
            
            [self.sectionItemAttributes addObject:itemAttributes.copy];
            
            // Footer
            CGFloat footerHeight =
            [self.delegate collectionView:self.collectionView
                                   layout:self
                 heightForFooterInSection:section];
            
            if (footerHeight > 0) {
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                                              withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
                yOffset += sectionInsets.bottom;
                attributes.frame = CGRectMake(0, yOffset, cvWidth, footerHeight);
                yOffset += footerHeight;
                
                [self.allItemAttributes addObject:attributes];
            }
        }
    }
    
    // Build union rects
    NSInteger idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
    
    self.contentHeight = CGRectGetMaxY(self.allItemAttributes.lastObject.frame);
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = self.contentHeight;
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        attribute = self.headersAttribute[@(indexPath.section)];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrs = [NSMutableArray array];
    
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Accessors

- (id<AYVariableDelegateFlowLayout>)delegate {
    return (id<AYVariableDelegateFlowLayout>)self.collectionView.delegate;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableDictionary *)headersAttribute {
    if (!_headersAttribute) {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
    if (!_footersAttribute) {
        _footersAttribute = [NSMutableDictionary dictionary];
    }
    return _footersAttribute;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

@end
