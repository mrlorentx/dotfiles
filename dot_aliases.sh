#!/usr/bin/env bash

alias dockerlgtm="docker run -p 3000:3000 -p 4317:4317 -p 4318:4318 --rm -ti grafana/otel-lgtm"

alias forge='mosh forge -- tmux new -A -s main'

alias devbox='ssh -t joakim_lorentz_henriksson_com@devbox-joakim "sudo docker exec -it --user paseo --workdir /workspace paseo-devbox-paseo-1 tmux new-session -A -s dev"'
