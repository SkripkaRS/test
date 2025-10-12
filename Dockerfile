FROM node:20 as builder

# Create app directory
WORKDIR /app
# Install app dependencies

COPY package.json package-lock.json ./

RUN npm install -g npm@10.7.0

RUN npm install
# Copy project files into the docker image
COPY . .

ARG ENV=production

RUN npx ng build -c=${ENV}

# STEP 2 build a small nginx image with static website
FROM nginx:alpine
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

COPY nginx/default.conf /etc/nginx/conf.d/

## From 'builder' copy website to default nginx public folder
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
