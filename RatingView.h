//
//  RatingView.h
//  Criteria
//
//  Created by Casey Marshall on 8/30/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingView;
@protocol RatingViewDelegate

- (void) ratingViewDidChangeRating: (RatingView *) ratingView;

@end


typedef enum RatingKind
{
    RatingKindThreeStar = 3,
    RatingKindFourStar = 4,
    RatingKindFiveStar = 5
} RatingKind;

@interface RatingView : UIView
{
    RatingKind ratingKind;
    NSUInteger rating;
    CGFloat starRadius;
    CGFloat starInnerRadius;
    CGFloat dotRadius;
    UIColor *starColor;
    UIColor *starHighlightColor;
    UIColor *dotColor;
    UIColor *dotHighlightColor;
    
    CGGradientRef starGradient;
    CGGradientRef dotGradient;
    
    CGPoint outerStarPoints[5];
    CGPoint innerStarPoints[5];
    CGPoint starGradientPoints[2];
    CGPoint dotGradientPoints[2];
    
    id<RatingViewDelegate> delegate;
}

@property (readonly) RatingKind ratingKind;
@property (assign) NSUInteger rating;
@property (assign) CGFloat starRadius;
@property (assign) CGFloat starInnerRadius;
@property (assign) CGFloat dotRadius;
@property (retain) UIColor *starColor;
@property (retain) UIColor *starHighlightColor;
@property (retain) UIColor *dotColor;
@property (retain) UIColor *dotHighlightColor;

@property (retain) IBOutlet id<RatingViewDelegate> delegate;

- (id) initWithFrame: (CGRect) aFrame
          ratingKind: (RatingKind) aRatingKind;

@end
