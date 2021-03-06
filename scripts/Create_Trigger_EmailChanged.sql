USE [Chinook]
GO
/****** Object:  Trigger [dbo].[TRG_EmailChanged]    Script Date: 12/08/2010 09:20:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[TRG_EmailChanged]
   ON  [dbo].[Customer]
   FOR UPDATE
AS 
IF UPDATE(Email)
BEGIN
	SET NOCOUNT ON;

	DECLARE @MESSAGENAME NVARCHAR(255)
	
	-- This is what event your application will use later
	SET @MESSAGENAME = 'CustomerEmailChangedEvent'

	DECLARE @CustomerId int
	DECLARE @OldEmail NVARCHAR(60)
	DECLARE @NewEmail NVARCHAR(60)

	SELECT @OldEmail = Email FROM deleted
	SELECT @NewEmail = Email, @CustomerId = CustomerId FROM inserted
	
	IF @OldEmail <> @NewEmail
	BEGIN
			
		DECLARE @CustomerIdXml XML
		DECLARE @PreviousEmailAddressXml XML
		DECLARE @NewEmailAddressXml XML
		DECLARE @XmlText NVARCHAR(MAX)
		
		-- I'm using select for xml because otherwise special characters might cause problems
		SET @CustomerIdXml = (select @CustomerId for xml path('CustomerId'))
		SET @PreviousEmailAddressXml = (select @OldEmail for xml path ('PreviousEmailAddress'))
		SET @NewEmailAddressXml = (select @NewEmail for xml path ('NewEmailAddress'))
		
		-- This is the text that we will use in our message
		SET @XmlText = cast(@CustomerIdXml as NVARCHAR(MAX)) 
		+ cast(@PreviousEmailAddressXml as NVARCHAR(MAX)) 
		+ cast(@NewEmailAddressXml as NVARCHAR(MAX))
		
		exec SendNServiceBusMessage
			@TargetService = N'ChinookEventService',
			@MessageName = @MESSAGENAME,
			@MessageContent = @XMLTEXT;	
	END
END