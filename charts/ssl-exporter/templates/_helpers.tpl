{{/*
Expand the name of the chart.
*/}}
{{- define "ssl-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ssl-exporter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ssl-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ssl-exporter.labels" -}}
helm.sh/chart: {{ include "ssl-exporter.chart" . }}
{{ include "ssl-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- range $key, $value := .Values.extraLabels }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ssl-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ssl-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ssl-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ssl-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the kubeconfig secret
*/}}
{{- define "ssl-exporter.kubeconfigSecret" -}}
{{- if eq .Values.kubeconfig.type "secret" }}
{{- required "You must specify the value 'kubeconfig.secret.name'" .Values.kubeconfig.secret.name }}
{{- else }}
{{- printf "%s-kubeconfig" (include "ssl-exporter.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create the env properties
*/}}
{{- define "ssl-exporter.args" -}}
- --log.level={{ .Values.logLevel | default "info" }}
- --config.file=/etc/ssl-exporter/config/config.yaml
{{- end }}

{{/*
Generate the kubeconfig path
*/}}
{{- define "ssl-exporter.kubeconfig.path" -}}
{{- if or (eq .Values.kubeconfig.type "cleartext") (eq .Values.kubeconfig.type "encoded") }}
{{- printf "/etc/ssl-exporter/kube/config" }}
{{- else if eq .Values.kubeconfig.type "secret" }}
{{- $secretKey := required "You must specify the value 'kubeconfig.secret.key'" .Values.kubeconfig.secret.key }}
{{- printf "/etc/ssl-exporter/kube/%s" $secretKey }}
{{- else }}
{{- fail "Unrecognized kubeconfig type. Choose one of 'cleartext', 'encoded' or 'secret'" }}
{{- end }}
{{- end }}

{{/*
Create the volume block to use
*/}}
{{- define "ssl-exporter.volumes" -}}
- configMap:
    name: {{ include "ssl-exporter.fullname" . }}
  name: config
{{- if  .Values.kubeconfig.enabled }}
- name: kube
  secret:
    secretName: {{ include "ssl-exporter.kubeconfigSecret" . }}
{{- end }}
{{- with .Values.extraVolumes }}
{{ toYaml . }}
{{- end }}
{{- if .Values.k8sCerts.enabled }}
- hostPath:
    path: {{ .Values.k8sCerts.path }}
    type: ""
  name: k8s-certs
{{- end }}
{{- end }}

{{/*
Create the volumeMounts block to use
*/}}
{{- define "ssl-exporter.volumeMounts" -}}
- mountPath: "/etc/ssl-exporter/config"
  name: config
{{- if .Values.kubeconfig.enabled }}
- mountPath: "/etc/ssl-exporter/kube"
  name: kube
{{- end }}
{{- with .Values.extraVolumeMounts }}
{{ toYaml . }}
{{- end }}
{{- if .Values.k8sCerts.enabled }}
- mountPath: {{ default .Values.k8sCerts.path .Values.k8sCerts.mountPath }}
  name: k8s-certs
  readOnly: true
{{- end }}
{{- end }}


{{/*
Create the serviceMoitor name
*/}}
{{- define "ssl-exporter.k8sCerts.serviceMonitor" }}
{{- printf "%s-local-certificates" (include "ssl-exporter.fullname" .) }}
{{- end }}
