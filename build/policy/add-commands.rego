package main

deny[msg] {
   # https://snyk.io/blog/10-docker-image-security-best-practices/
   input[i].Cmd == "add"
   val := concat(" ", input[i].Value)
   msg = sprintf("Use COPY instead of ADD: %s", [val])
}