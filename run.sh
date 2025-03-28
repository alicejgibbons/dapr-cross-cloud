# K8s docker images
cd react-form/
docker buildx build --platform linux/amd64 -t europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/react-form:latest .
docker push europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/react-form:latest

cd csharp-service/
dotnet publish -c Release -o out
docker buildx build --platform linux/amd64 -t europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/csharp-service:latest .
docker push europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/csharp-service:latest 

cd python-subscriber
docker buildx build --platform linux/amd64 -t europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/python-subscriber:latest .
docker push europe-west1-docker.pkg.dev/prj-dataplane-n-demo-30534/kubecon-demo-registry/python-subscriber:latest

# Create namespace
k create ns dapr-cross-cloud 

# Helm Redis install
helm install redis bitnami/redis -n redis --create-namespace
export REDIS_PASSWORD=$(kubectl get secret --namespace redis redis -o jsonpath="{.data.redis-password}" | base64 -d)
echo $REDIS_PASSWORD
kubectl create secret generic redis-password --from-literal=redis-password=$REDIS_PASSWORD -n dapr-cross-cloud

# Deploy apps


# Dapr running locally:
cd react-form/
npm install
dapr run --app-id react-form --app-port 8080 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local npm run start

## PUBSUB
# Show code for both apps
# Run apps - pubsub: 
dapr run --app-id react-form --app-port 8080 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local npm run start
dapr run --app-id python-subscriber --app-port 5001 --resources-path /Users/alicegibbons/repos/pubsub-svc-example/deploy/components/local python3 app.py
# show a message sending in the UI to pub sub 

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