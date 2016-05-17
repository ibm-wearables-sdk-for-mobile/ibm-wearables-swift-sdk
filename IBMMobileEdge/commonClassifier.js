"use strict";
var isDebug = false,
recognized,
gestureSensitivity = {},
DELAY = 2,
global = {};

global.gestures = [];
global.disabledGestures = [];
global.maxLength = global.maxLength || 0;
global.classifierHistory = [];

var debugMessage = function(message) {
    if(isDebug) debug(message);
}

var newSession = function() {
    global.classifierHistory = [];
}

var detectGesture = function(payload) {
    var resultGyroAcc = getJointGyroAccelDataClassify(payload);
    return slidingWindow(resultGyroAcc, global.gestures, global.maxLength);
}

var setGesturesSensitivity = function(newGesturesSensitivity) {
    gestureSensitivity = newGesturesSensitivity;
    recalcMaxLength();
}

var getSensitivity = function(gest) {
    var result = gest.defaultLogRatio;
    if(typeof gestureSensitivity[gest.gesture] !== 'undefined')
        result = gestureSensitivity[gest.gesture];
    debugMessage("result : " +  result);
    return result;
}

var removeGesture = function(name) {
    global.gestures.forEach(function(arr, i) {
                            if(global.gestures[i].gesture == name) {
                            global.gestures.splice(i,1);
                            }
                            });
    recalcMaxLength();
};

var enableGesture = function(name) {
    global.disabledGestures.forEach(function(arr, i) {
         if(global.disabledGestures[i].gesture == name) {
        	global.gestures.push(global.disabledGestures[i]);
         	global.disabledGestures.splice(i,1);
         }
         });
    recalcMaxLength();
};

var disableGesture = function(name) {
	 global.gestures.forEach(function(arr, i) {
         if(global.gestures[i].gesture == name) {
         	global.disabledGestures.push(global.gestures[i]);
         	global.gestures.splice(i,1);
         }
         });
    recalcMaxLength();
};
var recalcMaxLength = function(name) {
    var newMaxLength = 0;
    global.gestures.forEach(function(arr, i) {
                            newMaxLength = Math.max(newMaxLength, global.gestures[i].avgSeqLength || 0);
                            });
    global.maxLength = newMaxLength;
}

/*
 * Builds a sliding window with length of longest gesture
 */
var getJointGyroAccelDataClassify = function(msg) {
    var GyroAccelData = [];
    var countGyro = msg.gyroscope.length;
    var countAcc = msg.accelerometer.length;
    var GyroSum = msg.gyroscope.reduce(function(a, b) {
                                       return a + Math.abs(b[0]) + Math.abs(b[1]) + Math.abs(b[2])
                                       }, 0.0);
    var AccSum = msg.accelerometer.reduce(function(a, b) {
                                          return a + Math.abs(b[0]) + Math.abs(b[1]) + Math.abs(b[2])
                                          }, 0.0);
    var ratio = (countGyro*AccSum != 0) ? (countAcc*GyroSum)/(countGyro*AccSum) : 1;
    var min_length = Math.min(countGyro, countAcc);
    for (var i=0; i < min_length; i++) {
        msg.accelerometer[i][0] *= ratio;
        msg.accelerometer[i][1] *= ratio;
        msg.accelerometer[i][2] *= ratio;
        GyroAccelData[i] = msg.gyroscope[i].concat(msg.accelerometer[i]);
    }
    return GyroAccelData;
}

/*
 * Builds a sliding window with length of longest gesture
 */
var slidingWindow = function(payload, gestures, maxSeqLength) {
    var funcResult = {"detected" : false};
    for (var i=0; i<payload.length; i++) {
        if (global.classifierHistory.length < maxSeqLength) {
            global.classifierHistory.push(payload[i]);
        } else {
            global.classifierHistory.shift();
            global.classifierHistory.shift(); //sasha
            global.classifierHistory.shift(); //sasha - shift by 3 for sliding win
            global.classifierHistory.push(payload[i]);
            var newMsg = global.classifierHistory;
            var result = classify(newMsg, gestures);
            global.delay = global.delay || 0;
            if (result && result.detected === true && global.delay < new Date().getTime()) {
                global.delay = new Date().getTime() + (1000 * DELAY);
                funcResult = result;
            } else if (result && result.detected === false && funcResult && funcResult.detected == false) {
                funcResult = result;
            }
        }
    }
    return funcResult;
}

/*
 * Classify gesture
 */
var classify = function(msg, gestures) {
    var NUM_STATES = 6; //6
    var matches = new Array(gestures.length); // Default probability of each gesture
    var matchesNorm = new Array(gestures.length); // probability of each gesture
    var gestPercent = new Array(gestures.length); // recognition percentage of each gesture
    var sumGestures = 0.0; // sum of all gesture probabilities
    var sumgestPercent = 0.0;
    var dec = [];
    for (var i=0; i<gestures.length; i++) {
        dec[i] = 0;
        var sensitivity = getSensitivity(gestures[i]);
        if (!gestures[i].isSelected) continue; // check gesture is selected for classification
        var rawObservation = msg.slice(0,gestures[i].avgSeqLength);
        var a = gestures[i].transitions;
        var b = gestures[i].emissions;
        var codebook = gestures[i].codebook;
        var pi = [];
        pi[0] = 0.9;
        pi[1] = 0.1;
        for(var j=2; j<NUM_STATES; j++) {
            pi[j] = 0;
        }
        
        // create sequence based on gesture codebook
        var observation = [];

        for (var k=0; k<rawObservation.length; k++) {
            var dataPoint = rawObservation[k];
            // compute nearest neighbor (code) for the input data point
            var minDistance = Number.MAX_VALUE;
            var closestNeighbor = 1;
            for (var j in codebook) {
                var distanceSum = 0;
                for(var i2=0; i2<6; i2++)
                    distanceSum += Math.pow(codebook[j][i2] - dataPoint[i2], 2);
                var distance = Math.sqrt(distanceSum);
                if (distance < minDistance) {
                    minDistance = distance;
                    closestNeighbor = parseInt(j) + 1;
                }
            }
            observation.push(closestNeighbor);
        }
        
        
        // VA
        var V = new Array(NUM_STATES);
        var path = new Array(NUM_STATES);
        for (var j = 0; j < NUM_STATES; j++) {
            V[j] = new Array(observation.length);
            path[j] = new Array(observation.length);
        }
        
        for (var l = 0; l < V.length; l++) {
            V[l][0] = pi[l] * b[l][observation[0]-1];
        }
        
        for (var j = 1; j < observation.length; j++) {
            for (var k = 0; k < V.length; k++) {
                var ml = [0, null];
                for (var l = 0; l < NUM_STATES; l++) {
                    var calc = V[l][j-1] * a[l][k] * b[k][observation[j]-1];
                    if (calc > ml[0]) ml = [calc,l];
                }
                
                V[k][j] = ml[0];
                if (ml[1] != null) {
                    path[ml[1]][j] = k;
                    if (gestures[i].gesture == "up") {
                        debugMessage("ML0: " + 1/(-1*Math.log(ml[0])/gestures[i].avgSeqLength) + " ML1: " + ml[1] + " Path: " + k + " : " + j);
                    }
                }
            }
        }
        
        var ml = [0, null];
        for (var s = 0; s < NUM_STATES; s++) {
            var calc = V[s][observation.length - 1];
            if (calc > ml[0]) ml = [calc,s];
        }
        
        for (var s = 0; s < NUM_STATES; s++) {
            for (var o = 0; o < observation.length; o++) {
                if (path[s][o] == NUM_STATES - 1) {dec[i] = 1;}
            }
        }
        if (ml[1] != null) {
            debugMessage("ML0: " + 1/(-1*Math.log(ml[0])/gestures[i].avgSeqLength) + " ML1: " + ml[1]);
        }        
        
        // compute probability of observation (forward algorithm)
        /*
        var f = new Array(NUM_STATES);
        for (var j = 0; j < NUM_STATES; j++) {
            f[j] = new Array(observation.length);
        }
        for (var l = 0; l < f.length; l++) {
            if (!b[l]) console.warn(gestures[i]);
            f[l][0] = pi[l] * b[l][observation[0]-1];
        }
        for (var j = 1; j < observation.length; j++) {
            for (var k = 0; k < f.length; k++) {
                var sum = 0.0;
                for (var l = 0; l < NUM_STATES; l++) {
                    sum += f[l][j-1] * a[l][k];
                }
                f[k][j] = sum * b[k][observation[j]-1];
            }
        }
        
        // compute gesture's probability by summing probabilities of all states
        var prob = 0.0;
        for (var j = 0; j < f.length; j++) {
            prob += f[j][f[j].length - 1];
        }
        */
        
        var prob = ml[0];
        
        
        // add gesture's probability to global variables
        matches[i] = prob;
        matchesNorm[i] = (prob > 0) ? 1/(-1*Math.log(prob)/gestures[i].avgSeqLength) : 0;
        
        if (matchesNorm[i] > 0) {
            debugMessage(gestures[i].gesture + ": " + matchesNorm[i]);
        }
        sumGestures += matchesNorm[i];
        gestPercent[i] = Math.max(matchesNorm[i] - sensitivity/100,0);
        sumgestPercent += gestPercent[i];
    }
    var scoresInfo = [];
    //	old_recognized = recognized || -1;
    recognized = -1; // which gesture has been recognized
    var recogprob = Number.MIN_VALUE; // probability of this gesture
    var probgesture = 0;
    var probmodel = 0;
    for (var i=0; i<gestures.length; i++) {
        var tmpgesture = matchesNorm[i];
        var sensitivity = getSensitivity(gestures[i]);
        if (!gestures[i].isSelected) continue; // check gesture is selected for classification
        if(typeof matchesNorm[i] !== 'undefined') {
            scoresInfo.push({"name": gestures[i].gesture, "score": matchesNorm[i].toFixed(3), "sensitivity":  sensitivity.toFixed(3)});
            debugMessage(i + " : " + gestures[i].gesture + " : " + matchesNorm[i] + " sensitivity: " + sensitivity);
        }
        
        var tmpmodel = 1/sensitivity;
        //var tmpmodel = 1;
        if(dec[i]*((tmpmodel*tmpgesture)/sumGestures)>recogprob) {
            probgesture=tmpgesture;
            probmodel=tmpmodel;
            recogprob=((tmpmodel*tmpgesture)/sumGestures);
            recognized=i;
        }
    }
    debugMessage(recognized + " : " + dec + " : " + recogprob + " sensitivity: " + sumGestures);
    if (recognized > -1 && recogprob>0 && probmodel>0 && probgesture>0 && sumGestures >0) {
        var flag = true;
        
        var sensitivity = getSensitivity(gestures[recognized]);
        //if (matchesNorm[recognized] < sensitivity){flag = false;}
        //if (recognized == global.old_recognized){flag = false;}
        if (flag) {
            var jsonObj = {
                "detected" : true,
                "additionalInfo" : {
                recognized: gestures[recognized].gesture,
                score:  Math.round(100*gestPercent[recognized]/sumgestPercent),
                    others : ""
                }};
            //global.old_recognized = recognized;
            for (var i=0; i<gestures.length; i++) {
                //if (i == recognized){continue;}
                jsonObj.additionalInfo.others += gestures[i].gesture + ", score: " + Math.round(100*gestPercent[i]/sumgestPercent) + "%\n";
            }
            return jsonObj;
        }
    }
    var result = {"detected" : false};
    if (scoresInfo.length > 0) {
        result.additionalInfo = {
        others: scoresInfo
        };
    }
    return result;
}