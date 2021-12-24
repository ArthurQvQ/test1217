node() {
    script {
        def URL_ASIAN_SPECT = 'https://github.com/asiainspection/'
        def CREDENT = '5540db2b-369e-4a48-820e-f0970c41dd9a'
        
        def infos = params.infos.trim().replace('Back End=', '').replace('Front End=', '').split(' ')
        def branch_var = 'arthur_'
        
        for (info in infos) {            
            cleanWs()

            // skip when info doesn't exist
            info = info.trim()
            if (!info || info == 'BACK' || info == 'FRONT') {
                continue
            }

            name = info.split('=')[0]
            dev_branch = 'develop'
            
            if (info.split('=')[1] && info.split('=')[1].split('-')[1]) {
                if (name == 'commons') {
                    version = info.split('=')[1].split('-')[0]
                } else {
                     version = info.split('=')[1].split('-')[1]
                }
            } else {
                continue
            }

            switch (name) {
                case 'LT':
                case 'AIMS-services-api':
                case 'aims-web':
                case 'AIMS-web':
                case 'aims-service':
                case 'LT-DTO':
                case 'LT-constant':
                case 'LT-converter':
                case 'LT-model':
                case 'LT-utility':
                case 'data-service':
                case 'data-services':
                case 'data-services-api':
                case 'doc-services-api':
                case 'document-service':
                case 'external-service':
                case 'external-service-api':
                case 'external-services-api':
                case 'program-service':
                case 'program-services-api':
                case 'program-web':
                    dev_branch = 'DEVELOPMENT'
                    name = 'LT'
                    break;
                case 'ACA':
                    name = 'aca'
                    break
                case 'b2b-service':
                    name = 'B2B_DT_Service'
                    break
                case 'backoffice-portal-service':
                    name = 'backoffice-portal'
                    break
                case 'checklist-web':
                    name = 'checklist'
                    break
                case 'finance-service':
                case 'finance-web':
                    name = 'Finance'
                    break
                case 'gi-web':
                    name = 'GI-WEB'
                    break
                case 'gi-service':
                    name = 'GI-SERVICE'
                    break
                case 'irp-web':
                    name = 'irp'
                    break
                case 'msg-admin':
                case 'msg-common':
                case 'msg-core':
                case 'msg-jms':
                case 'msg-service-api':
                    name = 'qima-msg-util'
                    break
                case 'param-service':
                case 'parameter-web':
                    name = 'parameter-service'
                    break
                case 'psi-service':
                case 'psi-web':
                    name = 'psi'
                    break
                case 'public API':
                    name = 'Public-API'
                    break
                case 'sso-common':
                case 'sso-management':
                    name = 'sso-suite'
                    break
                case 'commons':
                    dev_branch = 'master'
                    break
                default:
                    dev_branch = 'develop'
            }
            
            try {
                stage(name) {
                    // pull code from remote
                    git url: "${URL_ASIAN_SPECT}${name}.git",
                    credentialsId: CREDENT,
                    branch: dev_branch
                    
                    withCredentials([usernamePassword(credentialsId: CREDENT, usernameVariable: "GIT_USERNAME", passwordVariable: "GIT_PASSWORD")]) {
                        if (name == 'LT' || name == 'commons') {
                            sh "git checkout -b ${branch_var}release-${version}"
                            sh "git push origin ${branch_var}release-${version}"
                        }
                        
                        // checkout develop branch
                        try {
                            sh "git checkout ${branch_var}${dev_branch}"
                        } catch (err) {
                            sh "git checkout -b ${branch_var}${dev_branch}"
                        }
                        
                        switch (name) {
                            // update package.json version
                            case 'aca':
                            case 'CIA-NEW':
                            case 'IPTB-web':
                                def packageJSON = readJSON file: 'package.json'
                                packageJSON['version']=version
                                writeJSON(file: 'package.json', json: packageJSON)
                                break
                            // special services which need enter sub-directories
                            case 'auditor-app-services':
                                sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./auditor-app-services-api/pom.xml"
                                break
                            case 'final-report-service':
                                sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./FINAL-REPORT-SERVICE-services-api/pom.xml"
                                break
                            case 'IPTB-service':
                                sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./IPTB-SERVICE-services-api/pom.xml"
                                break
                            case 'aiparams':
                                sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT -f ./parameter/pom.xml"
                                break
                            // normal services
                            default:
                                sh "mvn versions:set -DnewVersion=${version}-SNAPSHOT"
                                break
                        }
                        
                        // push to remote
                        sh 'git add .'
                        sh 'git commit -m "update pom version"'
                        sh "git push origin ${branch_var}${dev_branch}"
                        
                        if (name != 'LT' && name != 'commons') {
                            // update release branch
                            sh "git checkout -b ${branch_var}release-${version}"
                            sh "git push origin ${branch_var}release-${version}"
                        }
                    }
                }
            } catch (err) {
                echo "error:${err}"
                continue
            }
        }
    }
}