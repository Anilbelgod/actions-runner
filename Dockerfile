# Use the official Nginx image from Docker Hub as a parent image
FROM nginx:alpine

# Optional: Remove default Nginx welcome page
# RUN rm /usr/share/nginx/html/index.html /usr/share/nginx/html/50x.html

# Optional: Copy your custom static website files to the Nginx html directory
# Ensure you have an 'html' folder in the same directory as this Dockerfile
# with your index.html and other static assets.
# COPY html/ /usr/share/nginx/html/

# Optional: Copy a custom Nginx configuration file
# Ensure you have a 'nginx.conf' file in the same directory as this Dockerfile.
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 to the Docker host, so we can access the Nginx server
EXPOSE 80

# Command to run Nginx in the foreground when the container starts
CMD ["nginx", "-g", "daemon off;"]