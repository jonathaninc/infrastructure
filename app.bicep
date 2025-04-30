extension radius

@description('Specifies the environment for resources.')
param environment string

resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'jonathaninc'
  properties: {
    environment: environment
  }
}

resource backend 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'backend'
  properties: {
    application: app.id
    container: {
      image: 'ghcr.io/jonathaninc/dev/backend:latest'
      ports: {
        api: {
          containerPort: 8080
        }
      }
    }
    connections: {
      redis: {
        source: redis.id
      }
    }
  }
}

resource frontend 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'frontend'
  properties: {
    application: app.id
    container: {
      image: 'ghcr.io/jonathaninc/dev/frontend:latest'
      env: {
        REACT_APP_API_URL: {
          value: 'http://backend:8080'
        }
      }
      ports: {
        web: {
          containerPort: 80
        }
      }
    }
    connections: {
      backend: {
        source: 'http://backend:8080'
      }
      redis: {
        source: redis.id
      }
    }
  }
}

resource redis 'Applications.Datastores/redisCaches@2023-10-01-preview' = {
  name: 'redis'
  location: 'global'
  properties: {
    environment: environment
  }
}
