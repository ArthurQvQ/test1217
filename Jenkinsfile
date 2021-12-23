node() {
    script {
            def URL_ASIAN_SPECT = 'https://github.com/asiainspection/'
            def CREDENT = '5540db2b-369e-4a48-820e-f0970c41dd9a'
            
            def infos = "${params.infos}".split(' ')
            
            for (info in infos) {
                name = info.trim().split('=')[0]
                version = info.trim().split('=')[1]
                cleanWs()
                try {
                    stage("${name}") {
                        // pull code from remote
                        git url: "${URL_ASIAN_SPECT}${name}.git",
                        credentialsId: CREDENT,
                        branch: "develop"
                        
                        withCredentials([usernamePassword(credentialsId: CREDENT, usernameVariable: "GIT_USERNAME", passwordVariable: "GIT_PASSWORD")]) {
                            // checkout develop branch
                            try {
                                sh 'git checkout arthur_develop'
                            } catch (err) {
                                sh 'git checkout -b arthur_develop'
                            }
                            
                            // some services need enter sub-directories
                            switch (name) {
                                case 'aca':
                                case 'CIA-NEW':
                                case 'IPTB-web':
                                    def packageJSON = readJSON file: 'package.json'
                                    packageJSON.version="${version}"
                                    File file = new File('package.json')
                                    file.write(packageJSON)
                                    break;
                                case 'auditor-app-services':
                                    sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./auditor-app-services-api/pom.xml";
                                    break;
                                case 'final-report-service':
                                    sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./FINAL-REPORT-SERVICE-services-api/pom.xml";
                                    break;
                                case 'IPTB-service':
                                    sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./IPTB-SERVICE-services-api/pom.xml";
                                    break;
                                case 'aiparams' :
                                    sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./parameter/pom.xml";
                                    break;
                                // case 'LT':
                                //     sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./FINAL-REPORT-SERVICE-services-api/pom.xml";
                                default:
                                    sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT";
                                    break;
                            }
                            
                            // update pom version
                            
                            sh 'git add .'
                            sh 'git commit -m "update pom version"'
                            sh 'git push origin arthur_develop'
                            
                            // checkout release branch
                            try {
                                sh "git checkout -b arthur_release-${version}"
                            } catch (err) {
                                sh "git checkout arthur_release-${version}"
                            }
                            sh "git push origin arthur_release-${version}"
                        }
                    }
                } catch (err) {
                    echo "error:${err}"
                    continue
                }
            }
        }
}