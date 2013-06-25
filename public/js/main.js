$(document).ready(function(){
	//Loading all javascript files dynamically
	if (typeof appdata !== 'undefined'){
		for(i in appdata["jsfiles"]){
			$.getScript('/js/'+i+'.js');
		}
	}
});