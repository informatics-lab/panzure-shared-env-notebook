A container for running pangeo on our shared environment set up. 

The container assumes that environments will be available under the /env directory. 

Specifically there needs to be a environment at `/envs/infrastructure/lab` that can run Jupyter Lab under a Jupyter Hub system.

In our system (at time of writing) the container unfortunately runs as root and there are concessions made to this in the container. 
This should be resolved in the future.
