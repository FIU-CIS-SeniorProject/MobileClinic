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
 * $Date: 2012-04-20 11:34:15 +0200 (fr, 20 apr 2012) $ $Rev: 14636 $ 
 *
 */
#import <UIKit/UIKit.h>
#import "PBBiometryFinger.h"
#import "PBBiometryTemplate.h"

// Protocol for a biometric database. The database is responsible
// for storing and retrieving fingerprint templates.
@protocol PBBiometryDatabase <NSObject>
@required

/** Inserts a template of the specified finger in the database. If a template 
  * for the finger already exists it will be overwritten by the new template.
  *
  * @param[in] template_ is the template to be inserted in the database. The 
  *     database will not inherite the ownership of the template so the caller
  *     must still delete the template. The database implementation chooses if
  *     it makes a copy of the template or just retains it.
  * @param[in] finger is the finger associated with the template. Regarding
  *     ownership the same goes for the finger as for the template, see above.
  * 
  * @return YES if the template was inserted in the database, otherwise NO. 
  */
-(BOOL) insertTemplate: (PBBiometryTemplate*) template_
             forFinger: (PBBiometryFinger*) finger;

/** Finds a template belonging to the specified finger in the database and 
  * returns it.
  *
  * @param[in] finger is the finger associated with the template.
  *
  * @return the found template or nil if no template existed for the specified
  *     finger. 
  */
-(PBBiometryTemplate*) getTemplateForFinger: (PBBiometryFinger*) finger;

/** Deletes a previously enrolled template belonging to the specified
  * finger from the database. 
  *
  * @param[in] finger is the finger associated with the template.
  *
  * @return YES if the template was deleted, otherwise NO. 
  */
-(BOOL) deleteTemplateForFinger: (PBBiometryFinger*) finger;

/** Returns YES if a template belonging to the specified finger is enrolled
  * in the database. 
  *
  * @param[in] finger is the finger associated with the template.
  *
  * @return YES if there is a template enrolled for the specified finger, 
  *     otherwise NO. 
  */
-(BOOL) templateIsEnrolledForFinger: (PBBiometryFinger*)finger;

/** Returns an array of the enrolled fingers in the database. 
  *
  * @return an array of the enrolled fingers.
  */
-(NSArray*) getEnrolledFingers;
@end