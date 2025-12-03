when ever we givemn values in values.yaml file and if we want to pass or call in teamle then we can call them with the help of syntax

{{ .Values.directory.feild}}

To run any blcok of values repeatedly or run pass entire block as value then we cam achieve it by toYaml command 

lets assume 

#directory
~~
comoutereources:
  limits: 
     cpu : 1
     memory: 250mi
  requests:
     cpu : 1
     memory: 250mi
~~~~

lets assume above the block which needs to be pass as one value

we need to calucate the space in tempalte where this block needs to be execute and pass that as nindedt n

To print any yaml file or block in templates or yaml as function, which called as "toYam"
ex:

{{- toYaml .Vales.comoutereources | nindent n (n means space f=before this command palcing )}}


lets assume as this is reusable as functions or whenever any block wants to be repeat or call ut many times then we cna define it as funtion and call it when even we needed it 

we can define those funtion in _helper.tpl fiLe

to define any block as function we need to use the keyword define in fucntion 
ex:
````
{{- define "ui.labels" -}}
app: frontend
env: dev
{{- end -}}
`````

how can we refer this function into template and how can we avoid hardcaded details in fucntions..?

we can avoid harded details by refering values here and we can call funciton in templates as shown below

````
{{- define "ui.labels" -}}
app: frontend
env: {{ .Values.app.end }}
{{- end -}}
`````
rendering the funtion in maintempalte file 
To call and use this funtion or named funtion in template we need to sue the keyword "include" 

ex: 
````
{{- include "ui.labels" . | nindent nspace}}
`````

If we want to execute any tempalte on condition based (true/false) we can achieve it by mention the enabled condition in values

lets assme if any values of feileds is having condtion is true then execute template else dont execute tempalte

ex:
values
-------
hpa:
  enabled: true

template;
--------
{{- if .Values.hpa.enalbed }}

Note wgenever we open if condition amke sure theat we need to close that funtion wieh end

{{- end }}

helm tempalte ## this command only triggers and print the value based on rendering the value.yaml file it wont execute on real infra

syntax: helm template release-name code-folder -f values-files




Liveness probe
========
checks if the the container is healthy .
if probe fails contianers restart
prevent stuck and hung applicaitons

Rediness probe:
===============
Checks if the app is ready to serve traffic or not
if fails, remove from the service endpoints
prevent routing traffic to broken pods


startup probe:
==============
Used for slow-start applications.
Runs first; disables liveness until it passes.
Prevents early restarts for heavy apps.
Ensures proper warm-up before regular probes start.

