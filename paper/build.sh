cd ./8
sudo docker buildx build -t ghcr.io/scorchingflame/creeper-host-eggs:paper_java_8 .
sudo docker push ghcr.io/scorchingflame/creeper-host-eggs:paper_java_8
cd ../11
sudo docker buildx build -t ghcr.io/scorchingflame/creeper-host-eggs:paper_java_11 .
sudo docker push ghcr.io/scorchingflame/creeper-host-eggs:paper_java_11
cd ../16
sudo docker buildx build -t ghcr.io/scorchingflame/creeper-host-eggs:paper_java_16 .
sudo docker push ghcr.io/scorchingflame/creeper-host-eggs:paper_java_16
cd ../17
sudo docker buildx build -t ghcr.io/scorchingflame/creeper-host-eggs:paper_java_17 .
sudo docker push ghcr.io/scorchingflame/creeper-host-eggs:paper_java_17
echo "!!! DONE !!.. Now Clearning Up Images"

sudo docker rmi ghcr.io/scorchingflame/creeper-host-eggs:paper_java_8
sudo docker rmi ghcr.io/scorchingflame/creeper-host-eggs:paper_java_11
sudo docker rmi ghcr.io/scorchingflame/creeper-host-eggs:paper_java_16
sudo docker rmi ghcr.io/scorchingflame/creeper-host-eggs:paper_java_17

echo "Cleaned Up Images"
