/*
 * taskboard.js - should be loaded while rendering taskboard for each project
 * Uses Knockout.js to monitor changes in DOM
 *
 */

(function(window, document, ko){
	'use strict';
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
					//handle drop event
					//get source container n event.target returns the current target container
					event.stopPropagation();
					if (event.stopPropagation) {
							event.stopPropagation(); // stops the browser from redirecting.
					}

					var flag = 1;
  					
  					if(dragitem.getAttribute("class") != 'card-border'){flag=0;}
  					if(dragitem.parentNode === event.target){flag = 0;}
  					if(flag) {
  						flag = 0;
						if(event.target.getAttribute("data-bind") != null)
							if(event.target.getAttribute("data-bind").match(/boxext/).length > 0) flag=1; 
  					}
  					if(flag) {
  						event.target.appendChild(dragitem);
  					}

  					$("ajax-status").show();
  					// parameters to be sent to the restapi 
  					// projectid , statusname , ticketid, query

  					$.ajax({
  						url: "/api/v1.0/",
  						method: "get",
  						dataType: "JSON",
  						data: {
  							"query" : "status",
  							"ticketId" : dragitem.getAttribute('ticketId'),
  							"status" : event.target.getAttribute("status_name"),
  							"projectId" : appdata['project_id']
  						},
  						success: function(data){
  							$("ajax-status").hide();
  							console.log(data)
  						}
  					});

				});
			}
		}
	});

	var comments = {
		data : ko.observableArray([]),
		ticketId : [],
		currentId : "",
		handleClick : function(data, event){
			// get ticket id from event.target and check if its available in the data array
			// if available check for updates
			// if not get comments from server
			console.log(event);
			var flag = 0;
			var data = this.data;
			var currentId = this.currentId =  event.target.parentNode.getAttribute('ticketId');
			console.log(data.length);
			for(var i=0; i< data.length; i++){
				if(data[i].ticketId === currentId){
					console.log("matched");
					flag = 1;
					break;
				}
			}
			if(flag == 0){ //ticket comments have to be fetched from the server
				this.ticketId.push(currentId);
			} else { // ticket comments found, request server for updates

			}
		}

	}

	ko.applyBindings(comments);

})(window, window.document ,ko);