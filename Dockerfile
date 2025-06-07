# Stage 1: build flutter web
FROM instrumentisto/flutter AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

# Stage 2: serve static web with Nginx/Node/dhttpd/serve
FROM node:20-alpine

WORKDIR /app
RUN npm install -g serve

COPY --from=build /app/build/web ./

EXPOSE 8080
CMD ["serve", "-s", "-l", "8080"]