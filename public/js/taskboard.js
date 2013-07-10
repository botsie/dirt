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
					event.originalEvent.dataTransfer.setData("Text","Drop data");
					return true;
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
					return false;
				});


				ko.utils.registerEventHandler(element, 'dragover', function (event) {
					//console.log("dragover");
					event.stopPropagation();
					event.preventDefault();
					return false;
				});


				ko.utils.registerEventHandler(element, 'dragleave', function (event) {
					//console.log("dragleave");
					event.stopPropagation();
					event.preventDefault();
					return false;
				});


				ko.utils.registerEventHandler(element, 'drop', function (event) {
					//handle drop event
					//get source container n event.target returns the current target container
					event.stopPropagation();
					event.preventDefault();

					var flag = 1;
  					
  					if(dragitem.getAttribute("class") != 'card-border'){flag=0;}
  					if(dragitem.parentNode === event.target){flag = 0;}
  					if(flag) {
  						flag = 0;
						if(event.target.getAttribute("data-bind") != null)
							if(event.target.getAttribute("data-bind").match(/boxext/).length > 0) flag=1; 
  					}
  					var child = $(event.target).children(".card-border");
  					var limit = event.target.getAttribute("limit");

  					if(flag && child.length >= limit && limit!=0){
  						flag = 0;
  						var msg = document.createElement('div');
  						msg.setAttribute("class", "alert alert-msg alert-error");
  						msg.setAttribute("style", "z-index:10; float:left;");
  						msg.innerHTML = "<button type='button' class='close' data-dismiss='alert'>&times;</button><strong>Warning!</strong> This queue has reached its limit.";
  						event.target.appendChild(msg);
  						window.setTimeout(function(){
  							$(".alert-msg").fadeTo(500, 0).slideUp(500, function(){
  								$(this).remove(); 
  							});
  						},2000);

  					}else{
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
  					}


				});
			}
		}
	});

	var taskboard = function(){
		var self = this;

		self.ticketId = new Array;
		self.currentId = "";
		self.comment_msg = ko.observable();
		self.ajax = false;

		self.showInfo = function(data, event){
			// get ticket id from event.target and check if its available in the data array
			// if available check for updates
			// if not get comments from server
			event.stopPropagation();

			$("#taskboardModal").modal();
			var currentId = $(event.target).closest(".card-border").attr('ticketid');
			self.currentId = currentId;

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
					html += "<tr><td>Ticket Id</td><td><a target='_blank' href='https://sysrt.ops.directi.com/Ticket/Display.html?id="+data['id']+"'>#"+data['id']+"</a></td></tr>";
					html += "<tr><td>Queue Name</td><td>"+data['Queue']+"</td></tr>";
					html += "<tr><td>Subject</td><td>"+data['Subject']+"</td></tr>";
					html += "<tr><td>Prority</td><td>"+data['Prority']+"</td></tr>";
					html += "<tr><td>Status</td><td>"+data['Status']+"</td></tr>";
					html += "<tr><td>Creator</td><td>"+data['Creator']+"</td></tr>";
					html += "<tr><td>Owner</td><td>"+data['Owner']+"</td></tr>";
					html += "<tr><td>Created</td><td>"+data['Created']+"</td></tr>";
					html += "<tr><td>Last Updated</td><td>"+data['LastUpdated']+"</td></tr>";
					html += "</table>";
					html += "<div id='comment_status_container'></div>";
					html += "<div class='span9'><form name='comment-form' class='form-horizontal' data-bind='submit: submit_comment'>";
					html += "<div class='control-group'><label class='control-label' for='comment_msg'><img src='/images/profile/pic/"+data['pic_url']+"' style='height:60px; width:60px;'></label>";
					html += "<div class='controls'><textarea class='input-xlarge span6' id='comment_msg' name='comment_msg' cols=200 rows=4 data-bind='value: comment_msg' placeholder='Posting as "+data['user_name']+"'></textarea>";
					html += "<hr><input type='submit' class='btn btn-primary' value='Comment'></div>"
					html += "</form></div></div>";
					$("#taskboardBody").html(html);
					bindagain();
				}
			});
		}

		//This is for the comment box in the modal view
		self.submit_comment = function(data){
			if(!self.ajax){
				self.ajax = true;
				$.ajax({
					url: '/api/v1.0/',
					method: 'get',
					dataType : 'JSON',
					data: {
						"query": 'comment',
						"ticketId": self.currentId,
						"msg": self.comment_msg()
					}, 
					success: function(data){
						self.ajax = false;
						if(data['status'] == "600"){
							self.comment_msg(null);
							var msg = document.createElement('div');
	  						msg.setAttribute("class", "alert alert-success comment_status");
	  						msg.setAttribute("style", "z-index:10; float:left;");
	  						msg.innerHTML = "<button type='button' class='close' data-dismiss='alert'>&times;</button><strong>Success!</strong> Comment posted successfully";
	  						$("#comment_status_container").append(msg);
	  						window.setTimeout(function(){
	  							$(".comment_status").fadeTo(500, 0).slideUp(500, function(){
	  								$(this).remove(); 
	  							});
	  						},2000);
						} else {
							var msg = document.createElement('div');
	  						msg.setAttribute("class", "alert alert-error comment_status");
	  						msg.setAttribute("style", "z-index:10;");
	  						msg.innerHTML = "<button type='button' class='close' data-dismiss='alert'>&times;</button><strong>Warning!</strong> Comment could not be saved";
	  						$("#comment_status_container").append(msg);
	  						window.setTimeout(function(){
	  							$(".comment_status").fadeTo(500, 0).slideUp(500, function(){
	  								$(this).remove(); 
	  							});
	  						},2000);
						}
					}
				});
			}
		}

		self.post_comment = function(data){
			if(!self.ajax){
				self.ajax = true;
				$.ajax({
					url: '/api/v1.0/',
					method: 'get',
					dataType : 'JSON',
					data: {
						"query": 'comment',
						"ticketId": $($($("#popover_comment_form").parents(".popover")[0]).siblings("i")[0]).attr("ticketId"),
						"msg": self.comment_msg()
					}, 
					success: function(data){
						self.ajax = false;
						if(data["status"]=="600"){
							self.comment_msg(null)
							var msg = document.createElement('div');
	  						msg.setAttribute("class", "alert alert-success comment_status");
	  						msg.setAttribute("style", "z-index:10; float:left;");
	  						msg.innerHTML = "<button type='button' class='close' data-dismiss='alert'>&times;</button><strong>Success!</strong> Comment posted successfully";
	  						$("#comment_status_container").append(msg);
	  						window.setTimeout(function(){
	  							$(".comment_status").fadeTo(500, 0).slideUp(500, function(){
	  								$(this).remove(); 
	  							});
	  						},2000);
						} else {
							var msg = document.createElement('div');
	  						msg.setAttribute("class", "alert alert-error comment_status");
	  						msg.setAttribute("style", "z-index:10;");
	  						msg.innerHTML = "<button type='button' class='close' data-dismiss='alert'>&times;</button><strong>Warning!</strong> Comment could not be saved";
	  						$("#comment_status_container").append(msg);
	  						window.setTimeout(function(){
	  							$(".comment_status").fadeTo(500, 0).slideUp(500, function(){
	  								$(this).remove(); 
	  							});
	  						},2000);
						}
					}
				});

			}
		}

	}

	// callback binding for popover
	var pt = $.fn.popover.Constructor.prototype.show;
	$.fn.popover.Constructor.prototype.show = function () {
		pt.call(this);
		if (this.options.afterShowed) {
			this.options.afterShowed();
		}
	}

	$(".icon-comment").popover({
		html: true,
		title: "Post a comment",
		content: function() {
			var html = "<div id='comment_status_container'></div>";
			html += "<form name='comment-form' data-bind='submit: post_comment' id='popover_comment_form'>";
			html += "<textarea id='comment_msg' style='width: 254px;' rows='5' name='comment_msg' data-bind='value: comment_msg'></textarea>";
			html += "<input type='submit' onclick='submitForm()' class='btn btn-primary btn-mini' value='Comment'>"
			html += "</form>";
			return html;
		},
		afterShowed: function() {
			bindagain();
		}
	});	

	$('body').on('click', function (e) {
	    $('.icon-comment').each(function () {
	        if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
	            $(this).popover('hide');
	        }
	    });
	});

	$(document).on('keydown', function(e){
		$('.icon-comment').each(function () {
	        if (e.keyCode === 27) {
	            $(this).popover('hide');
	        }
	    });
	});

	var bindtaskboard = new taskboard;
	var bindagain = function(){
		ko.applyBindings(bindtaskboard);
	}
	bindagain();

})(window, window.document ,ko);

function submitForm(){
	$("#popover_comment_form").submit();
}