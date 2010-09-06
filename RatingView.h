//
//  RatingView.h
//
//  Created by Casey Marshall on 8/30/10.
//  Copyright 2010 Modal Domains.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
