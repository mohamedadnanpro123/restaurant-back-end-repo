# Use Node.js 20 on Alpine Linux (lightweight)
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY . .

# Expose port your app runs on
EXPOSE 5000

# Start the application
CMD ["node", "server.js"]
