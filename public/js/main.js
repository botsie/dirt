$(document).ready(function(){
	//Loading all javascript files dynamically
	for(i in appdata["jsfiles"]){
		console.log(i);
		$.getScript('/js/'+i+'.js');
	}
});