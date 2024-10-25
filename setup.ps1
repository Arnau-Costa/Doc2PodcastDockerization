# PowerShell Script to Set Up the Doc2Podcast Project
$REPO_URL = "https://github.com/misbahsy/Doc2Podcast.git"
$REPO_NAME = "Doc2Podcast"
$FLOW_ID = "your_flow_id_here"

# Green Text Color
$Green = "`e[32m"
$Reset = "`e[0m"

# ASCII Art Display
$text = @"
______           _____ ______         _               _      ___        _        
|  _  \         / __  \| ___ \       | |             | |    / _ \      | |       
| | | |___   ___`' / /'| |_/ /__   __| | ___ __ _ ___| |_  / /_\ \_   _| |_ ___  
| | | / _ \ / __| / /  |  __/ _ \ / _` |/ __/ _` / __| __| |  _  | | | | __/ _ \ 
| |/ / (_) | (__./ /___| | | (_) | (_| | (_| (_| \__ \ |_  | | | | |_| | || (_) |
|___/ \___/ \___\_____/\_|  \___/ \__,_|\___\__,_|___/\__| \_| |_/\__,_|\__\___/ 
"@

Write-Host "$Green$text$Reset"

# Step 1: Clone the repository
Write-Host "Cloning the repository..."
if (Test-Path -Path $REPO_NAME) {
    Write-Host "Repository already exists. Skipping clone."
} else {
    git clone $REPO_URL
}

# Change to the project directory
Set-Location -Path $REPO_NAME

# Step 2: Create .env.local file
Write-Host "Creating .env.local file..."
@"
LANGFLOW_API_URL=http://langflow:7860
FLOW_ID=$FLOW_ID
UPLOAD_FOLDER="uploads"
GENERATED_AUDIO_FOLDER="generated_audio"
"@ | Out-File -Encoding utf8 .env.local

# Step 3: Create Dockerfile
Write-Host "Creating Dockerfile..."
@"
# Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
"@ | Out-File -Encoding utf8 Dockerfile

# Step 4: Create docker-compose.yml file
Write-Host "Creating docker-compose.yml file..."
@"
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

  langflow:
    image: langflowai/langflow:latest
    ports:
      - "7860:7860"
    volumes:
      - ./langflow_data:/data
"@ | Out-File -Encoding utf8 docker-compose.yml

# Step 5: Run Docker Compose
Write-Host "Building and running Docker containers..."
docker-compose up --build -d

Write-Host "Setup complete! Access the app at http://localhost:3000 and Langflow at http://localhost:7860."
