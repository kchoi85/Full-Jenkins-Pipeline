pipeline{

	agent any


    triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: true, triggerOnNoteRequest: true, branchFilterType: 'All', secretToken: "abcdefghijklmnopqrstuvwxyz0123456789ABCDEF" )
    }



	stages{

        stage('Pulling GitLab Repository'){
          steps{
            script{
              git credentialsId: 'GitLab_credentials', url: 'https://git.fdmgroup.com/Kihoon.Choi/test-project.git'
            }
          }
          post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Git Pull successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
              }
            }
        }
        
        stage('Compile Stage'){
			steps{
				bat "mvn compile"
			}
			post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Compile stage successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
              }
            }
		}
  
		stage('Test-Compile Stage'){
			steps{
				bat "mvn test compile"
			}
			post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Test-compile stage successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
                }
            }
		}

		stage('Quality-Gate (SonarQube) Stage'){
			steps{
				bat "mvn verify"
				bat "mvn sonar:sonar \
                  -Dsonar.projectKey=Jenkinsfile_pipeline \
                  -Dsonar.host.url=http://localhost:9000 \
                  -Dsonar.login=ae14dc106e5443e85576063c3dd70a2df0fe7023"
			}
			post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Quality Gate successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
                }
            }
		}

		stage('Package Stage'){
			steps{
				bat "mvn package -Dmaven.test.skip=true"
			}
			post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Pacakage stage successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
                }
            }
		}

		stage('Deploy (Nexus) Stage'){
			steps{
				echo "deploying to tomcat container"
                deploy adapters: [tomcat8(credentialsId: 'tomcat_credentials', path: '', url: 'http://localhost:8088/')], contextPath: 'pipeline_webapp', war: '**/*.war'
		        nexusPublisher nexusInstanceId: 'SonatypeNexus', nexusRepositoryId: 'solo-project-nexus', packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: 'C:\\Program Files (x86)\\Jenkins\\workspace\\fullpipeline\\target\\JspExample-0.0.1-SNAPSHOT.war']], mavenCoordinate: [artifactId: 'solo-project-nexus', groupId: 'com.fdmgroup.com', packaging: 'war', version: '${BUILD_NUMBER}']]]
		    }
		    post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Deploy and Nexus stage successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
                }
            }
		}
		
		stage('Pulling war file from Nexus Repository'){
		    steps{
		        bat "curl -u admin:admin -X GET http://localhost:8081/repository/solo-project-nexus/com/fdmgroup/com/solo-project-nexus/%BUILD_NUMBER%/solo-project-nexus-%BUILD_NUMBER%.war --output target/JspExample-0.0.2-SNAPSHOT.war"
		    }
		    post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Pull request successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed"
                }
            }
		
		}

		stage('Build and Deploy Tomcat Container (8888)'){
            steps{
                bat "docker build -t myappcontainer ."
                bat "docker run -d -p 8888:8080 myappcontainer"
            }
            post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Build and Deploy successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed!"
                }
            }	
        } 
        
        stage('Push container to DockerHub'){
            steps{
                bat "docker logout"
                bat "docker tag myappcontainer kchoi85/jenkinspipeline:latest"
                bat "docker login -u kchoi85 -p Zjsxyks9! docker.io"
                bat "docker push kchoi85/jenkinspipeline:latest"
            }
            post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Push to dockerhub successful!"
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed!"
                }
            }	
        } 
        
        stage('Selenium Cucumber Test on Container (QA Env)'){
            steps{
                script{
                    git credentialsId: 'GitLab_credentials', url: 'https://git.fdmgroup.com/Kihoon.Choi/solo-project-cucumber.git'
                }
                bat "mvn clean test"
            }
            post{
              always{
                echo "Stage complete"
              }
              success{
                echo "Test cases successful!"
                cucumber failedFeaturesNumber: -1, failedScenariosNumber: -1, failedStepsNumber: -1, fileIncludePattern: '**/*.json', jsonReportDirectory: 'target/', pendingStepsNumber: -1, skippedStepsNumber: -1, sortingMethod: 'ALPHABETICAL', undefinedStepsNumber: -1
              }
              failure {
			    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
                }
              unstable{
			    echo "Unstable build... stage failed!"
                }
            }	
        } 
        
        
	
	} // end of staqges

	post{
		always{
			echo "Pipeline has been ran"
		}
		success{
			echo "Full pipeline tested... build successful!"
			emailext body: 'Full Jenkins pipeline was deployed successfully', subject: 'Deploy Successful!', to: 'davidchoi0304@gmail.com'
			
		}
        failure {
		    emailext body: 'Stage: ${env.JOB_NAME} build failed!', subject: 'Deploy failed!', to: 'davidchoi0304@gmail.com'
        }
		unstable{
			echo "Pipeline build has failed!"
		}
	}

}