/*
 * Copyright (C) 2018 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "config.h"

#if ENABLE(FULLSCREEN_API) && PLATFORM(IOS_FAMILY)
#import "WKFullscreenStackView.h"

#import "UIKitSPI.h"
#import <UIKit/UIVisualEffectView.h>
#import <pal/cf/CoreMediaSoftLink.h>
#import <pal/spi/cocoa/QuartzCoreSPI.h>
#import <wtf/NeverDestroyed.h>
#import <wtf/RetainPtr.h>

SOFTLINK_AVKIT_FRAMEWORK()
SOFT_LINK_CLASS_OPTIONAL(AVKit, AVBackgroundView)

@interface WKFullscreenStackView () {

#if PLATFORM(APPLETV)
    RetainPtr<UIView> _backgroundView;
#else
    RetainPtr<AVBackgroundView> _backgroundView;
#endif
}
@end

@implementation WKFullscreenStackView

#pragma mark - External Interface

- (instancetype)init
{
    CGRect frame = CGRectMake(0, 0, 100, 100);
    self = [self initWithFrame:frame];

    if (!self)
        return nil;

    [self setClipsToBounds:YES];
#if PLATFORM(APPLETV)
    _backgroundView = adoptNS([[UIView alloc] initWithFrame:frame]);
    _backgroundView.get().backgroundColor = [UIColor blackColor];
#else
    _backgroundView = adoptNS([allocAVBackgroundViewInstance() initWithFrame:frame]);
    // FIXME: remove this once AVBackgroundView handles this. https://bugs.webkit.org/show_bug.cgi?id=188022
    [_backgroundView setClipsToBounds:YES];
ALLOW_DEPRECATED_DECLARATIONS_BEGIN
    [_backgroundView.get().layer setContinuousCorners:YES];
ALLOW_DEPRECATED_DECLARATIONS_END
    [_backgroundView.get().layer setCornerRadius:16];
#endif
    [self addSubview:_backgroundView.get()];
    return self;
}

#if PLATFORM(APPLETV)
- (void)addArrangedSubviewForTV:(UIView *)subview
{
    [_backgroundView addSubview:subview];
    [self addArrangedSubview:subview];
}
#else
- (void)addArrangedSubview:(UIView *)subview applyingMaterialStyle:(AVBackgroundViewMaterialStyle)materialStyle tintEffectStyle:(AVBackgroundViewTintEffectStyle)tintEffectStyle
{
    [_backgroundView.get() addSubview:subview applyingMaterialStyle:materialStyle tintEffectStyle:tintEffectStyle];
    [self addArrangedSubview:subview];
}
#endif

#pragma mark - UIView Overrides

- (void)layoutSubviews
{
    [_backgroundView.get() setFrame:self.bounds];
    [super layoutSubviews];
}

@end

#endif // ENABLE(FULLSCREEN_API) && PLATFORM(IOS_FAMILY)
