# Stage 1: Build React frontend
FROM node:24-alpine AS frontend-build

WORKDIR /app

COPY frontend/package*.json ./

RUN npm ci

COPY frontend/ ./

RUN npm run build


# Stage 2: Configure Nginx
FROM nginx:1.28-alpine

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom Nginx configuration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copy React production build
COPY --from=frontend-build /app/dist /usr/share/nginx/html

EXPOSE 80