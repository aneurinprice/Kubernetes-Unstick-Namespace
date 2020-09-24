NAMESPACE=$1
kubectl proxy &
kubectl get namespace $NAMESPACE -o json |jq '.spec = {"finalizers":[]}' >temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize

sleep 5

if kubectl get namespace $NAMESPACE
then
	kubectl patch namespace $NAMESPACE -p '{"metadata":{"finalizers": []}}' --type=merge
else
	echo "Namespace deleted"
	exit 0
fi

if kubectl get namespace $NAMESPACE
then
	echo "I have failed you"
	exit 1
else
	echo "Namespace deleted"
	exit 0
fi
