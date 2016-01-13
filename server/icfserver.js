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
var app = express();
var TimeTableUnit = require('./timeTableUnit.js');

//Lets define a port we want to listen to
const PORT=7777; 

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
		res.setHeader('Content-Type', 'application/json');
		res.status(400).send('Bad Request!');
		return res;
	}
	
	// send request to alamaty to get courses
	var buildParameter = querystring.stringify({'studiengang' : qsStudy, 'jahr':qsYear, 'datum' : getDateOfTodayWithFormatYYYYMMDD()},"+", ":");
	request({
		url : 'http://almaty.fh-joanneum.at/stundenplan/search.php',
		method : "GET",
		qs: { q : buildParameter }
		},processTimetableCallback);
	
})

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



var server = app.listen(PORT, function () {

  var host = server.address().address
  var port = server.address().port

  console.log("ICF Server listening at http://%s:%s", host, port)

});
