# The base image 
FROM node:24-alpine AS build

# Makes a folder called /app, and then moves into it.
# From here on, every line in the Dockerfile happens inside /app
WORKDIR /app

# Copies the dependency list (package.json) and the exact versions
# (yarn.lock) from my Mac into /app
COPY package.json yarn.lock ./

# Installs the dependencies listed in package.json, at the exact
# versions in yarn.lock. Fails if the two don't match.
RUN yarn install --frozen-lockfile

# Copies the rest of the project (the app's code) from my Mac into /app.
# Kept separate from the first COPY because code changes most often, so it goes
# lower down - that way Docker can reuse the saved yarn install when only code changes.
COPY . . 

# Runs the build inside the image - turns the app's code into the
# plain files in a build folder
RUN yarn build

# Stage 2: Multi-stage

#clearçFROM nginxinc/nginx-unprivileged:stable-alpine
FROM cgr.dev/chainguard/nginx:latest

COPY default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 8080