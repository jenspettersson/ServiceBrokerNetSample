-- Message Type

CREATE MESSAGE TYPE NServiceBusTransportMessage
    VALIDATION = NONE ;
GO

-- Message Contract

CREATE CONTRACT NServiceBusTransportMessageContract
    ( NServiceBusTransportMessage SENT BY ANY);
GO

-- Chinook Service

CREATE QUEUE [dbo].[ChinookEventServiceQueue];
GO

CREATE SERVICE ChinookEventService
    ON QUEUE [dbo].[ChinookEventServiceQueue]
    (NServiceBusTransportMessageContract);
GO

-- Error service
CREATE QUEUE [dbo].[ErrorServiceQueue];
GO

CREATE SERVICE ErrorService
    ON QUEUE [dbo].[ErrorServiceQueue]
    (NServiceBusTransportMessageContract);
GO