cd react-form/
docker buildx build --platform linux/amd64 -t us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/react-form:latest .
docker push us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/react-form:latest 

cd csharp-service/
dotnet publish -c Release -o out
docker buildx build --platform linux/amd64 -t us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/csharp-service:latest .
docker push us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/csharp-service:latest  

cd python-subscriber
docker buildx build --platform linux/amd64 -t us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/python-subscriber:latest .
docker push us-central1-docker.pkg.dev/prj-common-d-shared-89549/reg-d-common-docker-public/pub-sub-demo/python-subscriber:latest   

# Dapr running locally:
# Installed the Dapr CLI, and have the containers running - Show dockerhub
dapr --version

## SVC INVOKE
# Show code for both apps
# Run apps - svc invoke: 
# cd react-form 
# dapr run --app-id react-form --app-port 8080 npm run start

# cd csharp-service/
# dapr run --app-id csharp-service --app-port 5009 dotnet run

## PUBSUB
# Show code for both apps
# Run apps - pubsub: 
dapr run --app-id react-form --app-port 8080 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local npm run start
dapr run --app-id python-subscriber --app-port 5001 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local python3 app.py
# show a message sending in the UI to pub sub 

# component swap
dapr run --app-id react-form --app-port 8080 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/aks npm run start
dapr run --app-id python-subscriber --app-port 5001 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/aks python3 app.py

# k8s:
## K8s show control plane:

k get all -n dapr-system
k get po  # 2 containers one for dapr and one for app
k get components

# Use rest samples to send messages
# send a message on A or C watch logs in react publisher and python subscriber



##OLD: 
# Try using the Dapr CLI
# dapr publish --publish-app-id react-form --pubsub pubsub --topic A --data-file message_a.json

# Navigate to http://34.83.221.26/

## Swap out yaml files
k delete component pubsub
k apply -f deploy/components/kafka.yaml
# note you do need to cycle the pods every time you make changes to components

## DDOSify for metrics in Conductor
ddosify -t http://34.83.221.26:80/publish -m POST -b '{"messageType": "C", "message":"Pub/sub from ddosify to topic C"}' -T 10 -d 600 -n 10000 -h 'Content-Type: application/json'
ddosify -t http://34.83.221.26:80/invoke -m POST -b '{"messageType": "B", "message":"Invoke from ddosify to topic B"}' -T 10 -d 600 -n 10000  -h 'Content-Type: application/json'