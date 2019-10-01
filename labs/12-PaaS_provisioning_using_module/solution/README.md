
Setup GCP environment using `gcloud` tool

```console
vagrant@terraform-vm:~$ gcloud init
Welcome! This command will take you through the configuration of gcloud.

Your current configuration has been set to: [default]

You can skip diagnostics next time by using the following flag:
  gcloud init --skip-diagnostics

Network diagnostic detects and fixes local network connection issues.
Checking network connection...done.                                                                                                                                    
Reachability Check passed.
Network diagnostic passed (1/1 checks passed).

You must log in to continue. Would you like to log in (Y/n)?  Y

Go to the following link in your browser:

    https://accounts.google.com/o/oauth2/auth?code_challenge=naYo_8i7e95LKv1RHYgK1RZNnFXFZEoYPk5It0798bOdfY&prompt=select_account&code_challenge_method=S256&access_type=offline&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googl11eapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth


Enter verification code: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
You are logged in as: [name.surname@gmail.com]

Pick cloud project to use:
...
 [3] sny-oss-trf-01-01-00
...
Please enter numeric choice or text value (must exactly match list 
item):  3

Your current project has been set to: [sny-oss-trf-01-01-00]. 

Do you want to configure a default Compute Region and Zone? (Y/n)?  n

Created a default .boto configuration file at [/home/vagrant/.boto]. See this file and
[https://cloud.google.com/storage/docs/gsutil/commands/config] for more
information about configuring Google Cloud Storage.
Your Google Cloud SDK is configured and ready to use!

* Commands that require authentication will use name.surname@gmail.com by default
* Commands will reference project `sny-oss-trf-01-01-00` by default
Run `gcloud help config` to learn how to change individual settings

This gcloud configuration is called [default]. You can create additional configurations if you work with multiple accounts and/or projects.
Run `gcloud topic configurations` to learn more.

Some things to try next:

* Run `gcloud --help` to see the Cloud Platform services you can interact with. And run `gcloud help COMMAND` to get help on any gcloud command.
* Run `gcloud topic --help` to learn about advanced features of the SDK like arg files and output formatting
```

Now enable some GCloud services

```console
vagrant@terraform-vm:~$ gcloud services enable compute.googleapis.com
vagrant@terraform-vm:~$ gcloud services enable servicenetworking.googleapis.com
Operation "operations/acf.f4f17717-fed8-46bc-a4be-a0e351464caf" finished successfully.
vagrant@terraform-vm:~$ gcloud services enable cloudresourcemanager.googleapis.com
Operation "operations/acf.09b94de4-283f-4e0e-bcb9-539cb33e071e" finished successfully.
vagrant@terraform-vm:~$ gcloud services enable container.googleapis.com
```

After having changed the configurations within the `terraform.tfvars` file, provision the environment

```console
vagrant@terraform-vm:~$ terraform init
terraform init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
...
* provider.kubernetes: version = "~> 1.9"
* provider.null: version = "~> 2.1"
* provider.random: version = "~> 2.2"

Terraform has been successfully initialized!
```

```console
vagrant@terraform-vm:~$ terraform plan
...
Plan: 9 to add, 0 to change, 0 to destroy.
```

```console
vagrant@terraform-vm:~$ terraform apply
```

Provisioning may take up to 20 minutes depending on the number of worker nodes you specified.
After the provision ends, you can type the following command to generate the kubeconfig file on the VM (be sure to specify a correct value for **--region** and **--project** parameters)

```console
vagrant@terraform-vm:~$ gcloud beta container clusters get-credentials gke-cluster --region europe-west4 --project sny-oss-trf-01-01-00
```

To verify the cluster functionalities and the kubeconfig file setup, you may try the following commands:


```console
vagrant@terraform-vm:~$ ls -l /home/vagrant/.kube/config
-rw------- 1 vagrant vagrant 2483 Sep 30 15:06 /home/vagrant/.kube/config
```

```console
vagrant@terraform-vm:~$ kubectl cluster-info
Kubernetes master is running at https://34.90.62.248
calico-typha is running at https://34.90.62.248/api/v1/namespaces/kube-system/services/calico-typha:calico-typha/proxy
Heapster is running at https://34.90.62.248/api/v1/namespaces/kube-system/services/heapster/proxy
KubeDNS is running at https://34.90.62.248/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://34.90.62.248/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
Metrics-server is running at https://34.90.62.248/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
```

```console
vagrant@terraform-vm:~$ kuberang 
Kubectl configured on this node                                                 [OK]
Delete existing deployments if they exist                                       [OK]
Nginx service does not already exist                                            [OK]
BusyBox service does not already exist                                          [OK]
Nginx service does not already exist                                            [OK]
Issued BusyBox start request                                                    [OK]
Issued Nginx start request                                                      [OK]
Issued expose Nginx service request                                             [OK]
Both deployments completed successfully within timeout                          [OK]
Grab nginx pod ip addresses                                                     [OK]
Grab nginx service ip address                                                   [OK]
Grab BusyBox pod name                                                           [OK]
Accessed Nginx service at 10.78.3.123 from BusyBox                              [OK]
Accessed Nginx service via DNS kuberang-nginx-1569859822148851965 from BusyBox  [OK]
Accessed Nginx pod at 10.12.0.5 from BusyBox                                    [OK]
Accessed Nginx pod at 10.12.5.2 from BusyBox                                    [OK]
Accessed Nginx pod at 10.12.1.13 from BusyBox                                   [OK]
Accessed Nginx pod at 10.12.3.6 from BusyBox                                    [OK]
Accessed Google.com from BusyBox                                                [OK]
Accessed Nginx pod at 10.12.0.5 from this node                                  [ERROR IGNORED]
Accessed Nginx pod at 10.12.5.2 from this node                                  [ERROR IGNORED]
Accessed Nginx pod at 10.12.1.13 from this node                                 [ERROR IGNORED]
Accessed Nginx pod at 10.12.3.6 from this node                                  [ERROR IGNORED]
Accessed Google.com from this node                                              [OK]
Powered down Nginx service                                                      [OK]
Powered down Busybox deployment                                                 [OK]
Powered down Nginx deployment                                                   [OK]
```

```console
vagrant@terraform-vm:~$ kubectl get nodes
NAME                                              STATUS   ROLES    AGE   VERSION
gke-gke-cluster-default-node-pool-0d2388be-2jcr   Ready    <none>   14m   v1.14.6-gke.1
gke-gke-cluster-default-node-pool-0d2388be-vlgj   Ready    <none>   14m   v1.14.6-gke.1
gke-gke-cluster-default-node-pool-1acb282b-knsg   Ready    <none>   14m   v1.14.6-gke.1
gke-gke-cluster-default-node-pool-1acb282b-ns7n   Ready    <none>   14m   v1.14.6-gke.1
gke-gke-cluster-default-node-pool-89d4f3ad-7rxz   Ready    <none>   14m   v1.14.6-gke.1
gke-gke-cluster-default-node-pool-89d4f3ad-vt3t   Ready    <none>   14m   v1.14.6-gke.1
```

To schedule a Pod and see if the cluster works

```console
vagrant@terraform-vm:~$ kubectl apply -f deployment.yaml 
deployment.extensions/web created
service/web created
ingress.extensions/basic-ingress created
```

It may take a few minutes for GKE to allocate an external IP address and set up forwarding rules until the load balancer is ready to serve your application.

You can monitor the Ingress status using the following command:

```console
vagrant@terraform-vm:~$ kubectl get ingress basic-ingress
NAME            HOSTS   ADDRESS               PORTS   AGE
basic-ingress   *       35.201.110.0          80      3h40m
```

Note down the IP in the ADRESS column and use it to invoke the endpoint

```console
vagrant@terraform-vm:~$ curl http://35.201.110.0/
Hello, world!
Version: 1.0.0
Hostname: web-ddb799d85-txcxz
```