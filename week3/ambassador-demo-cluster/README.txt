# Ambassador Kubernetes Demo Environment with Telepresence

To start using your remote Kubernetes demo cluster, execute the `install.sh` script from a terminal.

    ./install.sh

This will check if `kubectl` and `telepresence` are installed and download them if they're missing.

The script will also clone the Git repository of our demo application, defaulting on the `nodejs` version.

## Demo Application Language

A different demo application can be cloned by specifying the `--stack` parameter. The valid values are:

- nodejs
- flask
- fast-api
- java
- go

For example, this will clone the `fast-api` version:

    ./install.sh --stack=fast-api

If you want to have more details regarding the script operation, use the `--verbose` parameter:

    ./install.sh --verbose

## Using the demo cluster

Once the ./install.sh script completes, a new shell will be started with the proper environment variables to allow interactions with the demo cluster.

Try running the following to see what's running in your cluster:
  kubectl get all

Try listing the services than can be intercepted with Telepresence:
  telepresence list

To step out of the demo cluster context, run:
  exit

To remove all the applications and files installed by this script in this directory, run the script with the --clean parameter.
  ./install.sh --clean
Before cleaning up, be sure to leave any shell instance created by the script using the `exit` command.

See our docs for more information: https://www.getambassador.io/docs/telepresence/latest/quick-start/
Reach out to us on Slack: https://a8r.io/Slack
