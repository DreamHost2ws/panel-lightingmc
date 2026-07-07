Hey want to install this do this 

1.git clone https://github.com/DreamHost2ws/panel-lightingmc

2.cd panel-lightingmc

3.ls

4.apt install unzip -y

5.unzip panel.zip

6.cd panel.zip 

7.sudo apt install openjdk-21-jdk -y

8.curl -sL https://deb.nodesource.com/setup_23.x | sudo bash -

9.npm i

10.npm start

npm install pm2@latest -g
pm2 start  app.js
pm2 startup
pm2 save
