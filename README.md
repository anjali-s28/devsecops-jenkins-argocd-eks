# DevSecOps CI/CD Pipeline on AWS EKS with Jenkins, Terraform, SonarQube, Trivy and ArgoCD

A CI/CD pipeline that provisions an AWS EKS cluster with Terraform, builds and scans a Tetris web app with Jenkins, and deploys it to Kubernetes using ArgoCD (GitOps).

## Tech Stack

AWS (EC2, EKS), Terraform, Jenkins, SonarQube, Trivy, Docker, Kubernetes, ArgoCD

## Pipeline Flow

1. The Terraform pipeline in Jenkins creates the EKS cluster and node group in `ap-south-1`.
2. The CI pipeline pulls the application code from GitHub.
3. SonarQube analyzes the code, and the quality gate must pass.
4. `npm install` installs the dependencies.
5. Trivy scans the source files and dependencies.
6. Docker builds the image and pushes it to Docker Hub.
7. Trivy scans the built image.
8. Jenkins updates the image name in `deployment.yml` in the manifest repository and pushes the commit.
9. ArgoCD detects the change and syncs the new version to EKS automatically.
10. The application is served through an AWS LoadBalancer URL.

## Repository Structure

```
devsecops-jenkins-argocd-eks/
├── README.md
├── screenshots/
├── scripts/
│   ├── script1.sh                # Java, Docker, Jenkins
│   └── script2.sh                # Terraform, kubectl, AWS CLI, Trivy
├── terraform/
│   └── main.tf
├── pipelines/
│   ├── Jenkinsfile-terraform
│   ├── Jenkinsfile-tetris-v1
│   └── Jenkinsfile-tetris-v2
└── .gitignore
```

## Setup

1. Run the scripts in `scripts/` on an Ubuntu EC2 instance to install Java, Docker, Jenkins, Terraform, kubectl, AWS CLI and Trivy.
2. Add these credentials in Jenkins: `docker`, `github`, `sonar-token`.
3. Create the cluster by running the Terraform pipeline with `action = apply`.
4. Connect to the cluster:
   ```bash
   aws eks update-kubeconfig --name EKS_CLUSTER --region ap-south-1
   ```
5. Install ArgoCD and create an application that points to the manifest repository.
6. Run the application pipeline. ArgoCD deploys the app and exposes it through a load balancer.

To deploy version 2, run the v2 pipeline. It updates the manifest repository, and ArgoCD redeploys automatically.

## Cleanup

1. Delete the ArgoCD application and the ArgoCD load balancer.
2. Run the Terraform pipeline with `action = destroy`.
3. Terminate the EC2 instances and remove unused resources.

## Key Learnings

- Provisioning Kubernetes infrastructure with Terraform and Jenkins
- Building a pipeline with security gates (SonarQube quality gate, Trivy scans)
- GitOps: using Git as the single source of truth for deployments with ArgoCD
- Debugging cloud issues involving quotas, IAM, credentials and load balancers
- Controlling cost by tearing down EKS and load balancers in the correct order

