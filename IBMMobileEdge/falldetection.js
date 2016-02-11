/*
 *   © Copyright 2015 IBM Corp.
 *
 *   Licensed under the Mobile Edge iOS Framework License (the "License");
 *   you may not use this file except in compliance with the License. You may find
 *   a copy of the license in the license.txt file in this package.
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
*/

var context = context || [];
var notDetected = {
		"detected" : false
};

var detect = function(payload){
	return hasFallenOrFreeFallenShield(payload);
};

var fallDetectionPreProcessing = function(payload){
	if(payload.accelerometer) {
		var newPayload = {};
		newPayload.d = {};
		newPayload.d.accelX = payload.accelerometer.x;
		newPayload.d.accelY = payload.accelerometer.y;
		newPayload.d.accelZ = payload.accelerometer.z;
		newPayload.deviceUUID = 0; 
		return newPayload;
	}
};

var fallDetectionSafelet = function(payload){ 
	var BUFFER_SIZE = 10;

	context.fallHistory = context.fallHistory || [];
	context.fallHistory[payload.deviceUUID] = context.fallHistory[payload.deviceUUID] || [];

	if (context.fallHistory[payload.deviceUUID].length < BUFFER_SIZE){
		context.fallHistory[payload.deviceUUID].push(payload);
		return null; // stop proccessing if we do not have enough data
	} else {
		context.fallHistory[payload.deviceUUID].shift();
		context.fallHistory[payload.deviceUUID].push(payload);
	}
	
	var listXs = [];
	var listYs = [];
	var listZs = [];
	var length = context.fallHistory[payload.deviceUUID].length;
	for(var i = 0; i < length; i++){
		listXs.push(context.fallHistory[payload.deviceUUID][i].d.accelX);
		listYs.push(context.fallHistory[payload.deviceUUID][i].d.accelY);
		listZs.push(context.fallHistory[payload.deviceUUID][i].d.accelZ);
	}

	var acceleration = [];

	// some constants
	var free_fall_bound=0.3;  // in g units

	var alert_bound = 6.5; // based on training data

	var num_observations=length;
	for (i=0; i<num_observations; i++){
		acceleration.push(Math.sqrt(Math.pow(listXs[i],2)+Math.pow(listYs[i],2)+Math.pow(listZs[i],2)));  
	}

	var counter = 0;
	for (i=0; i<acceleration.length ; i++){
		if (acceleration[i]<free_fall_bound){
			counter++;
		} else {
			counter=0;
		}
	}

	return {d: {freeFallLength: counter}};
};

var hasFallenOrFreeFallenShield = function(payload) {

	context.previousFreeFallLength = context.previousFreeFallLength || 0;

	var postProcessedPayload = fallDetectionPreProcessing(payload);
	var safeletValue = fallDetectionSafelet(postProcessedPayload);
	if (safeletValue) {
		var freeFallLength = safeletValue.d.freeFallLength;		
		var message = null;	

		// // Shield condition
		if (context.previousFreeFallLength > freeFallLength){
			freeFallLength = context.previousFreeFallLength;
			context.previousFreeFallLength = 0;
			if (freeFallLength >= 6)
				message = 'High jump was detected';
			else if (freeFallLength >= 2 && freeFallLength <= 5){
				message = 'Fall was detected';
			}

			context.delayHasFallenOrFreeFallenShieldTill = context.delayHasFallenOrFreeFallenShieldTill || 0;
			if (message != null && context.delayHasFallenOrFreeFallenShieldTill < new Date().getTime()) {
				context.delayHasFallenOrFreeFallenShieldTill = new Date().getTime() + (1 * 1);
				return{
					"detected" : true,
					"additionalInfo" : {
						"message" : message
					}
				}
			} else {
				return notDetected;
			}
		} else {
			context.previousFreeFallLength = freeFallLength;
			return notDetected;
		}
	} else {
		return notDetected;
	}

};

exports.detect = detect;