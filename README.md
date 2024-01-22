# sample-full-stack-app
#Author: Sailesh Khadka

#Date: 23 Jan 2024



Here we create full stack application with sql server fully dockerize, along with github ci/cd and also deploy on azure.
Note: We directly commit and push to master branch but for the best practice please follow the branching patterns and create proper pull request and merge it to main branch.

Step 1: 
Create simple frontend application having package.json , Dockerfile and app.js
Here, we ensure the proper commands for dockerfile


	- npm install 
	- npm install -g http-server 
And in package.json with proper scripts, 


	"start": "http-server -p 3001"

Step 2: 
Create backend application with package.json, Dockerfile and app.js
Ensure these cmd on dockerfile, 


	- npm install 
 	- EXPOSE 3001

Step 3:
Create db with server initialization and Dockerfile
for db we use ms-sql server and with proper pwd and port expose

In the root folder, Create docker-compose file where we perform our tasks where proper ports should be exposed.

Run the docker compose up with detached mode so that it runs on background,

	docker-compose up --build -d 

This command will run frontend, backend and db in docker.

Now, we will create one github workflow inside .github/workflows/ named as main.yml which performs our CI/CD and pushed our code to Container Registery as docker hub.

After all these we run our changes and for the IaC, 
We create a terraform templete to deploy our resources on azure portal where we define every resource.

But first need to login to Azure using the Azure CLI. If it runs without first authenticating, Terraform complains that the resource group containing the storage account cannot be found.
So to login the ac

az login --tenant <tenant ID>
az account set --subscription <subscription ID>

once authenticated,

Run terraform command to apply the changes

To initialize the work dir

terraform init 

We can plan the overall infrastructure without applying 

terraform plan 

To create or updates infrastructure depending on the configuration files. By default, a plan will be generated first and will need to be approved before it is applied.

terraform apply 

If we need to apply without prompting yes 

terraform apply -auto-approve



Happy Learning!!


