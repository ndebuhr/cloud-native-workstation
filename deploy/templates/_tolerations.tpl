{{- define "tolerations" -}}
{{ if or (eq .runsOnSpotVMs true) (eq .runsOnPreemptibleVMs true) }}
tolerations:
{{ end }}
{{ if eq .runsOnSpotVMs true }}
- key: "cloud.google.com/gke-spot"
  operator: Equal
  value: "true"
  effect: NoSchedule
{{ end }}
{{ if eq .runsOnPreemptibleVMs true }}
- key: "cloud.google.com/gke-preemptible"
  operator: Equal
  value: "true"
  effect: NoSchedule
{{ end }}
{{- end -}}