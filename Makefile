all:
	podman build --jobs 0 --pull --rm -f "Dockerfile" -t us-docker.pkg.dev/jarvice/images/app-qlm:2024-11-08 "."

push: all
	podman push us-docker.pkg.dev/jarvice/images/app-qlm:2024-11-08
