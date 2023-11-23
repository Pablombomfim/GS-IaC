#!/bin/bash

# Instala o servidor Apache HTTP
sudo apt-get update
sudo apt-get install apache2 -y

# Cria o arquivo index.html com a mensagem "Hello, World!"
echo "<html><body><h1>Hello, World!</h1></body></html>" | sudo tee /var/www/html/index.html

# Inicia o servidor Apache HTTP
sudo systemctl start apache2
