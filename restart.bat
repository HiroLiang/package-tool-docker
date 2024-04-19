@echo off

REM stop & delete container and image
docker stop git-package-tool
docker rm git-package-tool
docker rmi hiroliang/git-package-tool

REM build image
docker build -t hiroliang/git-package-tool:latest .

pause

REM run image
docker run -p 8080:8080 -v D:\docker\git\base\resources:/app/targets -d --name git-package-tool hiroliang/git-package-tool