/**
 * class representing a timetable unit
 * 
 * author: Groeller Patrick, Kopf Helmut, Koller Christian
 * version: 1.0
 * date: 20160112
 * 
 * */
var timeTableUnit = function TimeTableUnit(lecturer, course, start, end, location) { 
	this.lecturer=lecturer;
	this.course=course;
	this.start=start;
	this.end=end;
	this.location=location;	
} 
module.exports = timeTableUnit;





