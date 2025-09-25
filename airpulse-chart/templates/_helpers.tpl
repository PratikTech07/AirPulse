{{- define "airpulse-chart.name" -}}
airpulse
{{- end }}

{{- define "airpulse-chart.fullname" -}}
{{ .Release.Name }}-airpulse
{{- end }}
