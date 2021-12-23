node() {
    stage('update all services') {
        script {
            def infos = "${params.infos}".split(',')
            def map = [
                checklist_service: 'https://github.com/asiainspection/checklist-service.git',
                aca: 'https://github.com/asiainspection/aca.git'
            ]
            for (info in infos) {
                name = info.split('=')[0]
                version = info.split('=')[1]
                echo "${map[name]},${version}"
                stage("clone ${name} develop") {
                    try {
                        git clone: "https://github.com/asiainspection/checklist-service.git",
                        credentialsId: "arthur",
                        branch: "arthur_develop"
                    }
                    catch (error) {
                        git url: "https://github.com/asiainspection/checklist-service.git",
                        credentialsId: "arthur",
                        branch: "arthur_develop"
                        echo 'first time fetch service'
                    }
                }
                stage("set operator info") {
                    withCredentials([usernamePassword(credentialsId: "arthur", usernameVariable: "GIT_USERNAME", passwordVariable: "GIT_PASSWORD")]) {
                        // 配置 Git 工具中仓库认证的用户名、密码
                        sh 'git config --local credential.helper "!p() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; p"'
                        // 配置 git 变量 user.name 和 user.emai
                        sh 'git config --global user.name "ArthurQvQ"'
                        sh 'git config --global user.email "arthur.sun@qima.com"'
                    }
                }
                stage("arthur_develop ${version}"){
                    withCredentials([usernamePassword(credentialsId: "arthur", usernameVariable: "GIT_USERNAME", passwordVariable: "GIT_PASSWORD")]) {
                        sh 'ls'
                        sh "git pull ${map[name]}"
                        // update arthur_test branch version
                        try {
                            sh 'git checkout arthur_develop'
                        } catch (err) {
                            sh 'git checkout -b arthur_develop'
                        }
                        sh "mvn versions:set -DnewVersion=${version}"
                        // push changes to remote
                        try {
                            sh 'git add .'
                            sh 'git commit -m "update pom version"'
                            sh 'git push -u origin arthur_develop'
                        } catch (err) {
                            echo "something error: ${err}"
                            stage('FAILED ${name}'){
                                input "Jump over this service?"
                            }
                        } finally { }
                    }
                }
                stage("arthur_release ${version}") {
                    withCredentials([usernamePassword(credentialsId: "arthur", usernameVariable: "GIT_USERNAME", passwordVariable: "GIT_PASSWORD")]) {
                        // switch release branch
                        try {
                          sh 'git checkout arthur_release'
                          sh 'git pull origin arthur_release'
                        } catch (err) {
                            sh 'git checkout -b arthur_release'
                        }
                        sh "mvn versions:set -DnewVersion=${version}"
                        // push changes to remote
                        try {
                            sh 'git add .'
                            sh 'git commit -m "update pom version"'
                            sh 'git push -u origin arthur_release'
                        } catch (err) {
                            echo "something error: ${err}"
                            stage('FAILED ${name}'){
                                input "Jump over this service?"
                            }
                        }
                    }
                }
            }
        }
    }
}