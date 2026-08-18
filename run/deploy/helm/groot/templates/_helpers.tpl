{{- define "groot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "groot.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "groot.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "groot.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "groot.image" -}}
{{- /* GHCR publishes vX.Y.Z (+ latest), not bare X.Y.Z — normalize a missing v. */ -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- if not (hasPrefix "v" $tag) -}}
{{- $tag = printf "v%s" $tag -}}
{{- end -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}

{{/*
Pull secrets on the Job ServiceAccount. Prefer serviceAccount.imagePullSecrets;
otherwise copy image.pullSecrets so groot-trigger Jobs using this SA inherit them.
*/}}
{{- define "groot.serviceAccountPullSecrets" -}}
{{- if .Values.serviceAccount.imagePullSecrets -}}
{{- toYaml .Values.serviceAccount.imagePullSecrets -}}
{{- else if .Values.image.pullSecrets -}}
{{- toYaml .Values.image.pullSecrets -}}
{{- end -}}
{{- end -}}
