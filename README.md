\# CAP-46: Nginx Reverse-Proxy Failure Isolation

\# \& Safe Configuration Rollout



\## Project Overview



This project implements a reliable Nginx reverse-proxy

architecture with controlled configuration deployment,

failure detection, testing, and rollback.



\## Technology Stack



\- Java 21

\- Spring Boot 3

\- React

\- Vite

\- MySQL

\- Nginx

\- Docker

\- Docker Compose

\- Python

\- Bash

\- GitHub Actions

\- AWS EC2 Ubuntu



\## Architecture



\- Nginx acts as the public entry point.

\- React provides the frontend.

\- Spring Boot provides REST APIs.

\- MySQL stores application data.

\- Docker Compose manages application services.

\- Python scripts validate application health and routing.

\- GitHub Actions automates testing and deployment.



\## Key Objectives



1\. Configure path-based reverse proxy routing.

2\. Validate Nginx configurations before deployment.

3\. Detect backend availability failures.

4\. Implement safe configuration rollout.

5\. Maintain working configuration backups.

6\. Demonstrate rollback after deployment failure.

7\. Deploy the architecture on AWS EC2.



\## Project Status



Environment setup completed.

Implementation pending.

