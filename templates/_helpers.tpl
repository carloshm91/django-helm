{{/*
Expand the name of the chart.
*/}}
{{- define "django.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "django.fullname" -}}
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
{{- define "django.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "django.labels" -}}
helm.sh/chart: {{ include "django.chart" . }}
{{ include "django.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "django.selectorLabels" -}}
app.kubernetes.io/name: {{ include "django.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "django.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "django.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define environment variables
*/}}
{{- define "django.envFrom" -}}
envFrom:
{{- if .Values.envConfigs }}
- configMapRef:
    name: {{ include "django.fullname" . }}-config
{{- end }}
{{- if .Values.envSecrets.enabled }}
- secretRef:
    {{- if .Values.envSecrets.external.enabled }}
    name: {{ .Values.envSecrets.external.secretName }}
    {{- else }}
    name: {{ .Values.envSecrets.name | default (printf "%s-secrets" (include "django.fullname" .)) }}
    {{- end }}
{{- end }}
{{- end }}

{{/*
Define Redis connection environment variables
*/}}
{{- define "django.redisEnv" -}}
{{- if .Values.redis.enabled }}
# Using built-in Redis
- name: REDIS_HOST
  value: {{ .Release.Name }}-redis-master
- name: REDIS_PORT
  value: "6379"
- name: CELERY_RESULT_BACKEND
  value: "redis://{{ .Release.Name }}-redis-master:6379"
{{- else if .Values.redis.external.enabled }}
# Using external Redis
- name: REDIS_HOST
  value: {{ .Values.redis.external.host | quote }}
- name: REDIS_PORT
  value: {{ .Values.redis.external.port | quote }}
- name: CELERY_RESULT_BACKEND
  value: "redis://{{ .Values.redis.external.host }}:{{ .Values.redis.external.port }}"
{{- end }}
{{- end }}

{{/*
Define RabbitMQ connection environment variables
*/}}
{{- define "django.rabbitmqEnv" -}}
{{- if .Values.rabbitmq.enabled }}
# Using built-in RabbitMQ
- name: RABBITMQ_HOST
  value: {{ .Release.Name }}-rabbitmq
- name: RABBITMQ_PORT
  value: "5672"
- name: RABBITMQ_USER
  value: {{ .Values.rabbitmq.auth.username | quote }}
- name: RABBITMQ_VHOST
  value: "/"
- name: CELERY_BROKER_URL
  value: "amqp://{{ .Values.rabbitmq.auth.username }}:{{ .Values.rabbitmq.auth.password }}@{{ .Release.Name }}-rabbitmq:5672//"
{{- else if .Values.rabbitmq.external.enabled }}
# Using external RabbitMQ
- name: RABBITMQ_HOST
  value: {{ .Values.rabbitmq.external.host | quote }}
- name: RABBITMQ_PORT
  value: {{ .Values.rabbitmq.external.port | quote }}
- name: RABBITMQ_USER
  value: {{ .Values.rabbitmq.external.user | quote }}
- name: RABBITMQ_VHOST
  value: {{ .Values.rabbitmq.external.vhost | quote }}
- name: CELERY_BROKER_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.envSecrets.name | default (printf "%s-secrets" (include "django.fullname" .)) }}
      key: CELERY_BROKER_URL
{{- end }}
{{- end }}

{{/*
Define PostgreSQL connection environment variables
*/}}
{{- define "django.postgresqlEnv" -}}
{{- if .Values.postgresql.enabled }}
# Using built-in PostgreSQL
- name: POSTGRES_SERVICE_HOST
  value: {{ .Release.Name }}-postgresql
- name: POSTGRES_SERVICE_PORT
  value: "5432"
- name: POSTGRES_DB
  value: {{ .Values.postgresql.auth.database | quote }}
- name: POSTGRES_USER
  value: {{ .Values.postgresql.auth.username | quote }}
{{- else if .Values.postgresql.external.enabled }}
# Using external PostgreSQL
- name: POSTGRES_SERVICE_HOST
  value: {{ .Values.postgresql.external.host | quote }}
- name: POSTGRES_SERVICE_PORT
  value: {{ .Values.postgresql.external.port | quote }}
- name: POSTGRES_DB
  value: {{ .Values.postgresql.external.database | quote }}
- name: POSTGRES_USER
  value: {{ .Values.postgresql.external.user | quote }}
{{- end }}
{{- end }}