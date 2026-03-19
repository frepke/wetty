# Dockerfile

# Use the official Node.js image as a base image
FROM node:14

# Create and change to the app directory
WORKDIR /usr/src/app

# Copy and install app dependencies
COPY package*.json ./
RUN npm install

# Copy app source code
COPY . .

# Build the app
RUN npm run build

# Expose the app port
EXPOSE 3000

# Start the app
CMD [ "npm", "start" ]
