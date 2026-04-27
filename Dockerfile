# ================================
# Stage 1: Build Astro
# ================================
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files trước để tận dụng Docker layer cache
COPY package.json package-lock.json ./

# Cài dependencies
RUN npm ci

# Copy toàn bộ source code
COPY . .

# Build Astro ra thư mục /app/dist
RUN npm run build

# ================================
# Stage 2: Serve bằng Nginx
# ================================
FROM nginx:alpine AS production

# Xoá config mặc định của nginx
RUN rm /etc/nginx/conf.d/default.conf

# Tạo config nginx trực tiếp — không cần file nginx.conf riêng
RUN printf 'server {\n\
    listen 80;\n\
    server_name localhost;\n\
\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
\n\
    # Bat nen gzip\n\
    gzip on;\n\
    gzip_vary on;\n\
    gzip_min_length 1024;\n\
    gzip_types text/plain text/css text/javascript application/javascript application/json image/svg+xml;\n\
\n\
    # Cache 1 nam cho assets tinh\n\
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|webp|woff|woff2|ttf)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
        try_files $uri =404;\n\
    }\n\
\n\
    # Xu ly routing Astro static\n\
    location / {\n\
        try_files $uri $uri/ $uri.html /index.html;\n\
    }\n\
\n\
    # Trang loi\n\
    error_page 404 /404.html;\n\
    error_page 500 502 503 504 /50x.html;\n\
}\n' > /etc/nginx/conf.d/terabox.conf

# Copy file build tu stage 1
COPY --from=builder /app/dist /usr/share/nginx/html

# Mo port 80
EXPOSE 80

# Khoi dong nginx
CMD ["nginx", "-g", "daemon off;"]