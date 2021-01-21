# Openshift Cluster Config
Setting up an OpenShift cluster using Kustomize and ArgoCD. More info coming soon.

HEAVILY borrowed from [the Red Hat Canadia team's repo](https://github.com/redhat-canada-gitops/cluster-config) :canada:


## Installing ArgoCD

> :warning: This is based on the argocd operator v0.0.12 using an "Automatic" update strategy on OpenShift 4.5.2

To install argocd using the operator, use this repo.

```
until oc apply -k https://github.com/Purple-Sky-Pirates/bd35-cluster-config/argocd/install; do sleep 2; done
```

This will start the installation of argocd. You can monitor the install with a `watch` on the following command.

```
oc get pods -n argocd
```

To get your argocd route (where you can login)

```
oc get route argocd-server -n argocd -o jsonpath='{.spec.host}{"\n"}'
```

## Deploying this Repo

To configure your cluster to this repo run

```
oc apply -k https://github.com/Purple-Sky-Pirates/bd35-cluster-config/cluster-config/config/overlays/default
```

This will configure your server with the following.

HTPasswd:

```
htpasswd -c -B -b ./users.htpasswd admin admin
htpasswd -b ./users.htpasswd ocp-admin admin
htpasswd -b ./users.htpasswd ocp-developer developer
htpasswd -b ./users.htpasswd ocp-marketing marketing
```

after

```
oc adm policy add-cluster-role-to-user admin admin
oc adm policy add-cluster-role-to-user admin ocp-admin
oc adm policy add-cluster-role-to-user edit developer
oc adm policy add-cluster-role-to-user view marketing


```

Cluster Configurations:
* HTPassword Authentication
  * Four users: `admin`, `ocp-admin`,`ocp-developer`, and `ocp-marketing`
* Three Groups created
  * `admins`
    * `ocp-admin` and `admin` is part of `admins`
  * `developer`
    * `ocp-developer` is part of `developer`
  * `marketing`
    * `ocp-marketing` is part of `marketing`
* ClusterRole/Role Bindings setup
  * `admins` group has `cluster-admin` on OpenShift
  * The `developer` group has `edit` on the `pricelist` namespace on OpenShift
* Container Security Operator installed

Application Deployments:
* Deploy Pricelist in an ArgoCD project called `pricelist`
  * One `application` running the frontend
  * Another `application` running the database
  * The 3rd `application` just creates the namespace called `pricelist`
  * The manifests for this app lives in my [gitops example repo](https://github.com/welshstew/gitops-examples)

ArgoCD Configurations
* ArgoCD is integrated with the OpenShift oAuth
* RBAC Policy
  * The `admins` OpenShift group is set up as ArgoCD admins
  * The `developer` OpenShift group is set up as ArgoCD users
  * ArgoCD admins can see and sync all ArgoCD Applications
* The `cluster-config` ArgoCD project has all "cluster wide" configurations
  * Can only be seen/synced by ArgoCD admins
* The `pricelist` ArgoCD project has all appliaction components to run the [Pricelist](https://github.com/Purple-Sky-Pirates/bd35-cluster-config) application
  * Can be seen/synced by ArgoCD admins or ArgoCD users
* Autosync is turned on

# How do I make changes

You don't, it's GitOps!

Jokes aside, the idea is to manage your cluster by pull request to the right repo. In a lot of instances, that means many PRs to many repos!



# Sealed Secrets

via Kustomize 

# Bootstrap Project 

1. Add the help repo if you dont already have it 

`helm repo add redhat-cop https://redhat-cop.github.io/helm-charts'

confirm you can access the project 'bootstrap-project'

$ helm search repo redhat-cop/bootstrap-project
NAME                        	CHART VERSION	APP VERSION	DESCRIPTION                                       
redhat-cop/bootstrap-project	0.0.7        	v0.0.1     	A Helm chart for deploying and managing Openshi...

1. We could create a local Chart and add the bootstrap-project as a dependency, however for variation we're going to deploy the project as-is and simply overwrite some of the local values. 

   - The Bootstrap project will create the following: 
     -  Namespaces:
        -  demo-cicd
           -  Bindings: 
              -  devs
              -  admin
        -  demo-dev
           -  Bindings: 
              -  devs
              -  admin
        -  demo-test 
             -  Bindings: 
              -  devs
              -  admin
     -  Creates Services Account 
        -  dummy-as

2. edit 'bootstrap-values' as required
   - NOTE: To view the possible values available use: 

    '$ helm show values redhat-cop/bootstrap-project'

3. login to OCP cluster if not already 
4. deploy via helm 

```
$helm template -f bootstrap-values.yaml redhat-cop/bootstrap-project | oc apply -f-
```

  You should see the following results: 
  
  ``` 
    namespace/demo-ci-cd created
    namespace/demo-dev created
    namespace/demo-test created
    serviceaccount/dummy-sa created
    rolebinding.rbac.authorization.k8s.io/demo-devs_edit_role created
    rolebinding.rbac.authorization.k8s.io/demo-admins_admin_role created
    rolebinding.rbac.authorization.k8s.io/dummy-sa_admin_role created
    rolebinding.rbac.authorization.k8s.io/demo-devs_edit_role created
    rolebinding.rbac.authorization.k8s.io/demo-admins_admin_role created
    rolebinding.rbac.authorization.k8s.io/dummy-sa_admin_role created
    rolebinding.rbac.authorization.k8s.io/demo-devs_edit_role created
    rolebinding.rbac.authorization.k8s.io/demo-admins_admin_role created
    rolebinding.rbac.authorization.k8s.io/dummy-sa_admin_role created 
  ```

# CICD Toolchain 

We're keeping it simple, the target is:  
 - Nexus as Artifact Repository
 - Jenkins peforming builds via OCP build agents 