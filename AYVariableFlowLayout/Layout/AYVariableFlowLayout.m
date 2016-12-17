//
//  AYVariableFlowLayout.m
//  AYVariableFlowLayout
//
//  Created by Andrey Yastrebov on 17.12.16.
//  Copyright © 2016 Andrey Yastrebov. All rights reserved.
//

#import "AYVariableFlowLayout.h"

@interface AYVariableFlowLayout ()
@property (nonatomic, weak) id<AYVariableDelegateFlowLayout> delegate;
@end

@implementation AYVariableFlowLayout

#pragma mark - Init

- (void)commonInit {
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Methods to Override

- (void)prepareLayout {
    [super prepareLayout];
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    
    return [super layoutAttributesForItemAtIndexPath:path];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [super layoutAttributesForElementsInRect:rect];
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

@end
