project = "showks-ecs"

app "showks-ecs" {
  labels = {
    "service" = "showks-ecs",
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
    use "aws-ecs" {
      region = "ap-northeast-1"
      memory = "512"
    }
  }
}
