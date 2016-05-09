node('windows') {
    checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CloneOption', noTags: false, reference: '', shallow: true]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'a97b10b1-5869-465d-8616-7231c95df9ac', url: 'git@github.com:RocketScienceProjects/BlueKing.git']]])

   //7zip the webcontent folder
   stage name: 'Zipping', concurrency: 1
   env.PATH="C:\\Program Files\\7-Zip;C:\\Program Files\\Git\\usr\\bin;${env.PATH}"
   bat '7z a webcontent.zip webcontent'

    //upload to nexus
    stage name: 'Upload2Nexus', concurrency: 1
    bat 'curl -v -u admin:admin123 --upload-file "%cd%\\webcontent.zip" http://ec2-54-213-106-231.us-west-2.compute.amazonaws.com:8081/nexus/content/repositories/releases/org/bar/%BUILD_NUMBER%/webcontent.zip'

   //execute the powershell script to download , move and extract
   stage name: 'DownloadToIIS', concurrency: 1
   bat 'powershell -F deploy.ps1 webcontent.zip %BUILD_NUMBER%'

   //extract the zip file
   stage name: 'ExtractingAndDeleting', concurrency: 1
   bat '''echo "Extracting the artifact $ProjectPath"
   7z x \\\\WIN-RATABIECTJ2\\App\\webcontent.zip -o\\\\WIN-RATABIECTJ2\\App -y
   echo "Deleting the zip file"
   del \\\\WIN-RATABIECTJ2\\App\\webcontent.zip
   echo "Deleted the zip file $ProjectPath"'''
}
