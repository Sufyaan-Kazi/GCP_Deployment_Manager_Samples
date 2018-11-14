- [GCP_Deployment_Manager_Samples](#gcp-deployment-manager-samples)
  * [Disclaimer: Don't take this as gospel!!](#disclaimer--don-t-take-this-as-gospel--)
  * [What is this?](#what-is-this-)
  * [Tidy Up](#tidy-up)
  * [Known Issues](#known-issues)
  * [What does this deploy?](#what-does-this-deploy-)
  * [To Do](#to-do)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# GCP_Deployment_Manager_Samples
Sample (Non Production) repo to deploy a 3 tier web app to GCP using Deployment Manager

## Disclaimer: Don't take this as gospel!!
These scripts are an example of how to use Deployment Manager to deploy a 3 tier web-app, specifically this web app: https://github.com/Sufyaan-Kazi/spring-boot-cities-service and this one: https://github.com/Sufyaan-Kazi/spring-boot-cities-ui. They are not a BEST practice way of doing it and certainly should NOT be used  AS IS in PRODUCTION!

## What is this?
There are two scripts - one "generic" ish script called ```dmFunctions.sh``` and another which is very specific, i.e. deploys the microservices ``deployCitiesMicroservices.sh``. 

The basic logic is as follows, execute deployCitiesMicroservices.sh, this will:
* Load variables from vars.txt
* Reads the common GCP functions into memory (dmFunctions.sh)
* Starts a timer
* Calls the cleanup script to delete any previous GCP components for these
  microservices
* Use gsutil to create a bucket in Cloud Storage
* Create a VPC Network
    - This calls a function within the script, but the actual work to construct
      a VPC network is common and not specific to this app, so it invokes the
      function from the dmFunctions.sh shell script.
    - This creates a custom VPC Network and subnet for the region defined in
      vars.properties
* Deploy the back end Microservice cities-service
    - This copies the startup script required by the Compute Instances of this
      microservice into cloud storage
    - Creates a Regional InstanceGroup in this subnet
    - Creates an Internal Load Balancer to front traffic to this Instance Group
* Deploy the front end Microservice cities-ui
    - This copies the startup script required by Compute Instances of this
      microservice into cloud storage
    - Creates a Regional InstanceGroup in this subnet
    - Sleeps for 2 minutes to enable apt-get to complete and for the application
      to start up
    - Creates an HTTP Load Balancer to diret traffic to this Instance Group
* Create the Firewall rules
    -  Creates the firewall rule to allow the Healthcheck from the Internal Load
       Balancer to reach the back-end Microservice (cities-service)
    -  Creates the firewall rules to allow external HTTP traffic as well as the
       healthcheck to access the cities-ui Microservice
    - Creates the Firewall rule that allows http REST calls from cities-ui to
      cities-service
    - Waits while the backends and front-ends stabilise and are marked as
      healthy in the respective load balancers
* Try to launch a browser to hit the web site
* Displays completion message with time for how long it took

Since this is not using containers, K8S or a PaaS, it could take about 20
minutes to completely execute. 

The automation uses jinja templates. For example, the 'it.jinja' file is a template to deploy a compute instance, since it is a template it has placeholders for parameters like instance name, network etc.

When ```deployCitiesMicroServices.sh``` is run, it reads in variables from the file 'vars.properties' which defines properties like network, instance name etc and these become shell variables, which can then be passed to the call to the deployment manager with each template.

In a real world, these two microservices would actualy be deployed as containers using K8S, PCF, OpenShift or a.n.other. This is an example of how to automate deployment in a non-containersied world using pure IaaS on GCP.

N.B. The sub-directory 'old' is an example of deployment NOT using jinja and just plain old yaml for all the objects. In this method there is a lot of duplication of yaml .....

## Tidy Up
To remove all the deployments made by this script, run ```cleanup.sh```. When you run ```deployCitiesMicroserVice.sh```, it calls this script anyway.

## Known Issues
If you deploy this to a GCP project that has some kind of auotmated firewall enforcement to stop all instances having external access by default etc, then the app will still deploy and be reachable correctly. However, the startup will be longer and may need an additional 5-10 minutes to be completely ready even after the script finishes.

## What does this deploy?
![Cities](/DepManager.png)

* An instance group with health-checks, autoscaling etc for the cities-service microservice, including an internal TCP load balancer to distribute traffic over this group.
* An instance group with health-checks, autoscaling etc for the cities-ui microservice, including an external HTTP load balancer to distribute traffic to this web layer
* Firewall rules to allow the web layer to communicate with the back-end layer
* Firewall rules to enable both health-checks and load balancers to communicate with each of their instance groups

## To Do
* Modify the script to create an instance image for the common aspects of the compute instances, and make the two instances refer to that image as the source, to reduce startup time and duplication.
* Insert some kind of discovery service layer so the ip address of the internal load balancer is invisible to the web layer
* Remove the need to "discover" the ip address of the internal load balancer and to "inject" it into the deployment of the cities-ui as a dependency
* Use CloudSQL or a.n.other as the third tier rather than H2 as the Spring Boot apps currently do
* Serve the static content from a bucket and dynamic content from compute, with CDN layer in front.
