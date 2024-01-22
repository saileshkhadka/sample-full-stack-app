FROM mcr.microsoft.com/mssql/server

ENV SA_PASSWORD=Sailesh@2024?
ENV ACCEPT_EULA=Y

COPY init.sql /docker-entrypoint-initdb.d/
