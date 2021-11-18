project = "showks-nomad"

app "showks-nomad" {

  build {
    use "pack" {}
    registry {
      use "docker" {
        image = "showks-nomad"
        tag   = "1"
        local = true
      }
    }
  }

  deploy {
    use "nomad" {
      datacenter = "dc1"
      namespace  = "default"
    }
  }

}
