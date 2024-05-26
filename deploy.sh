#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y python3-pip python3-venv nginx git

# Clone the repository
cd /home/newdmi/adminka_zachet
# Set up virtual environment and install dependencies
cd app
python3 -m venv venv
source venv/bin/activate
pip install flask gunicorn

# Create systemd service
sudo bash -c 'cat <<EOF > /etc/systemd/system/flask_app.service
[Unit]
Description=Gunicorn instance to serve flask_app
After=network.target

[Service]
User=newdmi
Group=www-data
WorkingDirectory=/home/newdmi/adminka_zachet
Environment="PATH=/home/newdmi/adminka_zachet/venv/bin"
ExecStart=/home/newdmi/adminka_zachet/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
EOF'

# Start and enable the service
sudo systemctl daemon-reload
sudo systemctl start flask_app
sudo systemctl enable flask_app

# Set up Nginx
sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/flask_app
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF'

# Enable Nginx site and restart the service
sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Configure UFW to allow HTTP traffic
sudo ufw allow 'Nginx Full'
sudo ufw reload

echo "Deployment completed successfully. Your app should be accessible from the host machine."
