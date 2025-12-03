{{- define "app.name" -}}
{{ .Values.app.name }}
{{- end }}

{{- define "app.deployment.name" -}}
{{ .Values.app.deployment.name }}
{{- end }}

{{- define "app.labels" -}}
app: {{ .Values.app.name }}
{{- end }}

{{- define "app.renderContainer" -}}
- name: {{ .container.name }}
  image: {{ .container.image }}
  imagePullPolicy: {{ .container.imagePullPolicy | default "IfNotPresent" }}

  {{- with .container.envFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- with .container.env }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}

  {{- if .container.port }}
  ports:
    - containerPort: {{ .container.port }}
      protocol: TCP
  {{- end }}

  {{- if .container.volumeMounts }}
  volumeMounts:
    {{- range $index, $mount := .container.volumeMounts }}
    - mountPath: {{ $mount.mountPath }}
      name: {{ $mount.name | default (printf "%s-volume-%d" $.root.Values.app.name $index) }}
      {{- if $mount.subPath }}
      subPath: {{ $mount.subPath }}
      {{- end }}
    {{- end }}
  {{- end }}

  resources:
    {{- default .root.Values.defaults.resources .container.resources | toYaml | nindent 4 }}

  {{- with default .root.Values.defaults.containerSecurityContext .container.securityContext }}
  securityContext:
    {{- . | toYaml | nindent 4 }}
  {{- end }}

  {{- if not .isInit }}
    {{- with .container.readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
    {{- end }}

    {{- with .container.livenessProbe }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
    {{- end }}

    {{- with .container.startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}

{{- end }}






{{- define "app.podTemplate" }}
metadata:
  labels:
    app: {{ .Values.app.name }}
    {{- with .Values.deployment.podLabels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.deployment.podAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with default .Values.defaults.podSecurityContext .Values.deployment.podSecurityContext }}
  securityContext:
    {{- . | toYaml | nindent 4 }}
  {{- end }}

  {{- if and (hasKey .Values "deployment") (hasKey .Values.deployment "initContainer") }}
  initContainers:
    {{- include "app.renderContainer" (dict "container" .Values.deployment.initContainer "root" . "isInit" true) | nindent 4 }}
  {{- end }}

  {{- if and (hasKey .Values "deployment") (hasKey .Values.deployment "container") }}
  containers:
    {{- include "app.renderContainer" (dict "container" .Values.deployment.container "root" . "isInit" false) | nindent 4 }}
    {{- if and (hasKey .Values "deployment") (hasKey .Values.deployment "sidecar") }}
    {{- include "app.renderContainer" (dict "container" .Values.deployment.sidecar "root" . "isInit" false) | nindent 4 }}
    {{- end }}
  {{- end }}



 {{- if and (hasKey .Values "deployment") (or .Values.deployment.volumes .Values.deployment.persistenceVolumeClaims) }}
  volumes:
    {{- if .Values.deployment.volumes }}
    {{- range $index, $vol := .Values.deployment.volumes }}
    - name: {{ $vol.name | default (printf "%s-volume-%d" $.Values.app.name $index) }}
      {{- if $vol.emptyDir }}
      emptyDir: {}
      {{- else if $vol.configMap }}
      configMap:
        name: {{ $vol.configMap }}
      {{- else if $vol.secret }}
      secret:
        secretName: {{ $vol.secret }}
      {{- end }}
    {{- end }}
    {{- end }}

    {{- if hasKey .Values.deployment "persistenceVolumeClaims" }}
    - name: {{ .Values.app.name }}-volume
      persistentVolumeClaim:
        claimName: {{ .Values.app.name }}-pvc
    {{- end }}
{{- end }}



  imagePullSecrets:
    {{- toYaml (default .Values.defaults.imagePullSecrets .Values.deployment.imagePullSecrets) | nindent 4 }}
{{- end }}
