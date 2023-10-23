#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

### nerdctl run -it --privileged --name=u1 
### -v /run/containerd:/run/containerd -v /usr/local/bin/nerdctl:/usr/local/bin/nerdctl  
### -v /var/lib/containerd:/var/lib/containerd -v /opt/cni/bin:/opt/cni/bin 
### -v /usr/local/sbin/runc:/usr/local/sbin/runc 
### -v /var/lib/nerdctl:/var/lib/nerdctl/ ubuntu:latest

{{- define "openwhisk.docker_volumes" -}}
- name: cgroup
  hostPath:
    path: "/sys/fs/cgroup"
- name: runc
  hostPath:
    path: "/usr/local/sbin/runc"
- name: dockerrootdir
  hostPath:
    path: "/var/lib/containerd"
- name: dockersock
  hostPath:
    path: "/run/containerd"
- name: nerdctl
  hostPath:
    path: "/usr/bin/nerdctl"
- name: ctr
  hostPath:
    path: "/usr/local/bin/ctr"
- name: crictl
  hostPath:
    path: "/usr/bin/crictl"
- name: nerdctlrootdir
  hostPath:
    path: "/var/lib/nerdctl"
- name: cni
  hostPath:
    path: "/opt/cni/bin"
- name: cnirootdir
  hostPath:
    path: "/var/lib/cni"
- name: overlaybdsock
  hostPath:
    path: "/run/overlaybd-snapshotter"
- name: certsdir
  hostPath:
    path: "/etc/containerd/certs.d"
- name: devdir
  hostPath:
    path: "/dev"
{{- end -}}

{{- define "openwhisk.docker_volume_mounts" -}}
- name: cgroup
  mountPath: "/sys/fs/cgroup"
- name: runc
  mountPath: "/usr/local/sbin/runc"
- name: dockersock
  mountPath: "/run/containerd"
- name: dockerrootdir
  mountPath: "/var/lib/containerd"
- name: nerdctl
  mountPath: "/usr/bin/nerdctl"
- name: ctr
  mountPath: "/usr/local/bin/ctr"
- name: crictl
  mountPath: "/usr/bin/crictl"
- name: nerdctlrootdir
  mountPath: "/var/lib/nerdctl"
- name: cni
  mountPath: "/opt/cni/bin"
- name: cnirootdir
  mountPath: "/var/lib/cni"
- name: overlaybdsock
  mountPath: "/run/overlaybd-snapshotter"
- name: certsdir
  mountPath: "/etc/containerd/certs.d"
- name: devdir
  mountPath: "/dev"
{{- end -}}

{{- define "openwhisk.docker_pull_runtimes" -}}
- name: docker-pull-runtimes
  image: "{{- .Values.docker.registry.name -}}{{- .Values.utility.imageName -}}:{{- .Values.utility.imageTag -}}"
  imagePullPolicy: {{ .Values.utility.imagePullPolicy | quote }}
  command: ["/usr/local/bin/ansible-playbook", "/invoker-scripts/playbook.yml"]
  volumeMounts:
  - name: dockersock
    mountPath: "/run/containerd/containerd.sock"
  - name: scripts-dir
    mountPath: "/invoker-scripts/playbook.yml"
    subPath: "playbook.yml"
  env:
    # action runtimes
    - name: "RUNTIMES_MANIFEST"
      value: {{ template "openwhisk.runtimes_manifest" . }}
{{- if ne .Values.docker.registry.name "" }}
    - name: "RUNTIMES_REGISTRY"
      value: "{{- .Values.docker.registry.name -}}"
    - name: "RUNTIMES_REGISTRY_USERNAME"
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-docker.registry.auth
          key: docker_registry_username
    - name: "RUNTIMES_REGISTRY_PASSWORD"
      valueFrom:
        secretKeyRef:
          name: {{ .Release.Name }}-docker.registry.auth
          key: docker_registry_password
{{- end -}}
{{- end -}}

