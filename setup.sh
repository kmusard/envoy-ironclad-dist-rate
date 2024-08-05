set -Eeuo pipefail

echo "Setting up envoy-ironclad-dist-rate!"

PKGS=()
for PKG in cilium docker helm kubectl minikube; do
    if ! which $PKG >/dev/null 2>&1; then
        PKGS=("${PKGS[@]}" "${PKG}")
    fi
done

if [ ${#PKGS[@]} -ne 0 ]; then
    echo "Missing packages: ${PKGS[@]}"
    exit 1
fi

echo "Starting minikube"
minikube start

echo "Enabling metrics-server"
minikube addons enable metrics-server

echo "Connecting to minikube docker daemon"
eval $(minikube -p minikube docker-env)

echo "Building curl-loop image in minikube"
docker build -t curl-loop:latest ./docker

echo "Adding cilium helm repo and installing cilium"
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
    --version 1.16.0 \
    --namespace kube-system \
    --set operator.replicas=1 
echo "Enabling hubble"
cilium hubble enable --namespace kube-system

echo "Creating envoy-ironclad-dist-rate namespace"
kubectl apply -f manifests/envoy-ns.yaml

echo "Ready for envoy-ironclad-dist-rate Helm Chart installation!"
CMD=(
    "Execute:\n"
    " set +o history # disable shell history\n"
    " helm install envoy-ironclad-dist-rate ./helm/envoy-ironclad-dist-rate"
    " --namespace envoy-ironclad-dist-rate"
    " --set curl.googleApiKey=GOOGLE_API_KEY\n"
    " set -o history # enable shell history\n"
)
echo -e "${CMD[@]}"