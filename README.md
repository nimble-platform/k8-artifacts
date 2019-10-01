> Change the `infra/postgres/fmp-main-db-persistentvolumeclaim.yaml` and the `infra/solr/solr-data-persistentvolumeclaim.yaml` StorageClass based on your k8s cluster



1. Start Infra services

	1.1. Create keycloak secret

		$ kubectl create secret generic keycloak-secrets --from-file=infra/keycloak/keycloak_secrets 

	1.2. Start the postres DB

		$ kubectl apply -f infra/postgres/

	> Wait till the fmp-main-db will start

		$ kubectl get pod -l io.kompose.service=fmp-main-db --watch

	1.3. Connect to the DB (DBeaver) and create dbs

	1.3.1. User port forward t the DB

		$ kubectl port-forward $(kubectl get pod -l  io.kompose.service=fmp-main-db -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}') 5432

	1.3.2. Connect to DB
		
		Host: localhost
		Database: postgres
		Username: xxx
		Password: xxx

	1.3.3. Execute the following

		CREATE DATABASE identitydb WITH OWNER admin;
		CREATE DATABASE catalogcategorydb WITH OWNER admin;
		CREATE DATABASE camundadb WITH OWNER admin;
		CREATE DATABASE businessprocessdb WITH OWNER admin;
		CREATE DATABASE ubldb WITH OWNER admin;
		CREATE DATABASE modalmldb WITH OWNER admin;
		CREATE DATABASE catalogsyncdb WITH OWNER admin;
		CREATE DATABASE datachanneldb WITH OWNER admin;
		CREATE DATABASE trustdb WITH OWNER admin;
		CREATE DATABASE keycloak WITH OWNER admin;
		CREATE DATABASE binarycontentdb WITH OWNER admin;
	
	1.4. start the rest Infra services

		$ for file in  $(find infra -name '*.yaml'); do kubectl apply -f $file; done

	> Make sure everything is up and running

		$ kubectl get pod --watch

2. Configure the ingress `ingress.yaml`
3. Apply the ingress
   
   		$ kubectl apply -f ingress.yaml

		   
4. Create keyclock client secrets API key
   
   4.1. KEYCLOAK_ADMIN_CLIENT_SECRET
   4.2. OAUTH_CLIENT_SECRET
   4.3. <Guide how shell it be done>
   4.4. Add the secrets `global-config.yaml`
   4.5. Cretae users and groups

   
5. Start the micro-services

	5.1. Change the `global-config.yaml` based on your external URL

	5.2. Change the #KAFKA sections to your needs
	
	5.3. Apply the `global-config.yaml`

		$ kubectl apply -f services/global-config.yaml

	5.4. Change the frontend service with you external URL in `services/frontend-service/src/environments/` file

	5.5. Build a docker image with your tag and push it

	5.6. Change the docker image tag in the `services/frontend-service/frontend-service-deployment.yaml`

	5.7. Apply the services

		$ for file in  $(find services -name '*.yaml'); do kubectl apply -f $file; done
	
	5.8. Make sure all services are running

		$ kubectl get pod --watch

	5.9 Connect to the `trustdb` database

		$ kubectl port-forward $(kubectl get pod -l  io.kompose.service=fmp-main-db -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}') 5432
		
	5.10. Execute the followin script

		insert into trust_attribute_types (id, name, descr, parent_type_id) values (1,'OverallCompanyRating','OverallCompanyRating',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (2,'OverallCommunicationRating','OverallCommunicationRating',1);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (3,'QualityOfNegotiationProcessRating','QualityOfNegotiationProcessRating',2);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (4,'QualityOfOrderingProcessRating','QualityOfOrderingProcessRating',2);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (5,'ResponseTimeRating','ResponseTimeRating',2);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (6,'OverallFullfilmentOfTermsRating','OverallFullfilmentOfTermsRating',1);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (7,'ListingAccuracyRating','ListingAccuracyRating',6);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (8,'ConformanceToContractualTerms','ConformanceToContractualTerms',6);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (9,'OverallDeliveryAndPackagingRating','OverallDeliveryAndPackagingRating',1);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (10,'NumberOfCompletedTransactions','NumberOfCompletedTransactions',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (11,'NumberOfUncompletedTransactions','NumberOfUncompletedTransactions',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (12,'TradingVolume','TradingVolume',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (13,'AverageTimeToRespond','AverageTimeToRespond',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (14,'AverageNegotiationTime','AverageNegotiationTime',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (15,'OverallProfileCompletness','OverallProfileCompletness',null);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (16,'ProfileCompletnessDetails','ProfileCompletnessDetails',15);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (17,'ProfileCompletnessDescription','ProfileCompletnessDescription',15);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (18,'ProfileCompletnessTrade','ProfileCompletnessTrade',15);
		insert into trust_attribute_types (id, name, descr, parent_type_id) values (19,'ProfileCompletnessCertificates','ProfileCompletnessCertificates',15);
		update trust_attribute_types set created_datetime = now();
		update trust_attribute_types set version = 0;
		commit;



6. Initiate trust sroce


# Tear down

	$ for file in  $(find . -name '*.yaml'); do kubectl delete -f $file; done