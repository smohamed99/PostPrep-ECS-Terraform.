# The base image 
#FROM node:24-alpine AS build
FROM node:24.22.3-alpine@sha256:116b800c3754b440ee0aa3ed2f20f5bf3d99a554bfd9adeea09ea8017f6e85f5 AS build

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


FROM nginxinc/nginx-unprivileged:1.30.6-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03


COPY default.conf /etc/nginx/conf.d/default.conf
  
COPY --from=build /app/build /usr/share/nginx/html

USER 101

EXPOSE 8080