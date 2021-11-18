project = "example-nodejs-k8s"

app "example-nodejs-k8s" {
  labels = {
    "service" = "example-nodejs-k8s",
    "env"     = "dev"
  }

  build {
    use "pack" {}
    registry {
      use "aws-ecr" {
        region     = "ap-northeast-1"
        repository = "waypoint-example"
        tag        = "latest"
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
    }
  }

  release {
    use "kubernetes" {
      // Sets up a load balancer to access released application
      load_balancer = true
      port          = 3000
    }
  }
}
