/*
 * Copyright (c) 2011 - 2012, Precise Biometrics AB
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Precise Biometrics AB nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 *
 * $Date: 2012-08-16 11:15:11 +0200 (to, 16 aug 2012) $ $Rev: 15397 $ 
 *
 */



#import <Foundation/Foundation.h>
#import "PBBiometryUser.h"

/* Finger positions. */
typedef enum {
	PBFingerPositionUnknown,
	PBFingerPositionRightThumb,
	PBFingerPositionRightIndex,
	PBFingerPositionRightMiddle,
	PBFingerPositionRightRing,
	PBFingerPositionRightLittle,
	PBFingerPositionLeftThumb,
	PBFingerPositionLeftIndex,
	PBFingerPositionLeftMiddle,
	PBFingerPositionLeftRing,
	PBFingerPositionLeftLittle
} PBFingerPosition;

/** A finger, identified uniquely by it's position and user. */
@interface PBBiometryFinger : NSObject <NSCoding> {
	/** The position of the finger, e.g. 'right index' or 'left middle'. */
	PBFingerPosition position;
	/** The user of the finger. */
	PBBiometryUser *user;
}
@property (nonatomic, readonly) PBFingerPosition position;
@property (nonatomic, readonly) PBBiometryUser *user;

-(id) initWithPosition: (PBFingerPosition) aPosition 
               andUser: (PBBiometryUser*)aUser;

-(id) initWithPosition: (PBFingerPosition) aPosition 
             andUserId: (uint32_t)aUserId;

/** Returns YES if the two fingers are equal, otherwise NO. */
-(BOOL) isEqualToFinger: (PBBiometryFinger*) finger;

/** Returns YES if the finger is a finger on the left hand. */
-(BOOL) isOnLeftHand;

/** Returns the "visual" position of the finger. This may e.g. be used
  * to tell if a certain finger is 'to the right' of (>) another finger.
  * E.g. left little = 1, left ring = 2, ... , right little = 10. */
-(NSUInteger) visualPosition;

@end
