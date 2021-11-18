project = "example-nodejs"

app "example-nodejs" {
  labels = {
    "service" = "example-nodejs",
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
