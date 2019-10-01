Install kubeadm https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

Open ports 

    $ ufw allow 6443/tcp

Start cluster 

    $ kubeadm init --apiserver-advertise-address 192.168.30.50 --pod-network-cidr=10.244.0.0/16
    $ kubectl taint nodes --all node-role.kubernetes.io/master-
    $ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml


Download HELM from https://github.com/helm/helm/releases

Install helm

    $ helm init

Add permissions to the cluster to HELM tiler

    $ kubectl create clusterrolebinding tillerAdmin --clusterrole=cluster-admin --serviceaccount=kube-system:default

Install Ingress

    $ helm install stable/nginx-ingress --name ingress -f kubeadm/ingress-values.yaml --namespace kube-system
    
Create secret TLS from ceftificates

    $ kubectl create secret tls nimble --cert=/root/efactory-nimble_salzburgresearch_at.crt --key=/root/efactory-nimble.salzburgresearch.at.key

Copy the kube config file to your local machine (~/.kube.config)

    $   mkdir -p $HOME/.kube
    $ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    $ sudo chown $(id -u):$(id -g) $HOME/.kube/config

Copy the config file to Jenkins user home dir

    $ sudo cp -rp /etc/kubernetes/admin.conf ~jenkins/.kube
    $ chown -R jenkins:jenkins ~jenkins/.kube/



## Deploy Prometheus Operator

Open ufw ports for pods to contact the Host IP
    $ sudo ufw allow from 10.244.0.0/16 to any

Create secret for etcd monitoring

Deploy Prometheus Operator Helm chard

    $ helm install --name prometheus-operator stable/prometheus-operator -f kubeadm/prometheus-operator-values.yaml --namespace prometheus

