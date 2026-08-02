Building a Fully Automated GitOps CI/CD Pipeline on Kubernetes: From Infrastructure to Deployment

Setting up a complete GitOps-driven CI/CD pipeline from scratch is one of the most rewarding endeavors in modern DevOps. By pairing infrastructure management tools, containerization, automated testing/building, and continuous delivery, we can turn manual deployment headaches into a seamless, automated flow.
In this project, we built a fully automated CI/CD pipeline from the ground up:

1. Infrastructure Provisioning: Spun up local Kubernetes (Minikube/Kind) using Terraform.
2. Containerization: Packaged a Python Flask time-printing application with Docker.
3. Packaging: Created a flexible Helm chart for managing Kubernetes manifests.
4. CI Automation: Set up GitHub Actions to automatically test, build, and push Docker images upon every push to main.
5. Continuous Delivery (GitOps): Integrated ArgoCD to monitor the GitHub repository and synchronize changes seamlessly into the Kubernetes cluster



The Architecture at a Glance
* Terraform $\rightarrow$ Provisions local Kubernetes infrastructure.

* Flask Application $\rightarrow$ A microservice exposing the current system time over HTTP.

* Docker & Docker Hub $\rightarrow$ Containerizes the app and hosts image versions.

* Helm $\rightarrow$ Packages the deployment, service, and configuration files into a reusable chart.

* GitHub Actions $\rightarrow$ Automates the CI process (build & push to Docker Hub).

* ArgoCD $\rightarrow$ Automates continuous delivery directly inside the Kubernetes cluster using Git as the source of truth.

  <img width="1536" height="1024" alt="ChatGPT Image Aug 2, 2026, 12_34_58 PM" src="https://github.com/user-attachments/assets/72765495-cc5a-4348-9c65-5a73043c9bf7" />

￼

Troubleshooting & Overcoming Key Project Roadblocks
Building an end-to-end pipeline rarely goes completely smooth on the first attempt. Throughout this journey, several real-world issues emerged during deployment and authentication. Special credit goes to Gemini AI, which acted as a real-time collaborative troubleshooting partner to diagnose, debug, and resolve these issues efficiently.
Here is a look back at the key technical hurdles we tackled together:

1. Docker Desktop & Architecture Compatibility Issues
* The Issue: Early in setup, Docker compatibility errors hit because of architecture mismatches between Apple Silicon vs. Intel Mac builds on macOS.

* The Fix: Identified that the local environment was running on an Intel-based MacBook Pro (2019 Intel Chip) and adjusted the Docker installation to match the Intel architecture.

  
<img width="1440" height="900" alt="Screenshot 2026-07-31 at 5 01 02 am" src="https://github.com/user-attachments/assets/33b516de-68f7-4cb6-b99f-d61dff33a163" />

￼
2. ArgoCD CLI Session & Network Expiration
* The Issue: When trying to register the GitHub repository with ArgoCD via CLI (argocd repo add), terminal operations threw invalid session: token signature is invalid and transport: failed to write client preface.

* The Fix: Re-authenticated the ArgoCD CLI using argocd login localhost:8081 --insecure and ensured the kubectl port-forward svc/argocd-server -n argocd 8081:443 background process remained active.

3. GitHub Secret Leaks & Token Management
* The Issue: Accidental leaks of Personal Access Tokens (PATs) occurred during raw terminal command runs.

* The Fix: Immediately revoked the compromised tokens inside GitHub Settings, generated fresh tokens with repo scopes, and switched to interactive prompt passing (argocd repo add ... --username <user>) so secrets were never displayed or saved in terminal history.

4. Git Repo Pathing Typos in ArgoCD
* The Issue: ArgoCD kept reporting repository not found even with valid credentials.

* The Fix: Corrected placeholder URLs (YOUR_REPO_NAME) and malformed Git paths (.../https:/...) to point precisely to the correct repository path ([https://github.com/oforotitodirichukwu-afk/complete-devops-project.git](https://github.com/oforotitodirichukwu-afk/complete-devops-project.git)).
￼
<img width="1440" height="900" alt="Screenshot 2026-07-31 at 5 00 00 am" src="https://github.com/user-attachments/assets/56020d61-6158-470e-b233-e48e5536dd17" />



<img width="1440" height="900" alt="Screenshot 2026-07-31 at 12 28 04 pm" src="https://github.com/user-attachments/assets/bb37dc8c-8d4f-4380-9f7d-2d8af158cb0a" />



￼

5. The "Degraded / Exit Code 0" Pod Health Loop
* The Issue: ArgoCD showed the pod status as Degraded and Completed (exit code 0).

* The Fix: The original app.py script ran once, printed the output, and exited immediately. Kubernetes Deployments expect processes to remain running continuously.


<img width="1440" height="900" alt="Screenshot 2026-07-31 at 5 06 59 am" src="https://github.com/user-attachments/assets/c8688735-02a2-4c95-aa7e-c7f54566ace1" />

￼

6. Python Indentation Bug in Flask Server
* The Issue: To fix the exiting container, we converted the script to a Flask web server listening on port 8080. However, the pod kept failing to serve traffic because the if __name__ == "__main__": block was accidentally indented inside the get_current_time() function under the return statement.


* The Fix: Corrected the indentation at the root of app.py so Flask could execute app.run(host="0.0.0.0", port=8080). Pushing this fix triggered our GitHub Actions pipeline to automatically build and push the new container image, bringing the ArgoCD pod health state straight to Healthy (Green).

  
<img width="1440" height="900" alt="Screenshot 2026-07-31 at 12 10 57 pm" src="https://github.com/user-attachments/assets/5ef3bf97-533a-4627-9dbf-79573037eb82" />

￼
Real-World Production Considerations
While this project successfully showcases core GitOps concepts, transitioning a setup like this into a high-scale production environment requires several additional layers:

* Comprehensive Testing: Production pipelines need unit tests, integration tests, and end-to-end (E2E) testing stages embedded into GitHub Actions before any image is built.

* Security & Vulnerability Scanning: Integrating tools like Trivy, Grype, or SonarQube to scan container images and code dependencies for vulnerabilities prior to deployment.

* Multi-Environment Promotion: Moving code through Dev $\rightarrow$ Staging $\rightarrow$ Production using environment-specific Git branches or directory structures in Helm/Kustomize.

* Deployment Gates & Approvals: Implementing manual approval steps, canary deployments, or blue/green strategies to minimise downtime and mitigate operational risk.

Conclusion

This project highlights the true power of combining Terraform, Docker, Helm, GitHub Actions, and ArgoCD into a single cohesive GitOps pipeline.
By offloading manual steps to automated workflows and utilizing Gemini AI for fast, effective troubleshooting when blockers arose, we established a clean foundation for managing and scaling cloud-native applications on Kubernetes.

