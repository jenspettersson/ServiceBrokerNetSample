CREATE PROCEDURE [dbo].[SendNServiceBusMessage]
 @TargetService NVARCHAR(200),
 @MessageName NVARCHAR(200),
 @MessageContent NVARCHAR(4000)
AS

BEGIN
-- Sending a Service Broker Message
DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
DECLARE @MessageContract NVARCHAR(200);
DECLARE @MessageType NVARCHAR(200);
DECLARE @TransportMessage NVARCHAR(4000);

SET NOCOUNT ON

SET  @MessageContract = 'NServiceBusTransportMessageContract';
SET  @MessageType = 'NServiceBusTransportMessage';

BEGIN TRANSACTION;

 BEGIN DIALOG @InitDlgHandle
   FROM SERVICE @TargetService
   TO SERVICE @TargetService
   ON CONTRACT @MessageContract
   WITH ENCRYPTION = OFF;

SET @TransportMessage ='<TransportMessage><Body><![CDATA[<Messages xmlns="http://tempuri.net/ServiceBrokerNetSample.Events"><'+@MessageName+'>' +
    @MessageContent +'</'+@MessageName+'></Messages>]]></Body></TransportMessage>';

 SEND ON CONVERSATION @InitDlgHandle
   MESSAGE TYPE @MessageType
    (@TransportMessage);

COMMIT TRANSACTION;

END

GO