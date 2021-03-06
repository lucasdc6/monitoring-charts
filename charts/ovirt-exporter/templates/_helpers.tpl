{{/*
Expand the name of the chart.
*/}}
{{- define "ovirt-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ovirt-exporter.fullname" -}}
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
{{- define "ovirt-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ovirt-exporter.labels" -}}
helm.sh/chart: {{ include "ovirt-exporter.chart" . }}
{{ include "ovirt-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ovirt-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ovirt-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ovirt-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ovirt-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret with the credentials
*/}}
{{- define "ovirt-exporter.secret.credentials.name" -}}
{{- if not (and .Values.config.api.passwordSecret.name .Values.config.api.passwordSecret.key) }}
{{- printf "%s-credentials" (include "ovirt-exporter.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Values.config.api.passwordSecret.name }}
{{- end }}
{{- end }}

{{/*
Create the path of the secret with the credentials
*/}}
{{- define "ovirt-exporter.secret.credentials.path" -}}
{{- if not (and .Values.config.api.passwordSecret.name .Values.config.api.passwordSecret.key) }}
{{- printf "/etc/ovirt_exporter/password" }}
{{- else }}
{{- printf "/etc/ovirt_exporter/%s" .Values.config.api.passwordSecret.key }}
{{- end }}
{{- end }}
