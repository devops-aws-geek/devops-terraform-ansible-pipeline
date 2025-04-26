pipeline {
     agent any
     parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')

    }


     environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
     stages {
          stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.BRANCH_NAME = env.GIT_BRANCH?.replaceFirst(/^origin\//, '')
                    echo "Branch after checkout: ${env.BRANCH_NAME}"
                }
                }
        }
          stage("Compile") {
	        when {
                 anyOf {
                     branch 'dev'
                     branch 'main'
                 }
                 not {
                    equals expected: true, actual: params.destroy
                 }
            }
               steps {
                    sh "/var/lib/jenkins/sw/maven/bin/mvn compile"
               }
          }
          stage("Unit test") {
	      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }        
                not {
                    equals expected: true, actual: params.destroy
                }
              }		  
               steps {
                    sh "/var/lib/jenkins/sw/maven/bin/mvn test"
               }
          }
	     
	  stage('SonarQube Analysis') {
		when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }        
                not {
                    equals expected: true, actual: params.destroy
                }
              }	  
	       steps {
               withSonarQubeEnv('sonarserver') {
                   sh '/var/lib/jenkins/sw/maven/bin/mvn sonar:sonar'
                   } // submitted SonarQube taskId is automatically attached to the pipeline context
	       }
          }
          
	  stage("Quality Gate"){
		      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }
                not {
                    equals expected: true, actual: params.destroy
                }
              }	  
	       steps {
		 script{      
                 timeout(time: 3, unit: 'MINUTES') { // Just in case something goes wrong, pipeline will be killed after a timeout
                 def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
                 if (qg.status != 'OK') {
                   error "Pipeline aborted due to quality gate failure: ${qg.status}"
                   }
                 }
		       }
	       }
           }
     
          stage("Package") {
		      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }  
                not {
                    equals expected: true, actual: params.destroy
                }
              }	  
               steps {
                     sh "/var/lib/jenkins/sw/maven/bin/mvn package"
               }
          }
         stage("Docker build"){
	      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }
                not {
                    equals expected: true, actual: params.destroy
                }
              }		 
	       steps {
              script {
                    sh 'docker version'
                    def tag = env.BRANCH_NAME.replace('/', '-')
                    sh 'docker build -t devopswithdeepak-docker-webapp-demo:${tag} .'
                    sh 'docker image list'
                    sh 'docker tag devopswithdeepak-docker-webapp-demo:${tag} deepak2717/devopswithdeepak-docker-webapp-demo:${tag}'
                }
            }
          }
         stage("Docker Login") {
	      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                } 
                not {
                    equals expected: true, actual: params.destroy
                }
              }		 
               steps {
	            withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'DOCKER_HUB_PASSWORD')]) {   
                     sh 'docker login -u deepak2717 -p $DOCKER_HUB_PASSWORD'
	            }
              }
         }

         stage("Push Image to Docker Hub"){
	      when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                }
                not {
                    equals expected: true, actual: params.destroy
                }
              }		 
               steps {
                  script {
                     def tag = env.BRANCH_NAME.replace('/', '-')
                     sh 'docker push  deepak2717/devopswithdeepak-docker-webapp-demo:${tag}'
                  }
                }
         }
         stage('Plan') {
            when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                  branch 'main'
                }
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                script {
                   def tfvarsFile = ""
                        if (env.BRANCH_NAME == 'dev') {
                            tfvarsFile = "dev.tfvars"
                        } else if (env.BRANCH_NAME == 'main') {
                            tfvarsFile = "main.tfvars"
                        } else if (env.BRANCH_NAME.startsWith('feature/')) {
                            tfvarsFile = "feature.tfvars"
                        } else {
                            error "No tfvars file defined for branch ${env.BRANCH_NAME}"
                        }    
                        sh 'terraform init -input=false'
                        sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'
                        sh "terraform plan -input=false -var-file=${tfvarsFile} -out tfplan "
                        sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }
        stage('Approval') {
           when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                  branch 'main'
                }
               not {
                   equals expected: true, actual: params.autoApprove
               }
               not {
                    equals expected: true, actual: params.destroy
                }
           }
           
                
            

           steps {
               script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
           }
       }

        stage('Apply') {
            when {
                anyOf {
                  branch 'feature'
                  branch 'dev'
                  branch 'main'
                }
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
               script {
                   def tfvarsFile = ""
                        if (env.BRANCH_NAME == 'dev') {
                            tfvarsFile = "dev.tfvars"
                        } else if (env.BRANCH_NAME == 'main') {
                            tfvarsFile = "main.tfvars"
                        } else if (env.BRANCH_NAME.startsWith('feature/')) {
                            tfvarsFile = "feature.tfvars"
                        } else {
                            error "No tfvars file defined for branch ${env.BRANCH_NAME}"
                        } 
                        sh "terraform apply -input=false -var-file=${tfvarsFile} tfplan"
               }
            }
        }
        
        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
        
        steps {
           sh "terraform destroy --auto-approve"
        }
    }

     }
  post {
     always {
          sh "echo 'I did It'"
     }
 }
}
