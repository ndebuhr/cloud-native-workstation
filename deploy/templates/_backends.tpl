{{- define "backends" -}}

{{- $backends := list -}}

{{- if eq .Values.code.enabled true -}}
{{- $backends = append $backends "code" -}}
{{- $backends = append $backends "code-dev-server" -}}
{{- end -}}

{{- if eq .Values.pgweb.enabled true -}}
{{- $backends = append $backends "pgweb" -}}
{{- end -}}

{{- if eq .Values.selenium.enabled true -}}
{{- $backends = append $backends "selenium-hub" -}}
{{- end -}}

{{- if eq .Values.selenium.chrome.enabled true -}}
{{- $backends = append $backends "selenium-chrome" -}}
{{- end -}}

{{- if eq .Values.selenium.firefox.enabled true -}}
{{- $backends = append $backends "selenium-firefox" -}}
{{- end -}}

{{- if eq .Values.selenium.edge.enabled true -}}
{{- $backends = append $backends "selenium-edge" -}}
{{- end -}}

{{- if eq .Values.jupyter.enabled true -}}
{{- $backends = append $backends "jupyter" -}}
{{- end -}}

{{- if eq .Values.landing.enabled true -}}
{{- $backends = append $backends "landing" -}}
{{- end -}}

{{- if eq .Values.sonarqube.enabled true -}}
{{- $backends = append $backends "sonarqube" -}}
{{- end -}}

{{- if eq .Values.guacamole.enabled true -}}
{{- $backends = append $backends "guacamole" -}}
{{- end -}}

{{- if eq .Values.kanboard.enabled true -}}
{{- $backends = append $backends "kanboard" -}}
{{- end -}}

{{- if eq .Values.prometheus.enabled true -}}
{{- $backends = append $backends "prometheus" -}}
{{- end -}}

{{- if eq .Values.grafana.enabled true -}}
{{- $backends = append $backends "grafana" -}}
{{- end -}}

{{- join "," $backends -}}

{{- end -}}