$(document).ready(function(){
	//Loading all javascript files dynamically
	for(i in appdata["jsfiles"]){
		$.getScript('/js/'+i+'.js');
	}
});