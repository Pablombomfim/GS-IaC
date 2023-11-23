echo "Update with latest packages"
yum update -y
    
echo "Install Apache"
yum install -y httpd git
    
echo "Enable Apache service to start after reboot"
sudo systemctl enable httpd
    
echo "Install application"
cd /tmp
git clone https://github.com/Pablombomfim/staticsite.git
cp /tmp/staticsite/*.html /var/www/html/
    
echo "Start Apache service"
service httpd restart