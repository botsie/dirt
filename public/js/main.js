$(function(){
	//Loading all javascript files dynamically
	var XMLHttpFactories = [
		function () {return new XMLHttpRequest()},
		function () {return new ActiveXObject("Msxml2.XMLHTTP")},
		function () {return new ActiveXObject("Msxml3.XMLHTTP")},
		function () {return new ActiveXObject("Microsoft.XMLHTTP")}
	];

	function createXMLHTTPObject() {
		var xmlhttp = false;
		for (var i=0;i<XMLHttpFactories.length;i++) {
			try {
				xmlhttp = XMLHttpFactories[i]();
			}
			catch (e) {
				continue;
			}
			break;
		}
		return xmlhttp;
	}

	if (typeof appdata !== 'undefined'){
		for(i in appdata["jsfiles"]){
			// get some kind of XMLHttpRequest
			var xhrObj = createXMLHTTPObject();
			// open and send a synchronous request
			xhrObj.open('GET', '/js/'+i+'.js', false);
			xhrObj.send('');
			// add the returned content to a newly created script tag
			var se = document.createElement('script');
			se.type = "text/javascript";
			se.text = xhrObj.responseText;
			document.getElementsByTagName('head')[0].appendChild(se);

		}
	}
});