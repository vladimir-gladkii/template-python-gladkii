# template-python
Python service template for reuse.

## Installation
<details>
<summary>Install Python 3.12 if it is not available in your package manager</summary>

These instructions are for Ubuntu 22.04. If you're on a different distribution,
or - God forbid! - Windows, you should adjust these accordingly.

Also, these instructions are about using Poetry with Pyenv-managed (non-system) Python.
 
### Step 1: Update and Install Dependencies
Before we install pyenv, we need to update our package lists for upgrades and new package installations. We also need to install dependencies for pyenv. 

Open your terminal and type:
```bash
sudo apt-get update
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

### Step 2: Install Pyenv
We will clone pyenv from the official GitHub repository and add it to our system path.
```bash
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
exec "$SHELL"
```

### Step 3: Install Python 3.12
Now that pyenv is installed, we can install different Python versions. To install Python 3.12, use the following command:
```bash
pyenv install 3.12
```

### Step 4: Connect Poetry to it
Do this in the template dir. Pycharm will automatically connect to it later
```bash
poetry env use ~/.pyenv/versions/3.12.1/bin/python
```
(change the version number accordingly to what is installed)

Finally, verify that Poetry indeed is connected to the proper version:
```bash
poetry enf info
```
</details>  

1. If you don't have `Poetry` installed run:
```bash
pip install poetry
```

2. Install dependencies:
```bash
poetry config virtualenvs.in-project true
poetry install --no-root --with dev,test
```

3. Install `pre-commit` hooks:
```bash
poetry run pre-commit install
```

4. Launch the project:
```bash
poetry run uvicorn app.main:app [--reload]
```
or do it in two steps:
```bash
poetry shell
uvicorn app.main:app
```

5. Running tests:
```bash
poetry run pytest
```

You can test the application for multiple versions of Python. To do this, you need to install the required Python versions on your operating system, specify these versions in the tox.ini file, and then run the tests:
```bash
poetry run tox
```

## Package
To generate and publish a package on pypi.org, execute the following commands:
```bash
poetry config pypi-token.pypi <pypi_token>
poetry build
poetry publish
```

pypi_token - API token for authentication on PyPI. https://pypi.org/help/#apitoken

## Docker
Build a docker image and run a container:
```bash
docker build . -t <image_name>:<image_tag>
docker run <image_name>:<image_tag>
```

Upload the Docker image to the repository:
```bash
docker login -u <username>
docker push <image_name>:<image_tag>
```

https://docs.docker.com/

## Helm chart
Authenticate your Helm client in the container registry:
```bash
helm registry login <repo_url> -u <username>
```

Create a Helm chart:
```bash
helm package charts/<chart_name>
```

Push the Helm chart to container registry:
```bash
helm push <helm_chart_package> <repo_url>
```

Deploy the Helm chart:
```bash
helm repo add <repo_name> <repo_url>
helm repo update <repo_name>
helm upgrade --install <release_name> <repo_name>/<chart_name>
```

https://helm.sh/ru/docs/

## OpenaAPI schema
To manually generate the OpenAPI schema, execute the command:
```bash
poetry run python ./tools/extract_openapi.py app.main:app --app-dir . --out openapi.yaml --app_version <version>
```

## Release
To create a release, add a tag in GIT with the format a.a.a, where 'a' is an integer.
The release version for branches, pull requests, and other tags will be generated based on the last tag of the form a.a.a.

## GitHub Actions
GitHub Actions triggers testing, builds, and application publishing for each release.  
https://docs.github.com/en/actions  

You can set up automatic testing in GitHub Actions for different versions of Python. To do this, you need to specify the set of versions in the .github/workflows/test_and_build.yaml file. For example:
```yaml
strategy:
  matrix:
    python-version: ["3.10", "3.11", "3.12"]
```

The process of building and publishing differs for web services and libraries.

### Web service
The default build and publish process is configured for a web application (.github\workflows\build_web.yaml).
During this process, a Docker image is built, a Helm chart is created, an openapi.yaml is generated, and the web service is deployed to a Kubernetes cluster.

**Initial setup**  
Create the branch gh-pages and use it as a GitHub page https://pages.github.com/.  
Set up secrets at `https://github.com/<workspace>/<project>/settings/secrets/actions`:
1. DOCKER_IMAGE_NAME - The name of the Docker image for uploading to the repository.
2. DOCKER_USERNAME - The username for the Docker repository on https://hub.docker.com/.
3. DOCKER_PASSWORD - The password for the Docker repository.
4. AWS_ACCESS_KEY_ID - AWS Access Key ID. https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html
5. AWS_SECRET_ACCESS_KEY - AWS Secret Access Key
6. AWS_REGION - AWS region. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/
7. EKS_CLUSTER_ROLE_ARN - The IAM role's ARN in AWS, providing permissions for managing an Amazon EKS Kubernetes cluster.
8. EKS_CLUSTER_NAME - Amazon EKS Kubernetes cluster name.
9. EKS_CLUSTER_NAMESPACE - Amazon EKS Kubernetes cluster namespace.
10. HELM_REPO_URL - `https://<workspace>.github.io/<project>/`

**After execution**  
The OpenAPI schema and the Helm chart will be available at `https://github.com/<workspace>/<project>/releases/`.  
The index.yaml file containing the list of Helm charts will be available at `https://<workspace>.github.io/<project>/charts-repo/index.yaml`. You can this URL on https://artifacthub.io/.

### Library
To change the build process for the library, you need to replace the nested workflow `./.github/workflows/build_web.yaml` to `./.github/workflows/build_lib.yaml` in `.github/workflows/test_and_build.yaml`:
```yaml
build:
  needs: [test]
  secrets: inherit
  uses: ./.github/workflows/build_lib.yaml
```

After that, during the build process, the package will be built and published on pypi.org.  
Uploading the package to pypi.org only occurs when a.a.a release is created.

**Initial setup**  
Set up a secret token for PyPI at `https://github.com/<workspace>/<project>/settings/secrets/actions`.
https://pypi.org/help/#apitoken

**After execution**  
A package will be available at `https://github.com/<workspace>/<project>/releases/` and pypi.org. 

## Act
You can run your GitHub Actions locally using https://github.com/nektos/act. 

Usage example:
```bash
act push -j deploy --secret-file my.secrets
```

## Classy-FastAPI
Classy-FastAPI allows you to easily do dependency injection of 
object instances that should persist between FastAPI routes invocations,
e.g. database connections.
More on that (with examples) at [Classy-FastAPI GitLab page](https://gitlab.com/companionlabs-opensource/classy-fastapi).

# Collaboration guidelines
HIRO uses and requires from its partners [GitFlow with Forks](https://hirodevops.notion.site/GitFlow-with-Forks-3b737784e4fc40eaa007f04aed49bb2e?pvs=4)
