source "docker" "nginx" {
  image  = "nginx"
  commit = true
  # either don't overwrite the entrypoint
  run_command = ["-d", "-i", "-t", "--", "{{.Image}}"]
  # or restore it
  changes = [
    "ENTRYPOINT [\"/docker-entrypoint.sh\"]",
    "CMD [\"nginx\", \"-g\", \"daemon off;\"]"
  ]
}
build {
  sources = [
    "source.docker.nginx",
  ]
  provisioner "file" {
    source = "./index.html"
    destination = "/usr/share/nginx/html/index.html"
  }
    provisioner "file" {
    source = "./Google.css"
    destination = "/usr/share/nginx/html/Google.css"
  }

  post-processor "docker-tag" {
    repository = "web"
  }
}