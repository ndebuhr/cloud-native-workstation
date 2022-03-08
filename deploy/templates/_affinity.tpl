{{ define "affinity" }}
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      {{ if eq .runsOnStandardVMs true }}
      - matchExpressions:
        - key: "cloud.google.com/gke-spot"
          operator: NotIn
          values:
          - "true"
        - key: "cloud.google.com/gke-preemptible"
          operator: NotIn
          values:
          - "true"
      {{ end }}
      {{ if eq .runsOnSpotVMs true }}
      - matchExpressions:
        - key: "cloud.google.com/gke-spot"
          operator: In
          values:
          - "true"
      {{ end }}
      {{ if eq .runsOnPreemptibleVMs true }}
      - matchExpressions:
        - key: "cloud.google.com/gke-preemptible"
          operator: In
          values:
          - "true"
      {{ end }}
{{ end }}