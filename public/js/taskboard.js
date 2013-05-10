/*
 * taskboard.js - should be loaded while rendering taskboard for each project
 * Uses Knockout.js to monitor changes in DOM
 *
 */

(function(window, document, ko, undefined){
	console.log("taskboard.js - loaded");
	var dragging = null; //currently being dragged

	//events for boxes
	function handledragover(e){
		e.stopPropagation();
		e.preventDefault();
	}

	function handledragenter(e){
		e.stopPropagation();
		e.preventDefault();
	}

	function handledragleave(e){
		e.stopPropagation();e.preventDefault();
	}

	function handledrop(e){
		e.stopPropagation();
		if (e.stopPropagation) {
   			e.stopPropagation(); // stops the browser from redirecting.
  		}

  		var flag = 1;
  		
  		if(dragging.parentNode === e.target){flag = 0;}
  		if(flag) {
  			flag = 0;
  			for(i in boxes){
				if(e.target === boxes[i]){flag=1;break;}
			}
  		}
  		if(flag) {
  			console.log("changing");
  			e.target.appendChild(dragging);
  		}
		e.preventDefault();
	}

	//events for cards
	var handledragstart = function (e){
		e.stopPropagation();
		dragging = e.target
	}

	function handledragend(){
		
	}

	var cards = document.getElementsByClassName("card-border");
	for(var i=0;i<cards.length;i++){
		cards[i].setAttribute("draggable", true);
		cards[i].setAttribute('data-bind','event: { dragstart : function(e){handledragstart(e)} } ');
		cards[i].addEventListener('dragstart', handledragstart, false);
	}
	
	var boxes = document.getElementsByTagName("td");
	for(i in boxes){
		if(typeof boxes[i] === "object"){
			boxes[i].addEventListener('dragenter', handledragenter, false);
			boxes[i].addEventListener('dragover',handledragover, false);
			boxes[i].addEventListener('dragleave',handledragleave,false);
			boxes[i].addEventListener('drop',handledrop,false);
		}
	}
})(window, document, ko);
