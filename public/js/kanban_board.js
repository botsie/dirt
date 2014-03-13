function p(arg) {
    console.log(arg);
}

function RtStatus(data) {
    var self = this;
    self.id = data.id;
    self.name = data.name;
    self.active = data.active;
    self.kanbanStatuses = ko.observableArray(data.kanbanStatuses);
}

function Status(data, childCards) {
    var self = this;
    self.active = false;
    self.id = data.id;
    self.name = data.status_name;
    self.rtStatusId = data.rt_status_id;
    self.max_tickets = data.max_tickets;
    self.childCards = ko.observableArray(childCards);
}


function Card(data){
    var self = this;
    self.id = data.id;
    self.subject = ko.observable(data.Subject) ;
    self.cards = ko.observableArray(data.cards);
    self.kanban_status = ko.observable(data.kanban_status);
    self.status_id  = ko.observable(data.status_id);
    self.short_subject = ko.observable(data.short_subject);
    self.age_class = ko.observable(data.age_class);
    self.owner = data.Owner;
    self.origin = data.origin;
}


function KanbanBoardViewModel() {
    var self = this;
    self.cards = ko.observableArray([]);
    self.statuses = ko.observableArray([]);
    self.backlog = ko.observableArray([]);

    self.rtStatuses = ko.observableArray([
        new RtStatus({"id" : 1, "name" : "New", "active" : true, "kanbanStatuses" : []}),
        new RtStatus({"id" : 2, "name" : "Open", "active" : true, "kanbanStatuses" : []}),
        new RtStatus({"id" : 3, "name" : "Stalled", "active" : false, "kanbanStatuses" : []}),
        new RtStatus({"id" : 4, "name" : "Resolved", "active" : true, "kanbanStatuses" : []})
    ]);  


    self.activeRtStatuses = ko.computed(function() {
        return $.grep(self.rtStatuses(), function(item, index) {
            return item.active; 
        });
    });

    self.activeStatuses = ko.computed(function() {
        var len = self.rtStatuses().length;
        var res = [];
        for(var i = 0; i < len ; i++) {
            var status = self.rtStatuses()[i];
            if (status.active == true) {
                res[res.length] = status.kanbanStatuses();
            }            
        }
        return [].concat.apply([],res);
    });

    self.passiveStatuses = ko.computed(function() {
        var len = self.rtStatuses().length;
        var res = [];
        for(var i = 0; i < len ; i++) {
            var status = self.rtStatuses()[i];
            if (status.active == false) {
                res[res.length] = status.kanbanStatuses();
            }            
        }
        return [].concat.apply([],res);
    });

    self.columnUnits = ko.computed(function(){
        // Use Euclid's algorithm to compute lcm
        function gcf(a, b) { 
            return ( b == 0 ) ? (a):( gcf(b, a % b) ); 
        }
        function lcm(a, b) { 
            return ( a / gcf(a,b) ) * b; 
        }
        return lcm(self.activeStatuses().length, self.passiveStatuses().length);
    });

    self.activeColumnSpan = ko.computed(function(){
        return (self.columnUnits() / self.activeStatuses().length);
    });

    self.passiveColumnSpan = ko.computed(function(){
        return (self.columnUnits() / self.passiveStatuses().length);
    });

    self.activeColumnWidth = ko.computed(function(){
        return (100 / self.activeStatuses().length) + "%";
    });

    self.passiveColumnWidth = ko.computed(function(){
        return (100 / self.passiveStatuses().length) + "%";
    });

    // Load initial state from server
    var url = "/api/v2.0/projects/" + project + "/cards";
    $.getJSON(url, function(allData) {
        var mappedCards = $.map(allData, function(item) {
            return new Card(item);
        });
        var backlog = $.map(mappedCards, function(card){
            if (card.kanban_status() === undefined) {
                return card;
            }
        });
        p(backlog);
        self.backlog(backlog);
        self.cards(mappedCards);
    });

    var url = "/api/v2.0/projects/" + project + "/kanban_statuses";
    $.getJSON(url, function(allData) {
        var mappedStatuses = $.map(allData, function(item) {
            // Add child cards to this status
            var childCards = $.grep(self.cards(), function(card, index) {
                return (card.status_id() == item.id); 
            });
            return new Status(item, childCards);
        });

        $.each(mappedStatuses,function(index, status){
            // Add this status to it's parent rt status
            $.each(self.rtStatuses(), function(index, rtStatus){
                if (status.rtStatusId == rtStatus.id) {
                    status.active = rtStatus.active;
                    rtStatus.kanbanStatuses.push(status);
                }
            });
        });
        self.statuses(mappedStatuses);
    });
}

ko.applyBindings(new KanbanBoardViewModel());