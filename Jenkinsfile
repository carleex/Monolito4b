pipeline {
    agent { label 'windows' }

    environment {
        SOLUTION_FILE = 'Monolito4b.sln'
        BUILD_CONFIG = 'Release'
        MSBUILD = 'C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\MSBuild\\Current\\Bin\\MSBuild.exe'
        NUGET = 'C:\\Tools\\nuget\\nuget.exe'
        PUBLISH_DIR = 'C:\\inetpub\\wwwroot\\Monolito4b'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                bat 'echo Codigo descargado desde GitHub'
            }
        }

        stage('Restore NuGet') {
            steps {
                bat '"%NUGET%" restore "%SOLUTION_FILE%"'
            }
        }

        stage('Build') {
            steps {
                bat '"%MSBUILD%" "%SOLUTION_FILE%" /p:Configuration=%BUILD_CONFIG%'
            }
        }

        stage('Test') {
            steps {
                bat 'echo No hay pruebas unitarias configuradas'
                bat 'if exist "%SOLUTION_FILE%" (echo Prueba OK: solucion encontrada) else (exit /b 1)'
            }
        }

stage('Publish') {
    steps {
        bat '''
        "%MSBUILD%" "%SOLUTION_FILE%" ^
        /p:Configuration=Release ^
        /p:DeployOnBuild=true ^
        /p:WebPublishMethod=FileSystem ^
        /p:DeleteExistingFiles=True ^
        /p:PublishUrl=C:\\inetpub\\wwwroot\\Monolito4b
        '''
    }
}

        stage('Deploy IIS') {
            steps {
                bat 'iisreset'
                bat 'echo Aplicacion desplegada en IIS'
            }
        }

        stage('Database Check') {
            steps {
                bat 'sqlcmd -S localhost -d Monolito4am -Q "SELECT GETDATE()"'
                bat '"C:\\Program Files\\MongoDB\\mongosh\\bin\\mongosh.exe" --eval "show dbs"'
            }
        }
    }
}