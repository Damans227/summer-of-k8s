#!/bin/bash
STACK="nodejs"
FAST_API_REPOSITORY="https://github.com/datawire/edgey-corp-python-fastapi.git"
FLASK_REPOSITORY="https://github.com/datawire/edgey-corp-python.git"
NODEJS_REPOSITORY="https://github.com/datawire/edgey-corp-nodejs.git"
GOLANG_REPOSITORY="https://github.com/datawire/edgey-corp-go.git"
JAVA_REPOSITORY="https://github.com/datawire/edgey-corp-java.git"

KUBECTL_MACOS_PATH="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
KUBECTL_LINUX_PATH="https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl"
TELEPRESENCE_MACOS_PATH="https://app.getambassador.io/download/tel2/darwin/amd64/latest/telepresence"
TELEPRESENCE_LINUX_PATH="https://app.getambassador.io/download/tel2/linux/amd64/latest/telepresence"
KUBECTL_BIN_PATH=${KUBECTL_MACOS_PATH}
TELEPRESENCE_BIN_PATH=${TELEPRESENCE_MACOS_PATH}

TELEPRESENCE_MACOS_VERSION_PATH="https://datawire-static-files.s3.amazonaws.com/tel2/darwin/amd64/stable.txt"
TELEPRESENCE_LINUX_VERSION_PATH="https://datawire-static-files.s3.amazonaws.com/tel2/linux/amd64/stable.txt"
TELEPRESENCE_VERSION_PATH=$TELEPRESENCE_MACOS_VERSION_PATH

FAST_API_DIR="edgey-corp-python-fastapi"
FLASK_DIR="edgey-corp-python-flask"
NODEJS_DIR="edgey-corp-nodejs"
GOLANG_DIR="edgey-corp-go"
JAVA_DIR="edgey-corp-java"

DATA_PROCESSING_DIR="DataProcessingService"

CURRENT_DIRECTORY=$(pwd)

VERBOSE="false"

# this function will download the lastest version of telepresence a replaced the installed by the user
update_telepresence(){
  if [ $VERBOSE = "flase" ]; then
    $(sudo curl -s -fL $TELEPRESENCE_BIN_PATH -o $(which telepresence))
  else
    $(sudo curl -fL $TELEPRESENCE_BIN_PATH -o $(which telepresence))
  fi
}

# this function read the version of telepresence which is installed in the computer
parse_telepresence_version(){
  local installed_version=$(telepresence version)
  local substring_to_match="Client v"
  installed_version=${installed_version#*$substring_to_match}
  echo ${installed_version%(*}
}

# this function will remove all the software installed in the current directory
clean(){
  if [ $VERBOSE = "false" ]; then
    # remove demo applications
    rm -rf edgey-* > /dev/null
    # remove telepresence and kubectl
    rm -rf bin > /dev/null
    # remove virtualenv
    rm -rf env > /dev/null
  else
    # remove demo applications
    rm -rf edgey-*
    # remove telepresence and kubectl
    rm -rf bin
    # remove virtualenv
    rm -rf env
  fi
}

# Validate if the telepresence version is supported for the demo.
# Requires one parameter, telepresence version to compare with LATEST_TELEPRESENCE_VERSION
# returns true when the telepresence version provided by the user is minor than the LATEST_TELEPRESENCE_VERSION
validate_telepresence_version(){
  if [ $1 = $LATEST_TELEPRESENCE_VERSION ]; then
    echo "false"
    return
  else
    local IFS=.
    local i ver1=($LATEST_TELEPRESENCE_VERSION) ver2=($1)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo "true"
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo "false"
            return
        fi
    done
  fi
  echo "false"
}

# Ask for user confirmation. Needs a parameter to prompt a message for the user
# returns 1 when the user confirm with Y or 0 when the user select N
confirm(){
  while true; do
    read -r -n 1 -p $'\n'"${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY])
        echo "true"
        return
        ;;
      [nN])
        echo "false"
        return
        ;;
    esac
  done
}

clone_repo(){
	# Cloning repository to temporal directory and overwritting the specific folder
	echo "Cloning repository from $REPO_TO_USE"
  if [ $VERBOSE = "false" ]; then
    rm -rf ${DIR_TO_USE} > /dev/null
    git clone --quiet ${REPO_TO_USE} ${DIR_TO_USE}
  else
    rm -rf ${DIR_TO_USE}
    git clone ${REPO_TO_USE} ${DIR_TO_USE}
  fi
}

analyze_dependencies_go(){
	if  [ -x "$(command -v go)" ]; then
    local continue="$(confirm "Several dependencies will be installed using go in the current project without affecting the rest of the system")"
    echo " "
    if [ $continue = "true" ]; then
      cd ${GOLANG_DIR}/${DATA_PROCESSING_DIR}
      # Install fresh for auto refresh
      if [ $VERBOSE = "false" ]; then
        go get github.com/pilu/fresh > /dev/null
      else
        go get github.com/pilu/fresh
      fi
      cd $CURRENT_DIRECTORY
    else
      exit
    fi
	else
		echo "To continue with go as stack please install golang compiler. Go to https://golang.org/dl/ for more information"
		exit
	fi
}

analyze_dependencies_nodejs(){
	if  [ -x "$(command -v npm)" ]; then
    local continue="$(confirm "Several dependencies will be installed using npm in the current project without affecting the rest of the system")"
    echo " "
    if [ $continue = "true" ]; then
		  cd ${NODEJS_DIR}/${DATA_PROCESSING_DIR}
		  # install dependencies
      if [ $VERBOSE = "false" ]; then
		    npm install --silent > "/dev/null" 2>&1
		  else
		    npm install
		  fi
		  cd $CURRENT_DIRECTORY
		else
		  exit
		fi
	else
		echo "To continue with nodejs as stack please install nodejs. Go to https://nodejs.org/en/download/ for more information"
		exit
	fi
}

analyze_dependencies_python(){
	if  [ -x "$(command -v python3)" ]; then
		if  [ -x "$(command -v pip3)" ]; then
      local continue="$(confirm "A new virtual environment will be created on the current project and several dependencies will be installed using pip in the current project without affecting the rest of the system")"
      echo " "
      if [ $continue = "true" ]; then
        # create and active a virtual environment
        if [ $VERBOSE = "false" ]; then
          python3 -m venv env > /dev/null
          source env/bin/activate > /dev/null
        else
          python3 -m venv env
          source env/bin/activate
        fi
      else
        exit
      fi
		else
			echo "In order to install dependencies for the demo, please install pip."
			exit
		fi
	else
		echo "To continue with python as stack please install python3. Go to https://www.python.org/downloads/ for more information"
		exit
	fi
}

analyze_dependencies_flask(){
	analyze_dependencies_python
	# install dependencies
  if [ $VERBOSE = "false" ]; then
	  pip --disable-pip-version-check install --no-warn-script-location flask requests > /dev/null
	else
	  pip install --no-warn-script-location flask requests
	fi
}

analyze_dependencies_fast_api(){
	analyze_dependencies_python
	# install dependencies
  if [ $VERBOSE = "false" ]; then
	  pip --disable-pip-version-check install --no-warn-script-location fastapi uvicorn requests > /dev/null
	else
	  pip install --no-warn-script-location fastapi uvicorn requests
	fi
}

analyze_dependencies_java(){
	if  [ -x "$(command -v javac)" ]; then
		if ! [ -x "$(command -v mvn)" ]; then
			echo "In order to install dependencies for the demo, please install mvn. Go to https://maven.apache.org/install.html for more information."
			exit
		fi
	else
		echo "To continue with java as stack please install java. Go to https://java.com/en/download/ for more information"
		exit
	fi
}

# Select
if [ "$(uname)" == "Darwin" ]; then
	KUBECTL_BIN_PATH=${KUBECTL_MACOS_PATH}
	TELEPRESENCE_BIN_PATH=${TELEPRESENCE_MACOS_PATH}
	TELEPRESENCE_VERSION_PATH=${TELEPRESENCE_MACOS_VERSION_PATH}
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	KUBECTL_BIN_PATH=${KUBECTL_LINUX_PATH}
	TELEPRESENCE_BIN_PATH=${TELEPRESENCE_LINUX_PATH}
	TELEPRESENCE_VERSION_PATH=${TELEPRESENCE_LINUX_VERSION_PATH}
fi

# Get specific stack selected by the user, by default will be nodejs
for arg in "$@"
do
	case $arg in
		-s=*|--stack=*)
			STACK="${arg#*=}"
			shift
			;;
	  -h|--help)
	    cat README.txt
	    exit
	    ;;
	  -v|--verbose)
	    VERBOSE="true"
	    ;;
	  --clean)
	    clean
	    exit
	    ;;
		*)
			echo "No valid argument ${arg}"
			exit
			;;
	esac
done

# Get repository
case $STACK in
  nodejs)
    echo "nodejs selected"
    REPO_TO_USE=$NODEJS_REPOSITORY
    DIR_TO_USE=$NODEJS_DIR
    clone_repo
    analyze_dependencies_nodejs
    ;;
  flask)
    echo "python with flask selected"
    REPO_TO_USE=$FLASK_REPOSITORY
    DIR_TO_USE=$FLASK_DIR
    clone_repo
    analyze_dependencies_flask
    ;;
  fast-api)
    echo "python with fast-api selected"
    REPO_TO_USE=$FAST_API_REPOSITORY
    DIR_TO_USE=$FAST_API_DIR
    clone_repo
    analyze_dependencies_fast_api
    ;;
  java)
    echo " java selected"
    REPO_TO_USE=$JAVA_REPOSITORY
    DIR_TO_USE=$JAVA_DIR
    clone_repo
    analyze_dependencies_java
    ;;
  go)
    echo "go selected"
    REPO_TO_USE=$GOLANG_REPOSITORY
    DIR_TO_USE=$GOLANG_DIR
    clone_repo
    analyze_dependencies_go
    ;;
  *)
    echo "Invalid stack selected ${STACK}"
    exit
    ;;
esac

# Get the latest version of telepresence
LATEST_TELEPRESENCE_VERSION="$(curl -s $TELEPRESENCE_VERSION_PATH)"
# Check if telepresence exists, if not install in this folder
echo " "
if ! [ -x "$(command -v telepresence)" ]; then
	if ! [ -f ./bin/telepresence ]; then
		echo "Installing telepresence"
		if [ $VERBOSE = "false" ]; then
		  mkdir -p ./bin > /dev/null
		  curl -s -LO ${TELEPRESENCE_BIN_PATH}
		  chmod a+x ./telepresence > /dev/null
		  mv ./telepresence ./bin/telepresence > /dev/null
		else
		  mkdir -p ./bin
		  curl -LO ${TELEPRESENCE_BIN_PATH}
		  chmod a+x ./telepresence
		  mv ./telepresence ./bin/telepresence
		fi
		echo "Telepresence is installed"
	else
		echo "Telepresence is installed at current directory"
	fi
else
  current_version="$(parse_telepresence_version)"
  need_update="$(validate_telepresence_version $current_version)"
  if [ $need_update = "true" ]; then
    install_update=$(confirm "A new version of telepresence is detected. Do you want to install the update.")
    echo " "
    if [ $install_update = "true" ]; then
      update_telepresence
    else
      echo "The telepresence version installed on this computer needs to be updated. Visit https://www.getambassador.io/docs/telepresence/latest/install/upgrade/ for more details."
      exit
    fi
  else
	  echo "Telepresence is detected in this computer"
	fi
fi

# Check if kubectl exists, if not install in this folder
if ! [ -x "$(command -v kubectl)" ]; then
	if ! [ -f ./bin/kubectl ]; then
		echo "Installing kubectl in current directory"
		if [ $VERBOSE = "false" ]; then
  		mkdir -p ./bin >/dev/null
	  	curl -s -LO ${KUBECTL_BIN_PATH}
		  chmod a+x ./kubectl > /dev/null
		  mv ./kubectl ./bin/kubectl > /dev/null
		else
  		mkdir -p ./bin
	  	curl -LO ${KUBECTL_BIN_PATH}
		  chmod a+x ./kubectl
		  mv ./kubectl ./bin/kubectl
		fi
		echo "kubectl is installed"
	else
		echo "kubectl is installed at current directory"
	fi
else
	echo "kubectl is detected in this computer"
fi

# Export configuration
env_vars="export KUBECONFIG=${CURRENT_DIRECTORY}/kubeconfig.yaml"
path="export PATH=\"$PATH:${CURRENT_DIRECTORY}/bin\""
eval $env_vars
eval $path

echo ""
echo "Setup complete!"
echo ""
echo "A new shell will now be started with the proper environment variables to allow interactions with the demo cluster."
echo ""
echo "Try running the following to see what's running in your cluster:"
echo "  kubectl get all"
echo ""
echo "Try listing the services than can be intercepted with Telepresence:"
echo "  telepresence list"
echo ""
echo "To step out of the demo cluster context, run:"
echo "  exit"
echo ""
echo "To remove all the applications and files installed by this script in this directory, run the script with the parameter --clean."
echo "  ./install.sh --clean"
echo "Before clean be sure to leave any shell instance created by the script using exit command."
echo ""
echo "Visit our docs for more information on how to leverage Telepresence: https://www.getambassador.io/docs/telepresence/latest/quick-start/"
echo "Reach out to us on Slack: https://a8r.io/Slack"

# run a new bash with a configuration set
eval $SHELL
