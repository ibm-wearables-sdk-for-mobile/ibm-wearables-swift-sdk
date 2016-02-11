"use strict";
//var fs = require('fs');
var isDebug = false;

var global = {};
global.gestures = [];
global.maxLength = 0;
var DataGyro = [];
var DataAcc = [];
//var maxLength = 70; // TODO: ashraf maxLength || 39;
global.classifierHistory =  [];
var gestureSensitivity = {};

//global.context = global.context || {};
var notDetected = {
    "detected" : false
};

var notDetected2 = {
    "detected" : false,
    "delayed": true
};
var notDetected3 = {
    "detected" : false,
    "notEnough": true
};
var DELAY = 2; // TODO: ashraf -- delay 2 seconds between detected gestures
/**------------------------------------ CLASSIFICATION ------------------------------------------------**/


//for (var i = 0; i < gestures.length; i++) {
//	//if (!docs.rows[i].doc.gesture) continue;
//	if (gestures[i].avgSeqLength > maxLength) maxLength = gestures[i].avgSeqLength;
//	//gestures.push(docs.rows[i].doc);
//}

var rate = 3;
var testGesture = function(payload) {
    for(var i=0; i+rate-1<accdata.length; i+=rate) {
        var o = ((detectGesture({
                                "accelerometer":accdata.slice(i,i+rate-1),
                                "gyroscope":gyrodata.slice(i,i+rate-1)
                                })));
        if (o["additionalInfo"]) return o;
    }
}

// TODO: ashraf - remove
var detectGesture = function(payload) {
    var resultGyroAcc = getJointGyroAccelDataClassify(payload);
    //console.log('resultGyroAcc : ' + resultGyroAcc);
    var result = slidingWindow(resultGyroAcc, global.gestures, global.maxLength);
    if(result)
        return result;
    else
        return notDetected3;
}

var setGesturesSensitivity = function(newGesturesSensitivity) {
    gestureSensitivity = newGesturesSensitivity;
}


/*
var removeGesture = function(name) {
    global.gestures.forEach(function(arr, i) {
                            if(isDebug)
                            debug(global.gestures[i].gesture);
                            if(global.gestures[i].gesture == name) {
                            delete global.gestures[i];
                            if(isDebug)
                            debug("gesture " + name + "was removed");
                            }
                            });
    recalcMaxLength();
};
*/

var removeGesture = function(name) {
    global.gestures.forEach(function(arr, i) {
                            if(global.gestures[i].gesture == name) {
                            global.gestures.splice(i,1);
                            }
                            });
    recalcMaxLength();
};




var recalcMaxLength = function(name) {
    var newMaxLength = 0;
    global.gestures.forEach(function(arr, i) {
                            var avgSeqLength = gestures[i].avgSeqLength || 0;
                            newMaxLength = Math.max(newMaxLength, avgSeqLength);
                            });
    global.maxLength = newMaxLength;
}

/*
 * Builds a sliding window with length of longest gesture
 */

var getJointGyroAccelDataClassify = function(msg) {
    var GyroAccelData = [];
    //var DataAccNorm = [];
    var GyroSum = 0;
    var AccSum = 0;
    var countGyro = 0;
    var countAcc = 0;
    for (var dp=0; dp<msg.gyroscope.length; dp++) { //add counter to calculate the same number of samples for Gyro and Accel
        var DataSplit = msg.gyroscope[dp];
        DataGyro.push([DataSplit[0], DataSplit[1], DataSplit[2]]);
        GyroSum = GyroSum + Math.abs(DataSplit[0]) + Math.abs(DataSplit[1]) + Math.abs(DataSplit[2]);
        countGyro++;
    }
    for (var dp=0; dp<msg.accelerometer.length; dp++) { //add counter to calculate the same number of samples for Gyro and Accel
        var DataSplit = msg.accelerometer[dp];
        DataAcc.push([DataSplit[0], DataSplit[1], DataSplit[2]]);
        AccSum = AccSum + Math.abs(DataSplit[0]) + Math.abs(DataSplit[1]) + Math.abs(DataSplit[2]);
        countAcc++;
    }
    
    //	var DataGyro = msg.gyroscope.map(function(obj){
    //		   GyroSum += Math.abs(obj[0]) + Math.abs(obj[1]) + Math.abs(obj[2]);
    //		   countGyro++;
    //		   return obj.map(function (str) {
    //			   return str.trim();
    //		   });
    //	});
    //	console.log('DataGyro : ' + JSON.stringify(DataGyro));
    //	var DataAcc = msg.accelerometer.map(function(obj){
    //		   AccSum += Math.abs(obj[0]) + Math.abs(obj[1]) + Math.abs(obj[2]);
    //		   countAcc++;
    //		   return obj.map(function (str) {
    //			   return str.trim();
    //		   });
    //	});
    
    //console.log('DataAcc.length: ' + DataAcc.length);
    
    if (countGyro*AccSum != 0){
        var ratio = (countAcc*GyroSum)/(countGyro*AccSum);
    }
    else {
        var ratio = 1;
    }
    //console.log("AccSum: " + AccSum);
    //console.log("ratio: " + ratio);
    var min_length = Math.min(DataGyro.length,DataAcc.length);
    var max_length = Math.max(DataGyro.length,DataAcc.length);
    if (min_length == DataGyro.length) {
        var GyroFlag = true;
        var AccFlag = false;
    }else {
        var AccFlag = true;
        var GyroFlag = false;
    }
    //console.log("MinLen: " + min_length);
    for (var i=0; i < min_length; i++) {
        DataAcc[i][0] = ratio*DataAcc[i][0] +'';
        DataAcc[i][1] = ratio*DataAcc[i][1] +'';
        DataAcc[i][2] = ratio*DataAcc[i][2] +'';
        //console.log(DataGyro[i].concat(DataAcc[i]));
        GyroAccelData[i] = DataGyro[i].concat(DataAcc[i]);
    }
    //console.log(GyroAccelData);
    var NextStepData = []; // TODO: ashraf
    if (AccFlag == true) {
        for (var j=0;j<max_length-min_length;j++) {
            NextStepData[j] = DataGyro[min_length+j];
        }
        DataGyro = [];
        DataAcc = [];
        DataGyro = NextStepData;
    }else {
        for (j=0;j<max_length-min_length;j++) {
            NextStepData[j] = DataAcc[min_length+j];
        }
        DataGyro = [];
        DataAcc = [];
        DataAcc = NextStepData;
    }
    return GyroAccelData;
}

var counter = 0;

var recognized;
var counter=0;
// var logString = "";

/*
 * Builds a sliding window with length of longest gesture
 */

var slidingWindow = function(payload, gestures, maxSeqLength) {
    var funcResult = notDetected;
    for (var i=0; i<payload.length; i++) {
        
        // global.classifierHistory = global.classifierHistory || [];
        //console.log("payload.length : " + payload[i]);
        if (global.classifierHistory.length < maxSeqLength) {
            global.classifierHistory.push(payload[i]);
            // shift window
        } else {
            
            global.classifierHistory.shift();
            global.classifierHistory.push(payload[i]);
            
            var newMsg = global.classifierHistory;
            var result = classify(newMsg,gestures);
            global.delay = global.delay || 0;
            if (result && result.detected === true && global.delay < new Date().getTime()) {
                global.delay = new Date().getTime() + (1000 * DELAY);
                funcResult = result;
            } else if (result && result.detected === false && funcResult && funcResult.detected == false) {
                funcResult = result;
                // return result;
            } else {
                // return notDetected2;
            }
        }
    }
    return funcResult;
    
}


/*
 * Classify gesture
 */
var classify = function(msg, gestures) {
    // constants
    var NUM_STATES = 6; //sasha
    // global variables
    var matches = new Array(gestures.length); // Default probability of each gesture
    var matchesNorm = new Array(gestures.length); // probability of each gesture
    var gestPercent = new Array(gestures.length); // recognition percentage of each gesture
    var sumGestures = 0.0; // sum of all gesture probabilities
    var sumgestPercent = 0.0;
    for (var i=0; i<gestures.length; i++) {
        if (!gestures[i].isSelected) continue; // check gesture is selected for classification
        var rawObservation = msg.slice(0,gestures[i].avgSeqLength); //sasha
        //console.log('rawObservation : ' + rawObservation);
        var a = gestures[i].transitions;
        var b = gestures[i].emissions;
        var codebook = gestures[i].codebook;
        var pi = [];
        pi[0] = 0.9; //if initial state is a little bit different ?? sasha. The distribution should be used.
        pi[1] = 0.1;
        //pi[NUM_STATES-1] = 0.1;
        for(var j=2; j<NUM_STATES; j++) {
            pi[j] = 0;
        }
        
        // create sequence based on gesture codebook
        var observation = [];
        
        for (var k=0; k<rawObservation.length; k++) {
            //sasha var dataPoint = rawObservation[k].split(",");
            var dataPoint = rawObservation[k]; //sasha
            
            // compute nearest neighbor (code) for the input data point
            var minDistance = Number.MAX_VALUE;
            var closestNeighbor = 1;
            for (var j in codebook) {
                var delta_x = codebook[j][0] - parseFloat(dataPoint[0]); //sasha
                var delta_y = codebook[j][1] - parseFloat(dataPoint[1]); //sasha
                var delta_z = codebook[j][2] - parseFloat(dataPoint[2]); //sasha
                var delta_xa = codebook[j][3] - parseFloat(dataPoint[3]); //sasha
                var delta_ya = codebook[j][4] - parseFloat(dataPoint[4]); //sasha
                var delta_za = codebook[j][5] - parseFloat(dataPoint[5]); //sasha
                
                var distance = Math.sqrt( delta_x*delta_x + delta_y*delta_y + delta_z*delta_z + delta_xa*delta_xa + delta_ya*delta_ya + delta_za*delta_za );
                
                if (distance < minDistance) {
                    minDistance = distance;
                    closestNeighbor = parseInt(j) + 1;
                }
            }
            observation.push(closestNeighbor);
            // logString += "Recog Observ: " + closestNeighbor +"\n";
        }
        
        
        // compute probability of observation (forward algorithm)
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
        
        // add gesture's probability to global variables
        matches[i] = prob;
        //console.log("Matches[i] : " + prob);
        if (prob > 0) {
            
            matchesNorm[i] = 1/(-1*Math.log(prob)/gestures[i].avgSeqLength);
            //console.log("MatchesNorm[i] : " + matchesNorm[i]);
        }else
        {
            matchesNorm[i]=0;
        }
        if (matchesNorm[i] > 0) {
            if(isDebug)
                debug(gestures[i].gesture + ": " + matchesNorm[i]);
        }
        sumGestures += matchesNorm[i]; //sasha
        var sensitivity = gestureSensitivity[gestures[i].gesture] || gestures[i].defaultLogRatio;
        if(isDebug)
            debug("sensitivity: " + sensitivity);
        gestPercent[i] = Math.max(matchesNorm[i] - sensitivity/100,0);
        sumgestPercent += gestPercent[i];
    }
    
    
    var additionalInfo = "";
    var scoresInfo = [];
    //	old_recognized = recognized || -1;
    recognized = -1; // which gesture has been recognized
    var recogprob = Number.MIN_VALUE; // probability of this gesture
    var probgesture = 0;
    var probmodel = 0;
    for (var i=0; i<gestures.length; i++) {
        var tmpgesture = matchesNorm[i];
        var sensitivity = gestureSensitivity[gestures[i].gesture] || gestures[i].defaultLogRatio;
        
        //Cirill change
        //if (matchesNorm[i] > 0) {
        
        
        
        
        additionalInfo = additionalInfo + gestures[i].gesture + ", score: " + matchesNorm[i].toFixed(3) + " threshold:" + sensitivity.toFixed(3) + "\n";
        
        scoresInfo.push({"name": gestures[i].gesture, "score": matchesNorm[i].toFixed(3), "sensitivity":  sensitivity.toFixed(3)});
        
        //additionalInfo = additionalInfo + gestures[i].gesture + ", score: " + matchesNorm[i].toFixed(3) + " sen:" + sensitivity.toFixed(3) + " max: "+ global.maxLength + " gl: "+ gestures.length + "\n";
            if(isDebug)
                debug(i + " : " + gestures[i].gesture + " : " + matchesNorm[i] + " sensitivity: " + sensitivity);
        //}
        //var tmpmodel = gestures[i].defaultProbability;
        
        var tmpmodel = 1/sensitivity; //sasha
        if(((tmpmodel*tmpgesture)/sumGestures)>recogprob) {
            probgesture=tmpgesture;
            probmodel=tmpmodel;
            recogprob=((tmpmodel*tmpgesture)/sumGestures);
            recognized=i;
            //console.log("Recog Observ: " + recognized + "Ratio: " + matchesNorm[recognized]);
        }
        
    }
    
    // logString += "Recognized: " + recognized +"\n";
    
    //	fs.writeFile("D:\\gesture\\states.txt", logString, function(err) {
    //	    if(err) {
    //	        return console.log(err);
    //	    }
    //
    //	    //console.log("The file was saved!");
    //	});
    
    
    if (recogprob>0 && probmodel>0 && probgesture>0 && sumGestures >0) {
        
        // check if probability passes predefined threshold
        var flag = true;
        
        //console.log("Recog Observ: " + recognized + "Ratio: " + matchesNorm[recognized] + "Flag: " + flag);
        var sensitivity = gestureSensitivity[gestures[recognized].gesture] ||  gestures[recognized].defaultLogRatio;
        if (matchesNorm[recognized] < sensitivity){flag = false;}
        
        if (recognized == global.old_recognized) flag = false;
        
        if (flag) {
            //lastprob = recogprob;
            //global.old_recognized = recognized;
            
            var jsonObj = {
                "detected" : true,
                "additionalInfo" : {
                recognized: gestures[recognized].gesture,
                score:  Math.round(100*gestPercent[recognized]/sumgestPercent),
                    others : ""
                }};
            
            
            var others = "";
            for (var i=0; i<gestures.length; i++) {
                
                if (i == recognized){
                    continue;
                }
                
                others += gestures[i].gesture + ", score: " + Math.round(100*gestPercent[i]/sumgestPercent) + "%\n";
                
                //                jsonObj.additionalInfo.others.push(
                //                                                   "gesture: " + gestures[i].gesture +
                //                                                   ", score:" + Math.round(100*gestPercent[i]/sumgestPercent)
                //                                                   );
            }
            
            jsonObj.additionalInfo.others = others;
            
            //debug(JSON.stringify(jsonObj));
            return jsonObj;
        }
    }
    var result = notDetected;
    if (additionalInfo) {
        result.additionalInfo = {};
        result.additionalInfo.others = scoresInfo;
    }
    return result;
}
