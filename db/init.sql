-- database/init.sql
USE master;
GO

CREATE DATABASE HelloWorldDB;
GO

USE HelloWorldDB;
GO

CREATE TABLE Greetings (
  id INT PRIMARY KEY IDENTITY,
  message NVARCHAR(255)
);

INSERT INTO Greetings (message) VALUES ('Hello from Database!');
