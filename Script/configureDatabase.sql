DROP TABLE [CONTACT]
GO
DROP TABLE [TAG-VALIDATION]
GO
DROP TABLE [TAG]
GO
DROP TABLE [USER]
GO
DROP TABLE [DHBW]
GO
----------------------------------------------------------

-- Create DHBW table
CREATE TABLE "DHBW" (
    "LOCATION"      VARCHAR(30) NOT NULL,
    "EMAIL-DOMAIN"  VARCHAR(30) NOT NULL

	CONSTRAINT "DHBW-PK"
		PRIMARY KEY ("LOCATION")
)
GO

-- Create USER table
CREATE TABLE "USER" (
    "USER-ID"           INT IDENTITY(1000, 1),
    "FIRSTNAME"         VARCHAR(30) NOT NULL,
    "LASTNAME"          VARCHAR(30) NOT NULL,
    "DHBW"              VARCHAR(30) NOT NULL,
    "COURSE-ABR"        VARCHAR(15) NOT NULL,
    "COURSE"            VARCHAR(30) NOT NULL,
    "SPECIALIZATION"    VARCHAR(50),
    "EMAIL-PREFIX"      VARCHAR(50) NOT NULL,
    "CITY"              VARCHAR(30),
    "BIOGRAPHY"         VARCHAR(1000) COLLATE Latin1_General_100_CI_AI_SC_UTF8,
    "RFID-ID"           VARCHAR(30),
    "PW-HASH"           VARCHAR(30) NOT NULL,
    "IS-VERIFIED"       BIT NOT NULL DEFAULT 0,
    "VERIFICATION-ID"   INT NOT NULL,
    "TMS-CREATED"       DATETIME DEFAULT CURRENT_TIMESTAMP

    CONSTRAINT "USER-PK"
        PRIMARY KEY ("USER-ID"),

	CONSTRAINT "USER-FK-DHBW"
        FOREIGN KEY ("DHBW") REFERENCES [DHBW]("LOCATION"),

	CONSTRAINT "USER-UNIQUE-NO-DUPLICATE-EMAILS"
        UNIQUE ("EMAIL-PREFIX", "DHBW")
)
GO

-- Create TAG table
CREATE TABLE "TAG" (
    "TAG-ID"        INT IDENTITY(1000, 1),
    "TAG"           VARCHAR(15) NOT NULL,
    "USER"          INT NOT NULL,
    "TMS-CREATED"   DATETIME DEFAULT CURRENT_TIMESTAMP

    CONSTRAINT "TAG-PK"
        PRIMARY KEY ("TAG-ID"),

	CONSTRAINT "TAG-FK-USER"
        FOREIGN KEY ("USER") REFERENCES [USER]("USER-ID"),

    CONSTRAINT "TAG-UNIQUE-NO-DUPLICATE-TAGS" 
        UNIQUE ("TAG", "USER")
)
GO

-- Create TAG-VALIDATION table
CREATE TABLE "TAG-VALIDATION" (
    "VALIDATION-ID" INT IDENTITY(1000, 1),
    "TAG"           INT NOT NULL,
    "VALIDATED-BY"  INT NOT NULL,
    "COMMENT"       VARCHAR(1000),
    "TMS-CREATED"   DATETIME DEFAULT CURRENT_TIMESTAMP

    CONSTRAINT "TAG_VALIDATION-PK"
        PRIMARY KEY ("VALIDATION-ID"),

	CONSTRAINT "TAG_VALIDATION-FK-TAG"
        FOREIGN KEY ("TAG") REFERENCES [TAG]("TAG-ID"),

	CONSTRAINT "TAG_VALIDATION-FK-USER"
        FOREIGN KEY ("VALIDATED-BY") REFERENCES [USER]("USER-ID"),

    CONSTRAINT "TAG-VALIDATION-UNIQUE-NO-DUPLICATE-VALIDATIONS" 
        UNIQUE ("TAG", "VALIDATED-BY")
)
GO

-- Create CONTACTS table
CREATE TABLE "CONTACT" (
    "USER"          INT NOT NULL,
    "CONTACT"       INT NOT NULL,
    "TMS-CREATED"   DATETIME DEFAULT CURRENT_TIMESTAMP

	CONSTRAINT "CONTACT-FK-USER"
        FOREIGN KEY ("USER") REFERENCES [USER]("USER-ID"),

	CONSTRAINT "CONTACT-FK-USER_CONTACT"
        FOREIGN KEY ("CONTACT") REFERENCES [USER]("USER-ID"),

    CONSTRAINT "CONTACT-UNIQUE-NO-DUPLICATE-CONTACTS"
        PRIMARY KEY ("USER", "CONTACT")
)
GO

-- Create ON-USER-DELETE Trigger
CREATE TRIGGER [dbo].[ON-USER-DELETE]
    ON [dbo].[USER]
    INSTEAD OF DELETE
AS
    DELETE FROM [dbo].[CONTACT]
		WHERE 
			[dbo].[CONTACT].[USER] IN(SELECT deleted.[USER-ID] FROM deleted) OR
			[dbo].[CONTACT].[CONTACT] IN(SELECT deleted.[USER-ID] FROM deleted)

	DELETE FROM [dbo].[TAG-VALIDATION]
		WHERE 
			[dbo].[TAG-VALIDATION].[VALIDATED-BY] IN(SELECT deleted.[USER-ID] FROM deleted)

	DELETE FROM [dbo].[TAG]
		WHERE 
			[dbo].[TAG].[USER] IN(SELECT deleted.[USER-ID] FROM deleted)

	DELETE FROM [dbo].[USER]
		WHERE 
			[dbo].[USER].[USER-ID] IN(SELECT deleted.[USER-ID] FROM deleted)
GO

-- Create ON-TAG-DELETE Trigger
CREATE TRIGGER [dbo].[ON-TAG-DELETE]
    ON [dbo].[TAG]
    INSTEAD OF DELETE
AS
    DELETE FROM [dbo].[TAG-VALIDATION]
		WHERE 
			[dbo].[TAG-VALIDATION].[TAG] IN(SELECT deleted.[TAG-ID] FROM deleted)

	DELETE FROM [dbo].[TAG]
		WHERE 
			[dbo].[TAG].[TAG-ID] IN(SELECT deleted.[TAG-ID] FROM deleted)
 GO

 -- Create ON-DHBW-DELETE Trigger
CREATE TRIGGER [dbo].[ON-DHBW-DELETE]
    ON [dbo].[DHBW]
    INSTEAD OF DELETE
AS
    DELETE FROM [dbo].[USER]
		WHERE 
			[dbo].[USER].[DHBW] IN(SELECT deleted.[LOCATION] FROM deleted)

	DELETE FROM [dbo].[DHBW]
		WHERE 
			[dbo].[DHBW].[LOCATION] IN(SELECT deleted.[LOCATION] FROM deleted)