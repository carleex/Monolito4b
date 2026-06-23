pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo 'Codigo descargado desde GitHub'
            }
        }

        stage('Restore NuGet') {
            steps {
                echo 'Restaurando paquetes NuGet'
                sh 'ls -la'
                sh 'test -f Monolito4b/Packages.config || test -f Monolito4b/packages.config || echo "packages.config encontrado o no requerido"'
            }
        }

        stage('Build') {
            steps {
                echo 'Compilando solucion Monolito4b'
                sh 'test -f Monolito4b.sln'
                echo 'Build simulado porque ASP.NET Web Forms .NET Framework requiere MSBuild de Windows'
            }
        }

        stage('Test') {
            steps {
                echo 'Ejecutando pruebas'
                echo 'No hay pruebas automatizadas configuradas, se valida existencia de la solucion'
                sh 'test -f Monolito4b.sln'
            }
        }

        stage('Publish') {
            steps {
                echo 'Publicando aplicacion'
                sh 'mkdir -p publish'
                sh 'echo "Aplicacion publicada de forma simulada" > publish/resultado.txt'
            }
        }

        stage('Deploy IIS') {
            steps {
                echo 'Despliegue simulado hacia IIS'
                echo 'Para deploy real se necesita servidor Windows con IIS'
            }
        }

        stage('Database Check') {
            steps {
                echo 'Validando conexiones SQL Server y MongoDB'
                echo 'SQL Server configurado en el proyecto'
                echo 'MongoDB configurado en Infrastructure/Mongo'
                echo 'Validacion simulada porque las bases no estan dentro del contenedor Jenkins'
            }
        }
    }
}