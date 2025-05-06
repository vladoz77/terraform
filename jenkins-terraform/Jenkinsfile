pipeline {
    agent any

    stages {
        stage('clean ws')
            step {
                cleanWs()
            }

        stage('git checout') {
            steps {
              git branch: 'main', credentialsId: 'github_token', url: 'https://github.com/vladoz77/terraform'
            }
        }
        
        stage('terraform') {
            steps {
                script {
                    withCredentials([
                        vaultString(credentialsId: 'cloud_id', variable: 'CLOUD_ID'), 
                        vaultString(credentialsId: 'folder_id', variable: 'FOLDER_ID'), 
                        vaultString(credentialsId: 'iam_token', variable: 'IAM_TOKEN')
                    ]) 
                    {
                        '''sh
                        terraform init
                        terraform apply -auto-approve \
                            -var "cloud_id=${env.CLOUD_ID}" \
                            -var "folder_id=${env.FOLDER_ID}" \
                            -var "token=${env.IAM_TOKEN}"
                        '''
                    }
                }
            }
        }
    }
}
