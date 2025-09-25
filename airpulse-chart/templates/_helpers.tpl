{{- define "airpulse-chart.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "airpulse-chart.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
