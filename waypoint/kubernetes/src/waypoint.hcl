project = "showks-k8s"

app "showks-k8s" {
  labels = {
    "service" = "showks-k8s",
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
      load_balancer = true
      port          = 3000
    }
  }
}
