pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '992382545251'
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'calculator-app'
        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
        PROD_IP = '10.0.1.77'  
    }

    stages {
        stage('Login to AWS') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
            }
        }

        stage('Build & Push') {
            steps {
                sh "docker build -t ${IMAGE_URI}:latest ."
                sh "docker push ${IMAGE_URI}:latest"
            }
        }

        stage('Deploy to Prod') {
            steps {
                sshagent(['prod-server-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${PROD_IP} '
                            which docker || (sudo apt update && sudo apt install docker.io -y && sudo usermod -aG docker ubuntu && sudo chmod 666 /var/run/docker.sock)
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                            docker pull ${IMAGE_URI}:latest
                            docker stop calc-app || true
                            docker rm calc-app || true
                            docker run -d -p 5000:5000 --name calc-app ${IMAGE_URI}:latest
                        '
                    """
                }
            }
        }
    }
}
