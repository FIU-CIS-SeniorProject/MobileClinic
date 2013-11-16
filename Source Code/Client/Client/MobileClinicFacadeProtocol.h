// The MIT License (MIT)
//
// Copyright (c) 2013 Florida International University
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
//
//  MobileClinicFacadeProtocol.h
//  Mobile Clinic
//
//  Created by Michael Montaque on 3/1/13.
//
#define OPEN_VISITS_PATIENT @"Open Visit"

#import "PatientObjectProtocol.h"
#import "VisitationObjectProtocol.h"
#import "PrescriptionObjectProtocol.h"
#import "MedicationObjectProtocol.h"
#import <Foundation/Foundation.h>

/**
 * WorkFLow
 *	- Triage:
 *		Note 1: Before editing a visitation record you need to lock the record @see updateVisitRecord and @see LockVisit.
 *		Note 2: Currently you do not need to lock patients becuase of the unique workflow it is moot to do so.
 *		Note 3: if an object is already locked by another user then you will have to allow the user to query for the object until it becomes unlocked.
 *		1. You can always search without the need to lock. Only when an object can be modified should the locks be taken into consideration.
 *		2. If you are working with a patient and modifying any of their records make sure you pass the appropriate Bool attribute to lock the patient.(See Note 2 & 3)
 *		3. All(Most) the objects return from the Block response of the methods will be updated values take from the server. So if you tried to lock the object under your userprofile but it was already locked by another user, your returned object from the server will reflect the other user's information and changes. This is to help mitigate RACE conditions
 */
typedef void (^MobileClinicCommandResponse)(NSDictionary* object, NSError* error);
typedef void (^MobileClinicSearchResponse)(NSArray* allObjectsFromSearch, NSError* error);
@protocol MobileClinicFacadeProtocol <NSObject>

@required
/**
 * This method creates a LOCAL patient. This patient will not be synced to the server immediately.
 * This on completion this method will return the object it saves.
 * @param patietnInfo The patient's information in a dictionary form
 */
-(void) createAndCheckInPatient:(NSDictionary*)patientInfo onCompletion:(MobileClinicCommandResponse)Response;

/**
 * Locates the patient by First and/or Family name. This method fetches the query from the server and caches it to the device. Then it queries the cache to return a complete list objects that matches the criteria
 * @param firstname the firstname of the patient
 * @param lastname the family name of the patient
 */
-(void) findPatientWithFirstName:(NSString*)firstname orLastName:(NSString*)lastname onCompletion:(MobileClinicSearchResponse)Response;

/**
 * Adds a new visitation record for the given patient. This method will not lock the patient but. This method is meant to be called at the end of the triage workflow.
 * This method will store the visitation object locally and on the server.
 * @response Block call that, on completion, will return the visitation object
 * @param visitInfo The visitation information
 * @param patientInfo The patient to associate the visitation to
 */
-(void)addNewVisit:(NSDictionary *)visitInfo ForCurrentPatient:(NSDictionary *)patientInfo shouldCheckOut:(BOOL)checkout onCompletion:(MobileClinicCommandResponse)Response;

/**
 * This will update the give visit in local and remote database.
 * If the visit is locked by another user the server will not update the visit but will throw an error message.
 * You should successfully lock the object before you try and change information.
 * This method has the power to lock the object, but the object must not be in user by another user.
 * This method also allows you to open and close a visit, which is determined by the Bool ShouldCloseVisit.
 * This method will returned the updated value to you through the block call.
 * @param visitRecord the record you want to lock
 * @param unlock TRUE means that the object will be unlocked when the update is completed FALSE will leave the object locked after the update;
 * @param closeVisit determines whether or not the patient has completed his/her visit
 */
-(void) updateVisitRecord:(NSDictionary*)visitRecord andShouldUnlock:(BOOL)unlock andShouldCloseVisit:(BOOL)closeVisit onCompletion:(MobileClinicCommandResponse)Response;
/**
 * Using information from the given patient, this method will find all visits related to them.
 * @param patientInfo the patient you want the visits from.
 */
-(void) findAllVisitsForCurrentPatient:(NSDictionary*)patientInfo AndOnCompletion:(MobileClinicSearchResponse)Response;

/**
 * This method will return all open visits.
 * When a Visit is created in triage it is automatically deemed Open, which means that it should be tracked by the system till the patien leaves.
 * The information will be synced from the server and cached to the local. The returned visits will be an accumulation of both the local and client.
 * This is great to help them narrow down who is next and how many is left.
 * If the user selects the visit from the queue it MUST BE LOCKED USING THE @see UpdateVisitRecord or @see LockVisit methods
 * The block returns an array of Visitaion Dictionaries;
 * The dictionaries also hold the corresponing Patient Dictionary the belongs to that visit
 which can be retrieved by using the Definition OPEN_VISITS_PATIENT
 */
-(void) findAllOpenVisitsAndOnCompletion:(MobileClinicSearchResponse)Response;

/**
 * This method will update the patient's Information.
 * If the patient doesn't exist then it will create one
 * If the lock is True then the system will attempt to lock the patient
 * @param patientInfo the patient you want to save locally and to the server
 * @param lock If True then the system will attempt to lock the patient
 */
-(void) updateCurrentPatient:(NSDictionary*)patientInfo AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response;

/**
 *  Locates on the server and client all prescriptions for a given Visit
 *  @param visit the Visitation Dictionary that you want to search for all prescriptions from
 */
-(void) findAllPrescriptionForCurrentVisit:(NSDictionary*)visit AndOnCompletion:(MobileClinicSearchResponse)Response;

/**
 * Creates a new patient and associates it to a given visit.
 * Can also lock the prescription using the AndLockVisit boolean variable
 * The block will return an error or the updated object.
 * @param Rx the prescription dictionary that must be sent
 */
-(void) addNewPrescription:(NSDictionary*)Rx ForCurrentVisit:(NSDictionary*)visit AndlockVisit:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response;

/**
 * Updates existing medication or creates new ones if it doesn't exist
 * Set the Bool variable to true to lock the prescription if necessary
 * The block variable will return updated versions of the object or error messages if there was a problem
 * @param Rx the Prescription dicitionary file to update
 */
-(void) updatePrescription:(NSDictionary*)Rx AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response;
-(void) findAllMedication:(NSDictionary*)visit AndOnCompletion:(MobileClinicSearchResponse)Response;
-(void) updateMedication:(NSDictionary*)Rx AndShouldLock:(BOOL)lock onCompletion:(MobileClinicCommandResponse)Response;

/**
 * This will mark the patient and their visit as closed.
 */
-(void)checkoutVisit:(NSDictionary*)visit forPatient:(NSDictionary*)patient AndWillUlockOnCompletion:(MobileClinicCommandResponse)Response;
@end