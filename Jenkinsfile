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
          stage("Compile") {
	      when {
                not {
                    equals expected: true, actual: params.destroy
                }
              }
               steps {
                    sh "/usr/bin/mvn compile"
               }
          }
          stage("Unit test") {
	      when {
                not {
                    equals expected: true, actual: params.destroy
                }
              }		  
               steps {
                    sh "/usr/bin/mvn test"
               }
          }
	     
	  stage('SonarQube analysis') {
		when {
                not {
                    equals expected: true, actual: params.destroy
                }
              }	  
	       steps {
               withSonarQubeEnv('sonarserver') {
                   sh '/usr/bin/mvn sonar:sonar'
                   } // submitted SonarQube taskId is automatically attached to the pipeline context
	       }
          }
          
	  stage("Quality Gate"){
		      when {
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
                not {
                    equals expected: true, actual: params.destroy
                }
              }	  
               steps {
                     sh "/usr/bin/mvn package"
               }
          }
         stage("Docker build"){
	      when {
                not {
                    equals expected: true, actual: params.destroy
                }
              }		 
	       steps {
                    sh 'docker version'
                    sh 'docker build -t devopswithdeepak-docker-webapp-demo .'
                    sh 'docker image list'
                    sh 'docker tag devopswithdeepak-docker-webapp-demo deepak2717/devopswithdeepak-docker-webapp-demo:devopswithdeepak-docker-webapp-demo'
		
               }
          }
         stage("Docker Login") {
	      when {
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
                not {
                    equals expected: true, actual: params.destroy
                }
              }		 
               steps {
                     sh 'docker push  deepak2717/devopswithdeepak-docker-webapp-demo:devopswithdeepak-docker-webapp-demo'
                }
         }
         stage('Plan') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh 'terraform init -input=false'
                sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'

                sh "terraform plan -input=false -out tfplan "
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Approval') {
           when {
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
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh "terraform apply -input=false tfplan"
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
