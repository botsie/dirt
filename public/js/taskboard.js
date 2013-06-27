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
  							//console.log(data)
  						}
  					});

				});
			}
		}
	});

	var taskboard = function(){
		var self = this;

		self.data = ko.observableArray([]);
		self.ticketId = new Array;
		self.currentId = "";
		
		self.newcomment = function(data, event){
			console.log("clicked me");
			// show comment popover here..
		}

		self.showInfo = function(data, event){
			// get ticket id from event.target and check if its available in the data array
			// if available check for updates
			// if not get comments from server
			event.stopPropagation();

			$("#taskboardModal").modal();
			var currentId = this.currentId =  $(event.target).closest(".card-border").attr('ticketid');

			$("#taskboardLable").html("<a href='https://sysrt.ops.directi.com/Ticket/Display.html?id="+currentId+"'>#"+currentId+"</a>");

			$.ajax({
				url : "/api/v1.0/",
				method: "get",
				dataType: "JSON",
				data: {
					"query" : "info",
					"ticketId" : currentId
				},
				success: function(data){
					// console.log(data);
					// var html = "";
					$("#taskboardLable").html("<a href='https://sysrt.ops.directi.com/Ticket/Display.html?id="+currentId+"'>#"+currentId+"</a> <span>: "+data['Subject']+"</span>");
					var html = "<table class='table table-striped'>";
					html += "<tr><td>Ticket Id</td><td><a href='https://sysrt.ops.directi.com/Ticket/Display.html?id="+data['id']+"'>#"+data['id']+"</a></td></tr>";
					html += "<tr><td>Queue Name</td><td>"+data['Queue']+"</td></tr>";
					html += "<tr><td>Subject</td><td>"+data['Subject']+"</td></tr>";
					html += "<tr><td>Prority</td><td>"+data['Prority']+"</td></tr>";
					html += "<tr><td>Status</td><td>"+data['Status']+"</td></tr>";
					html += "<tr><td>Creator</td><td>"+data['Creator']+"</td></tr>";
					html += "<tr><td>Owner</td><td>"+data['Owner']+"</td></tr>";
					html += "<tr><td>Created</td><td>"+data['Created']+"</td></tr>";
					html += "<tr><td>Last Updated</td><td>"+data['LastUpdated']+"</td></tr>";
					html += "</table>";
					$("#taskboardBody").html(html);
					$("#taskboardBody").html(html);
				}
			});
		}

	}

	ko.applyBindings(new taskboard);

})(window, window.document ,ko);