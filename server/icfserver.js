/**
 * 
 * author: Groeller Patrick, Kopf Helmut, Koller Christian
 * version: 1.0
 * date: 20160112
 * 
 * */
var request = require('request');
var ical = require('ical.js');
var express = require('express');
var querystring = require('querystring')
var bodyParser = require('body-parser');
var schedule = require('node-schedule');
var TimeTableUnit = require('./timeTableUnit.js');
var Voting = require('./voting.js');
var app = express();

//Lets define a port we want to listen to
const PORT=7777;
const BREAK="break";
const SPEED = "speed";
const CONTENT = "content";

var trackingConnectionMultiMap = {};
var userToLecturerMap = {};

app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies



/**
 *  Scheduled Job which runs every 5 minutes and removes old connections from the 'trackingConnectionMultiMap' 
 *  and also deletes the token entry in the 'userToLecturerMap'
 * */
schedule.scheduleJob('*/5 * * * *', function(){
	console.log('Start invalidating old connections.');
	var currentdate = new Date();
	var hh = currentdate.getHours().toString();
	var mm = currentdate.getMinutes().toString();
	var ss = currentdate.getSeconds().toString();

	var currentTime = (hh[1]?hh:"0"+hh[0]) +":"+ (mm[1]?mm:"0"+mm[0]) + ":"+  (ss[1]?ss:"0"+ss[0]); // padding
	console.log(currentTime);
	
	for (var key in trackingConnectionMultiMap) {
		if (trackingConnectionMultiMap.hasOwnProperty(key)) {
			console.log("oldDate: "+ trackingConnectionMultiMap[key].endOfCourse  + " currentTime: " +currentTime);
			if(trackingConnectionMultiMap[key].endOfCourse < currentTime){
				var userConnectionsToInvalidate = trackingConnectionMultiMap[key].connections;
				for (var token in userConnectionsToInvalidate) {
					if(userToLecturerMap[token].endOfCourse < currentTime){
						console.log("Before deleting from lecturer connection-map: " + JSON.stringify(userConnectionsToInvalidate));
						console.log("Before deleting from user to lecturer-map: " + JSON.stringify(userToLecturerMap));
						console.log("Try to delete user connection with token: " + token);
						delete userConnectionsToInvalidate[token];
						delete userToLecturerMap[token];
						console.log("After deleting from lecturer connection-map: " + JSON.stringify(userConnectionsToInvalidate));
						console.log("After deleting from user to lecturer-map: " + JSON.stringify(userToLecturerMap));
					}	
				}
			}
		}
	}
	console.log('Finished with invalidating of old connections.');
 });


var server = app.listen(PORT, function () {

  var host = server.address().address
  var port = server.address().port

  console.log("ICF Server listening at http://%s:%s", host, port)

});

app.get('/courses', function (req, res) {
	
	var processTimetableCallback = function(error, resp, body) {
		
		if (!error && res.statusCode == 200) {
			//console.log(body) 
			var courseArray=getWebCalTimeTableUnits(body, qsGroup);
			
			//console.log(JSON.stringify(courseArray));
			res.setHeader('Content-Type', 'application/json');
			res.send(JSON.stringify(courseArray), null, 3);
		}
	}

	console.log("Incoming Request with Parameters:" + JSON.stringify(req.query));
	var qsGroup = req.query.group;
	var qsStudy = req.query.study;
	var qsYear = req.query.year;
	
	if ( qsGroup == null || qsStudy == null || qsYear ==null){
		return createHttp400Response(res);
	}
	
	// send request to alamaty to get courses
	var buildParameter = querystring.stringify({'studiengang' : qsStudy, 'jahr':qsYear, 'datum' : getDateOfTodayWithFormatYYYYMMDD()},"+", ":");
	request({
		url : 'http://almaty.fh-joanneum.at/stundenplan/search.php',
		method : "GET",
		qs: { q : buildParameter }
		},processTimetableCallback);

	res.status(200);
	return res;
})


app.post('/vote', function (req, res) {	
	console.log('Incoming POST Params: ' + JSON.stringify(req.body));
	paramToken = req.body.token;
	paramLecturer = req.body.lecturer;
	paramTime = req.body.time;
	paramBreak = parseInt(req.body[BREAK]);
	paramContent = parseInt(req.body[CONTENT]);
	paramSpeed = parseInt(req.body[SPEED]);

	
	if(paramToken == null || paramLecturer == null || paramBreak == null || paramSpeed == null || paramContent== null){
		return createHttp400Response(res);
	}
	
	console.log("Checking if " + paramLecturer + " exists");
	console.log("Connection Multimap: " + JSON.stringify(trackingConnectionMultiMap));
	console.log("User-Lecturer Map: " + JSON.stringify(userToLecturerMap));
	
	var assignedLecturer;
	var hasUserSwitchedLecturer = false;
	if(userToLecturerMap.hasOwnProperty(paramToken)){
		assignedLecturer = userToLecturerMap[paramToken].lecturer;
		if(assignedLecturer && assignedLecturer != paramLecturer){
			console.log("Reassigning lecturer of user: " + paramToken );
			userToLecturerMap[paramToken].lecturer = paramLecturer;
			hasUserSwitchedLecturer = true;
		}
	}
	
	var voting = new Voting(paramSpeed, paramContent,paramBreak);
	
	if(!trackingConnectionMultiMap.hasOwnProperty(paramLecturer)){
		console.log("No connections for: " + paramLecturer + " exists");
		trackingConnectionMultiMap[paramLecturer] = {};
		trackingConnectionMultiMap[paramLecturer].connections={};
	}else{
		console.log("Some connections for: " + paramLecturer + " exists");
	}
	
	removeUserConnectionFromLecturer(hasUserSwitchedLecturer,assignedLecturer, paramToken);
	trackingConnectionMultiMap[paramLecturer].endOfCourse = paramTime;
	trackingConnectionMultiMap[paramLecturer].connections[paramToken] = voting;
	userToLecturerMap[paramToken]={};
	userToLecturerMap[paramToken].lecturer = paramLecturer;
	userToLecturerMap[paramToken].endOfCourse = paramTime;

	res.status(200).send('Done!');
	return res;
})

app.get('/feedback', function (req, res) {
	console.log("Incoming Request with Parameters:" + JSON.stringify(req.query));
	var qsLecturer = req.query.lecturer;
	
	if ( qsLecturer == null) {
		return createHttp400Response(res);
	}
	console.log("Actual connections of " + qsLecturer +": " + JSON.stringify(trackingConnectionMultiMap[qsLecturer]))
	result = getFeedbackResult(qsLecturer);
	res.setHeader('Content-Type', 'application/json');
	res.status(200).send(JSON.stringify(result));
	return res;
	
})

/**
 *  returns a Javascript object which contains the number of connected users for a lecturer and the average voting values
 * */
function getFeedbackResult(qsLecturer){
	var voting;
	var cntUsers = 0;
	if(trackingConnectionMultiMap.hasOwnProperty(qsLecturer)){
		var connections = trackingConnectionMultiMap[paramLecturer].connections;
		var speedFactor = 0;
		var contentFactor = 0;
		var breakFactor = 0;
		for (var key in connections) {
			if (connections.hasOwnProperty(key)) {
				console.log(key + " -> " + JSON.stringify(connections[key]));
				speedFactor += connections[key][SPEED];
				contentFactor += connections[key][CONTENT];
				breakFactor += connections[key]["breakProp"];
				cntUsers++;
			}
		}
		var speed = speedFactor / cntUsers;
		var content = contentFactor / cntUsers;
		var breakProp = breakFactor / cntUsers;
		
		voting = new Voting(speed,content,breakProp);
	}else{
		//default settings
		voting = new Voting(3,3,3);
	}
	var result = {
			connectedUsers : cntUsers,
			voting: voting
	}
	return result;	
}


/**
 *  removes a usertoken from the connections of a former lecturer if the 'hasUserSwitchedLecturer' parameter is set to 'true'
 * */
function removeUserConnectionFromLecturer(hasUserSwitchedLecturer, assignedLecturer, token){
	if(hasUserSwitchedLecturer){
		//remove from connection map
		console.log("Tracking: "  + JSON.stringify(trackingConnectionMultiMap));
		var connectionsOfFormerLecturer = trackingConnectionMultiMap[assignedLecturer].connections;
		console.log("Connections of former Lecturer: "  + JSON.stringify(connectionsOfFormerLecturer));
		delete connectionsOfFormerLecturer[token];
		console.log("Connections of former Lecturer after deleting: "  + JSON.stringify(connectionsOfFormerLecturer));
	}	
}

/**
 *  returns a response with status code 400
 * */
function createHttp400Response(res){ 
	res.setHeader('Content-Type', 'application/json');
	res.status(400).send('Bad Request!');
	return res;
}

/**
 * returns the current date as string with the format YYYYMMDD
 * */
function getDateOfTodayWithFormatYYYYMMDD() {
	var today = new Date();
	var yyyy = today.getFullYear().toString();
	var mm = (today.getMonth()+1).toString(); // getMonth() is zero-based
	var dd  = today.getDate().toString();
	return '20160109'; // for testing only
	//return yyyy + (mm[1]?mm:"0"+mm[0]) + (dd[1]?dd:"0"+dd[0]); // padding
 };
 
 /**
  * parses the body of the Almaty-Request which is in webCal format and 
  * returns all timetable units of the appropriate group and courses without a group label.
  * */
function getWebCalTimeTableUnits(body, qsGroup){
	var jcalData = ICAL.parse(body);					
	var comp = new ICAL.Component(jcalData);
	
	var courseArray=[];
	var subComponents = comp.getAllSubcomponents("vevent");
	for(var i = 0; i < subComponents.length; i++){
		
		var dtstart= subComponents[i].getFirstPropertyValue("dtstart").toString();
		// format example: 2016-01-09T08:45:00		
		var start = dtstart.substr(dtstart.indexOf('T')+1);
		var dtend = subComponents[i].getFirstPropertyValue("dtend").toString();
		end = dtend.substr(dtend.indexOf('T')+1);
		
		var location = subComponents[i].getFirstPropertyValue("location");
		var summaryArray = subComponents[i].getFirstPropertyValue("summary").split(',');
		
		var course = summaryArray[0];
		var lecturer = summaryArray[1].trim();
		var group = summaryArray[2].trim();
		var ttu = new TimeTableUnit(lecturer, course, start, end, location);
	
		//only the selected group is allowed and others like VO,EX,...
		if (group == qsGroup || group.slice(0,1)!= 'G'){
			courseArray.push(ttu);
		}
	}
	return courseArray;
}

