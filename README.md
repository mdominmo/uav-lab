# UAV LAB

This repository aims to create a container-based simulation environment for unmanned aerial vehicles (UAV). The main focus is to avoid the developers to struggle with dependencies between the different tools that involve SITL simulations decoupling
the major parts. This environment is thought to be deployed on top of a container orchestrator like Kubernetes. 

## Releases
![release](https://img.shields.io/badge/version-0.0.1-blue)

## Features
In this repository you will find the Dockerfiles to generate the different container images that are in use:
- PX4 SITL
- Gazebo Sim (Harmonic)
- Micro-XRCE-DDS 

## Requirements
- Docker (For image building)
- A Kubernetes distribution (K0S recommended).

