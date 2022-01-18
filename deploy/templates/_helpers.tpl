{{- define "rand32" -}}
{{- randAlphaNum 32 | nospace -}}
{{- end -}}

{{- define "rand16" -}}
{{- randAlphaNum 16 | nospace -}}
{{- end -}}