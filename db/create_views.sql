

CREATE OR REPLACE VIEW expanded_tickets AS
SELECT 
  Tickets.id AS id,
  Tickets.EffectiveId,
  Tickets.Queue AS queue_id,
  Tickets.Type,
  Tickets.IssueStatement,
  Tickets.Resolution,
  Tickets.Owner AS owner_id,
  Tickets.Subject,
  Tickets.InitialPriority,
  Tickets.FinalPriority,
  Tickets.Priority,
  Tickets.TimeEstimated,
  Tickets.TimeWorked,
  Tickets.Status,
  Tickets.TimeLeft,
  Tickets.Told,
  Tickets.Starts,
  Tickets.Started,
  Tickets.Due,
  Tickets.Resolved,
  Tickets.LastUpdatedBy AS last_updated_by_id,
  Tickets.LastUpdated,
  Tickets.Creator AS creator_id,
  Tickets.Created,
  Tickets.Disabled,
  Queues.Name AS Queue,
  Owners.Name AS Owner,
  Creators.Name AS Creator,
  Updaters.Name AS LastUpdatedBy
FROM Tickets, Queues, Users AS Owners, Users AS Creators, Users AS Updaters
WHERE Tickets.Queue = Queues.id
  AND Tickets.Owner = Owners.id
  AND Tickets.Creator = Creators.id
  AND Tickets.LastUpdatedBy = Updaters.id;  
