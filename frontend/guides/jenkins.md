## Manual install

Jenkins LTS from its repository on Java 21. On Debian 13, as root:

```bash
apt update && apt install -y curl fontconfig openjdk-21-jre-headless
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key -o /usr/share/keyrings/jenkins.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt update && apt install -y jenkins git
systemctl enable --now jenkins
cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Docker

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts-jdk21
    container_name: jenkins
    restart: unless-stopped
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - ./jenkins_home:/var/jenkins_home
```

The unlock password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`.

## Using it

1. Open `http://<container-ip>:8080` and paste the unlock password from `/root/jenkins.creds`.
2. Choose **Install suggested plugins** and wait.
3. Create your admin user and confirm the Jenkins URL.
4. **New Item > Pipeline**: point it at a Git repository with a `Jenkinsfile`, or paste a pipeline script, for example:

```groovy
pipeline {
  agent any
  stages {
    stage('Build') { steps { sh 'echo Building...' } }
    stage('Test')  { steps { sh 'echo Testing...' } }
  }
}
```

5. Click **Build Now** and follow the console output.

Keep builds off the controller as you grow: add agents under **Manage Jenkins > Nodes**.
