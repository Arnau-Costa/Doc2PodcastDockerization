#!/bin/bash

REPO_URL="https://github.com/misbahsy/Doc2Podcast.git"
REPO_NAME="Doc2Podcast"
FLOW_ID="Doc2Podcast"


GREEN='\033[0;32m'
NC='\033[0m'

text=$(cat <<'EOF'
______           _____ ______         _               _      ___        _        
|  _  \         / __  \| ___ \       | |             | |    / _ \      | |       
| | | |___   ___`' / /'| |_/ /__   __| | ___ __ _ ___| |_  / /_\ \_   _| |_ ___  
| | | / _ \ / __| / /  |  __/ _ \ / _` |/ __/ _` / __| __| |  _  | | | | __/ _ \ 
| |/ / (_) | (__./ /___| | | (_) | (_| | (_| (_| \__ \ |_  | | | | |_| | || (_) |
|___/ \___/ \___\_____/\_|  \___/ \__,_|\___\__,_|___/\__| \_| |_/\__,_|\__\___/
EOF
)

echo -e "${GREEN}${text}${NC}"


echo "Cloning the repository..."
if [ -d "$REPO_NAME" ]; then
  echo "Repository already exists. Skipping clone."
else
  git clone "$REPO_URL"
fi

cd "$REPO_NAME" || exit

echo "Creating .env.local file..."
cat <<EOL > .env.local
LANGFLOW_API_URL=http://langflow:7860
FLOW_ID=$FLOW_ID
UPLOAD_FOLDER="uploads"
GENERATED_AUDIO_FOLDER="generated_audio"
EOL

echo "Creating Dockerfile..."
cat <<EOL > Dockerfile
# Dockerfile
FROM node:18
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
EXPOSE 3000
EOL

echo "Creating docker-compose.yml file..."
cat <<EOL > docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
    command: ["npm", "run", "dev"]
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      LANGFLOW_API_URL: "http://langflow:7860"
      FLOW_ID: "$FLOW_ID"
      UPLOAD_FOLDER: "/app/uploads"
      GENERATED_AUDIO_FOLDER: "/app/generated_audio"
    depends_on:
      - langflow
    networks:
      - app-network  # Add app to the shared network

  langflow:
    image: langflow:latest
    ports:
      - "7860:7860"
    volumes:
      - ./langflow_data:/data
    networks:
      - app-network  # Add Langflow to the shared network

networks:
  app-network:
    driver: bridge
EOL

echo "Building and running Docker containers..."
docker compose up --build -d

echo "Setup complete! Access the app at http://localhost:3000 and Langflow at http://localhost:7860."
