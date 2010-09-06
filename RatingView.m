//
//  RatingView.m
//  Criteria
//
//  Created by Casey Marshall on 8/30/10.
//  Copyright 2010 Modal Domains. All rights reserved.
//

#import "RatingView.h"

#define PI 3.14159265
#define d2r(d) ((d) * (PI/180))

@interface RatingView (private)

- (void) drawStarCenteredAtPoint: (CGPoint) p
                         context: (CGContextRef) c;
- (void) drawDotCenteredAtPoint: (CGPoint) p
                        context: (CGContextRef) c;

- (void) makeStarGradient;
- (void) makeDotGradient;

@end


@implementation RatingView

@synthesize delegate;

- (RatingKind) ratingKind
{
    return ratingKind;
}

- (NSUInteger) rating
{
    return rating;
}

- (void) setRating: (NSUInteger) aRating
{
    if (aRating < 1 || aRating > (NSUInteger) self.ratingKind)
        [[NSException exceptionWithName: @"RatingViewInvalidRating"
                                 reason: [NSString stringWithFormat: @"Rating must be between 1 and %d", self.ratingKind]
                               userInfo: nil]
         raise];
    
    if (rating != aRating)
    {
        rating = aRating;
        [self setNeedsDisplay];
        if (self.delegate != nil)
            [self.delegate ratingViewDidChangeRating: self];
    }
}

- (UIColor *) starColor
{
    return starColor;
}

- (void) setStarColor:(UIColor *) c
{
    if (starColor != nil)
        [starColor release];
    
    starColor = c;
    [starColor retain];
    if (starColor != nil && starHighlightColor != nil)
    {
        [self makeStarGradient];
#if DEBUG_MESSAGES
        NSLog(@"starColor:%@ starGradient:%p", starColor, starGradient);
#endif
    }
}

- (UIColor *) starHighlightColor
{
    return starHighlightColor;
}

- (void) setStarHighlightColor:(UIColor *) c
{
    if (starHighlightColor != nil)
        [starHighlightColor release];
    
    starHighlightColor = c;
    [starHighlightColor retain];
    if (starColor != nil && starHighlightColor != nil)
    {
        [self makeStarGradient];
#if DEBUG_MESSAGES
        NSLog(@"starHighlightColor:%@ starGradient:%p", starHighlightColor, starGradient);
#endif
    }
}

- (UIColor *) dotColor
{
    return dotColor;
}

- (void) setDotColor: (UIColor *) c
{
    if (dotColor != nil)
        [dotColor release];
    
    dotColor = c;
    [dotColor retain];
    if (dotColor != nil && dotHighlightColor != nil)
    {
        [self makeDotGradient];
#if DEBUG_MESSAGES
        NSLog(@"dotColor:%@ dotGradient:%p", dotColor, dotGradient);
#endif
    }
}

- (UIColor *) dotHighlightColor
{
    return dotHighlightColor;
}

- (void) setDotHighlightColor:(UIColor *) c
{
    if (dotHighlightColor != nil)
        [dotHighlightColor release];
    
    dotHighlightColor = c;
    [dotHighlightColor retain];
    if (dotColor != nil && dotHighlightColor != nil)
    {
        [self makeDotGradient];
#if DEBUG_MESSAGES
        NSLog(@"dotHighlightColor:%@ dotGradient:%p", dotHighlightColor, dotGradient);
#endif
    }
}

- (CGFloat) starRadius
{
    return starRadius;
}

- (void) setStarRadius:(CGFloat) r
{
    if (starRadius != r)
    {
        if (r <= starInnerRadius)
            [[NSException exceptionWithName: @"RatingViewInvalidRadius"
                                     reason: [NSString stringWithFormat: @"star outer radius (%f) is smaller than the inner radius (%f)", r, starInnerRadius]
                                   userInfo: nil] raise];
        starRadius = r;
        
        // Precompute the points of the outer pentagon.
        outerStarPoints[0] = CGPointMake(r * cos(d2r(270)), r * sin(d2r(270)));
        outerStarPoints[1] = CGPointMake(r * cos(d2r(342)), r * sin(d2r(342)));
        outerStarPoints[2] = CGPointMake(r * cos(d2r( 54)), r * sin(d2r( 54)));
        outerStarPoints[3] = CGPointMake(r * cos(d2r(126)), r * sin(d2r(126)));
        outerStarPoints[4] = CGPointMake(r * cos(d2r(198)), r * sin(d2r(198)));
        
        // And the gradient control points.
        starGradientPoints[0] = CGPointMake(r * cos(d2r(105)), r * sin(d2r(105)));
        starGradientPoints[1] = CGPointMake(r * cos(d2r(285)), r * sin(d2r(285)));
        
#if DEBUG_MESSAGES
      NSLog(@"starRadius:%f p:(%f, %f) (%f, %f) (%f, %f) (%f, %f) (%f, %f) -- gp:(%f, %f) (%f, %f)",
            starRadius, outerStarPoints[0].x, outerStarPoints[0].y,
            outerStarPoints[1].x, outerStarPoints[1].y,
            outerStarPoints[2].x, outerStarPoints[2].y,
            outerStarPoints[3].x, outerStarPoints[3].y,
            outerStarPoints[4].x, outerStarPoints[4].y,
            starGradientPoints[0].x, starGradientPoints[0].y,
            starGradientPoints[1].x, starGradientPoints[1].y);
#endif
    }
}

- (CGFloat) starInnerRadius
{
    return starInnerRadius;
}

- (void) setStarInnerRadius:(CGFloat) r
{
    if (starInnerRadius != r)
    {
        if (r >= starRadius)
            [[NSException exceptionWithName: @"RatingViewInvalidRadius"
                                     reason: [NSString stringWithFormat: @"star inner radius (%f) is larger than the outer radius (%f)", r, starRadius]
                                   userInfo: nil] raise];
        
        starInnerRadius = r;
        
        // Precompute the points of the inner pentagon.
        innerStarPoints[0] = CGPointMake(r * cos(d2r(306)), r * sin(d2r(306)));
        innerStarPoints[1] = CGPointMake(r * cos(d2r( 18)), r * sin(d2r( 18)));
        innerStarPoints[2] = CGPointMake(r * cos(d2r( 90)), r * sin(d2r( 90)));
        innerStarPoints[3] = CGPointMake(r * cos(d2r(162)), r * sin(d2r(162)));
        innerStarPoints[4] = CGPointMake(r * cos(d2r(234)), r * sin(d2r(234)));
        
#if DEBUG_MESSAGES
        NSLog(@"starInnerRadius:%f p:(%f, %f) (%f, %f) (%f, %f) (%f, %f) (%f, %f)",
              starInnerRadius,
              innerStarPoints[0].x, innerStarPoints[0].y,
              innerStarPoints[1].x, innerStarPoints[1].y,
              innerStarPoints[2].x, innerStarPoints[2].y,
              innerStarPoints[3].x, innerStarPoints[3].y,
              innerStarPoints[4].x, innerStarPoints[4].y);  
#endif
    }
}

- (CGFloat) dotRadius
{
    return dotRadius;
}

- (void) setDotRadius:(CGFloat) r
{
    if (dotRadius != r)
    {
        dotRadius = r;
        
        dotGradientPoints[0] = CGPointMake(r * cos(d2r(105)), r * sin(d2r(105)));
        dotGradientPoints[1] = CGPointMake(r * cos(d2r(285)), r * sin(d2r(285)));
        
#if DEBUG_MESSAGES
        NSLog(@"dotRadius:%f gp:(%f, %f) (%f, %f)",
              dotRadius, dotGradientPoints[0].x, dotGradientPoints[0].y,
              dotGradientPoints[1].x, dotGradientPoints[1].y);
#endif
    }
}

- (id) initWithFrame: (CGRect) aFrame
          ratingKind: (RatingKind) aRatingKind
{
    if (aRatingKind != RatingKindThreeStar
        && aRatingKind != RatingKindFourStar
        && aRatingKind != RatingKindFiveStar)
        return nil;
    if ((self = [super initWithFrame:aFrame]))
    {
        starGradient = NULL;
        dotGradient = NULL;
        ratingKind = aRatingKind;
        
        self.dotColor = [UIColor colorWithWhite:0.0 alpha:0.500];
        self.dotHighlightColor = [UIColor colorWithWhite:0.702 alpha:1.000];
        self.starColor = [UIColor colorWithWhite: 0.0 alpha:0.500];
        self.starHighlightColor = [UIColor colorWithWhite: 0.702 alpha:1.000];
        
        CGFloat r = aFrame.size.height;
        if (r > aFrame.size.width / (CGFloat) aRatingKind - 4)
            r = aFrame.size.width / (CGFloat) aRatingKind - 4;
        
        self.starRadius = r / 2;
        self.starInnerRadius = r / 5;
        self.dotRadius = r / 8;
        
        switch (aRatingKind)
        {
            case RatingKindThreeStar:
                self.rating = 2;
                break;
            case RatingKindFourStar:
                self.rating = 2;
                break;
            case RatingKindFiveStar:
                self.rating = 3;
        }
    }
    return self;
}

- (void) drawRect: (CGRect) rect
{
    [super drawRect: rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect b = self.bounds;
    CGFloat y = b.size.height / 2.f;
    switch (self.ratingKind)
    {
        case RatingKindThreeStar:
        {
            CGFloat w = b.size.width / 3;
            CGFloat x0 = w / 2.f;
            CGFloat x1 = x0 + w;
            CGFloat x2 = x1 + w;
            
            switch (self.rating)
            {
                case 1:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x1, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                         context: context];
                    break;
                case 2:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                         context: context];
                    break;
                case 3:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    break;
            }
        }
            break;
            
        case RatingKindFourStar:
        {
            CGFloat w = b.size.width / 4;
            CGFloat x0 = w / 2.f;
            CGFloat x1 = x0 + w;
            CGFloat x2 = x1 + w;
            CGFloat x3 = x2 + w;
            switch (self.rating)
            {
                case 1:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x1, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                         context: context];
                    break;
                    
                case 2:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                         context: context];
                    break;
                    
                case 3:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                         context: context];
                    break;
                    
                case 4:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x3, y)
                                          context: context];
                    break;
            }
        }
            break;
            
        case RatingKindFiveStar:
        {
            CGFloat w = b.size.width / 5;
            CGFloat x0 = w / 2.f;
            CGFloat x1 = x0 + w;
            CGFloat x2 = x1 + w;
            CGFloat x3 = x2 + w;
            CGFloat x4 = x3 + w;
            
            switch (self.rating)
            {
                case 1:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x4, y)
                                          context: context];
                    break;
                    
                case 2:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x2, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x4, y)
                                         context: context];
                    break;
                    
                case 3:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                         context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x3, y)
                                         context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x4, y)
                                         context: context];
                    break;
                    
                case 4:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                         context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x3, y)
                                          context: context];
                    [self drawDotCenteredAtPoint: CGPointMake(x4, y)
                                         context: context];
                    break;
                    
                case 5:
                    [self drawStarCenteredAtPoint: CGPointMake(x0, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x1, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x2, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x3, y)
                                          context: context];
                    [self drawStarCenteredAtPoint: CGPointMake(x4, y)
                                          context: context];
                    break;
            }
        }
            break;
    }
}

- (void) dealloc
{
    [starColor release];
    [starHighlightColor release];
    [dotColor release];
    [dotHighlightColor release];
    if (delegate != nil)
        [delegate release];
    if (starGradient != NULL)
        CGGradientRelease(starGradient);
    if (dotGradient != NULL)
        CGGradientRelease(dotGradient);
    [super dealloc];
}

#pragma mark -
#pragma mark Touch Events

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: self];
        CGFloat pct = location.x / self.bounds.size.width;
        
        switch (self.ratingKind)
        {
            case RatingKindThreeStar:
                if (pct <= (1.f/3.f))
                    self.rating = 1;
                else if (pct <= 2.f/3.f)
                    self.rating = 2;
                else
                    self.rating = 3;
                break;
                
            case RatingKindFourStar:
                if (pct <= 0.25)
                    self.rating = 1;
                else if (pct <= 0.5)
                    self.rating = 2;
                else if (pct <= 0.75)
                    self.rating = 3;
                else
                    self.rating = 4;
                break;
                
            case RatingKindFiveStar:
                if (pct <= (1.f/5.f))
                    self.rating = 1;
                else if (pct <= 2.f/5.f)
                    self.rating = 2;
                else if (pct <= 3.f/5.f)
                    self.rating = 3;
                else if (pct <= 4.f/5.f)
                    self.rating = 4;
                else
                    self.rating = 5;
                break;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: self];
        CGFloat pct = location.x / self.bounds.size.width;
        
        switch (self.ratingKind)
        {
            case RatingKindThreeStar:
                if (pct <= (1.f/3.f))
                    self.rating = 1;
                else if (pct <= 2.f/3.f)
                    self.rating = 2;
                else
                    self.rating = 3;
                break;
                
            case RatingKindFourStar:
                if (pct <= 0.25)
                    self.rating = 1;
                else if (pct <= 0.5)
                    self.rating = 2;
                else if (pct <= 0.75)
                    self.rating = 3;
                else
                    self.rating = 4;
                break;
                
            case RatingKindFiveStar:
                if (pct <= (1.f/5.f))
                    self.rating = 1;
                else if (pct <= 2.f/5.f)
                    self.rating = 2;
                else if (pct <= 3.f/5.f)
                    self.rating = 3;
                else if (pct <= 4.f/5.f)
                    self.rating = 4;
                else
                    self.rating = 5;
                break;
        }
    }
}

@end

@implementation RatingView (private)

- (void) drawStarCenteredAtPoint: (CGPoint) p
                         context: (CGContextRef) context
{
#if DEBUG_MESSAGES
    NSLog(@"drawStarCenteredAtPoint:(%f, %f)", p.x, p.y);
#endif
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGContextBeginPath(context);
    CGPathMoveToPoint(path, NULL, outerStarPoints[0].x + p.x, outerStarPoints[0].y + p.y);
    CGPathAddLineToPoint(path, NULL, innerStarPoints[0].x + p.x, innerStarPoints[0].y + p.y);
    CGPathAddLineToPoint(path, NULL, outerStarPoints[1].x + p.x, outerStarPoints[1].y + p.y);
    CGPathAddLineToPoint(path, NULL, innerStarPoints[1].x + p.x, innerStarPoints[1].y + p.y);
    CGPathAddLineToPoint(path, NULL, outerStarPoints[2].x + p.x, outerStarPoints[2].y + p.y);
    CGPathAddLineToPoint(path, NULL, innerStarPoints[2].x + p.x, innerStarPoints[2].y + p.y);
    CGPathAddLineToPoint(path, NULL, outerStarPoints[3].x + p.x, outerStarPoints[3].y + p.y);
    CGPathAddLineToPoint(path, NULL, innerStarPoints[3].x + p.x, innerStarPoints[3].y + p.y);
    CGPathAddLineToPoint(path, NULL, outerStarPoints[4].x + p.x, outerStarPoints[4].y + p.y);
    CGPathAddLineToPoint(path, NULL, innerStarPoints[4].x + p.x, innerStarPoints[4].y + p.y);
    //CGPathAddLineToPoint(path, NULL, outerStarPoints[0].x + p.x, outerStarPoints[0].y);
    CGPathCloseSubpath(path);
    
    CGPoint startPoint = CGPointMake(self.frame.size.width / 2, 0);
    CGPoint endPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height);
    
    /*startPoint.x = startPoint.x + starGradientPoints[0].x;
    startPoint.y = startPoint.y + starGradientPoints[0].y;
    endPoint.x = endPoint.x + starGradientPoints[1].x;
    endPoint.y = endPoint.y + starGradientPoints[1].y;*/
    
    CGContextSetFillColorWithColor(context, [self.starColor CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    /*CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, starGradient, startPoint, endPoint,
                                kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);*/
    
    /*CGContextSetStrokeColorWithColor(context, [self.starColor CGColor]);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);*/
    
    CGPathRelease(path);
}

- (void) drawDotCenteredAtPoint: (CGPoint) p
                        context: (CGContextRef) context
{
#if DEBUG_MESSAGES
    NSLog(@"drawDotCenteredAtPoint:(%f, %f)", p.x, p.y);
#endif
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = CGRectMake(p.x - dotRadius,
                             p.y - dotRadius,
                             2 * dotRadius, 2 * dotRadius);
    CGPathAddEllipseInRect(path, NULL, rect);
    CGPathCloseSubpath(path);

    CGPoint startPoint = p;
    CGPoint endPoint = p;
    
    startPoint.x = startPoint.x + dotGradientPoints[0].x;
    startPoint.y = startPoint.y + dotGradientPoints[0].y;
    endPoint.x = endPoint.x + dotGradientPoints[1].x;
    endPoint.y = endPoint.y + dotGradientPoints[1].y;
    
#if DEBUG_MESSAGES
    NSLog(@"dotGradient points: (%f, %f) to (%f, %f)",
          startPoint.x, startPoint.y, endPoint.x, endPoint.y);
#endif
    
    CGContextSetFillColorWithColor(context, [self.dotColor CGColor]);
    CGContextAddPath(context, path);
    CGContextFillPath(context);

    /*CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, dotGradient, startPoint, endPoint,
                                kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);*/

    /*CGContextSetStrokeColorWithColor(context, [self.starColor CGColor]);
    CGContextSetLineWidth(context, 1.5);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);*/
    
    CGPathRelease(path);
}

- (void) makeStarGradient
{
    if (starGradient != NULL)
        CGGradientRelease(starGradient);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CFMutableArrayRef colors = CFArrayCreateMutable(NULL, 4, NULL);
    CFArrayAppendValue(colors, [starColor CGColor]);
    CFArrayAppendValue(colors, [starColor CGColor]);
    CFArrayAppendValue(colors, [starHighlightColor CGColor]);
    CFArrayAppendValue(colors, [starHighlightColor CGColor]);
    const CGFloat locations[] = { 0.f, 0.6f, 0.61f, 1.f };
    starGradient = CGGradientCreateWithColors(space, colors, locations);
    CGColorSpaceRelease(space);
    CFRelease(colors);
#if DEBUG_MESSAGES
    NSLog(@"starGradient:%@", starGradient);
#endif
}

- (void) makeDotGradient
{
    if (dotGradient != NULL)
        CGGradientRelease(dotGradient);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CFMutableArrayRef colors = CFArrayCreateMutable(NULL, 4, NULL);
    CFArrayAppendValue(colors, [dotColor CGColor]);
    CFArrayAppendValue(colors, [dotColor CGColor]);
    CFArrayAppendValue(colors, [dotHighlightColor CGColor]);
    CFArrayAppendValue(colors, [dotHighlightColor CGColor]);
    const CGFloat locations[] = { 0.f, 0.6f, 0.61f, 1.f };
    dotGradient = CGGradientCreateWithColors(space, colors, locations);
    CGColorSpaceRelease(space);
    CFRelease(colors);
#if DEBUG_MESSAGES
    NSLog(@"dotGradient:%@", dotGradient);
#endif
}

@end
