/*
 * taskboard.js - should be loaded while rendering taskboard for each project
 * Uses Knockout.js to monitor changes in DOM
 *
 */

(function(window, document, ko){
	var cards = document.getElementsByClassName("card-border");
	var boxes = document.getElementsByTagName("td");

	for(i=0;i<cards.length;i++){
		//console.log(cards[i]);
		cards[i].setAttribute("draggable","true");
		cards[i].setAttribute("data-bind","cardext :{ name :'card"+i+"'}");
	}

	for(j=0;j<boxes.length;j++){
		//console.log(boxes[j]);
		boxes[j].setAttribute("data-bind","boxext :{ name :'box"+i+"'}");

	}

	//my extension for knockout 
	var dragitem = null;

	//actual ko code
	ko.utils.extend(ko.bindingHandlers, {
		cardext : {
			init : function(element, valueAccessor){
				var value = ko.utils.unwrapObservable(valueAccessor()),
					name = value.name;

				ko.utils.registerEventHandler(element, 'dragstart', function (event) {
					//set the source container
					//console.log("starting drag");
					//console.log(event.target);
					dragitem = event.target;
				});
			}
		},
		boxext : {
			init : function(element, valueAccessor){
				var value = ko.utils.unwrapObservable(valueAccessor()),
					name = value.name;

				ko.utils.registerEventHandler(element, 'dragenter', function (event) {
					//console.log("dragenter");
					event.stopPropagation();
					event.preventDefault();
				});


				ko.utils.registerEventHandler(element, 'dragover', function (event) {
					//console.log("dragover");
					event.stopPropagation();
					event.preventDefault();
				});


				ko.utils.registerEventHandler(element, 'dragleave', function (event) {
					//console.log("dragleave");
					event.stopPropagation();
					event.preventDefault();
				});


				ko.utils.registerEventHandler(element, 'drop', function (event) {
					//console.log("drop");
					//handle drop event
					//get source container n event.target returns the current target container
					event.stopPropagation();
					if (event.stopPropagation) {
							event.stopPropagation(); // stops the browser from redirecting.
					}

					//console.log(event.target);

					var flag = 1;
  		
  					if(dragitem.parentNode === event.target){flag = 0;}
  					if(flag) {
  						flag = 0;
  						for(i in boxes){
							if(event.target === boxes[i]){flag=1;break;}
						}
  					}
  					if(flag) {
  						//console.log("changing");
  						event.target.appendChild(dragitem);
  					}

				});
			}
		}
	});

	ko.applyBindings();

})(window, window.document ,ko);