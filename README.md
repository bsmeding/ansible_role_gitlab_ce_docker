# GitLab CE
This role will install Gitlab CE on docker host

# Root password
If not set via  ENV `GITLAB_ROOT_PASSWORD` or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`:
After first run, the root password can be retreived from container at location `/etc/gitlab/initial_root_password`
Only first 24 hour after creation this file will be there!

To retreive:
* login to the host
* login to container: `docker exec -it gitlab /bin/bash`
* execute command: `cat /etc/gitlab/initial_root_password`

# todo :
test without auto user generation (create users ad OS and map /etc/passwd file to container)

# Disable signup
Manually turn off sign up
see https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2837

# LDAP Support

When enabling / setting the variables `gitlab__ldap_server_host_ip` and `gitlab__ldap_server_host_port` LDAP support is enabled

* `gitlab__ldap_search_users`: Set user base search path
* `gitlab__ldap_search_groups`: not implemented yet
* `gitlab__ldap_auth_bind_dn`: User to BIND to the LDAP server (minimal access, only to authenticate and run search query)
* `gitlab__ldap_auth_bind_pass`: Password of the user
* `gitlab__ldap_user_filter`: What group must the users be member of to allow access

## Microsoft Active Directory
If you have MS AD, then the variable `gitlab__ldap_is_ad` to true and set user_search (when used) with prefix: `(memberOf:1.2.840.113556.1.4.194:=CN=....` instead of `(memberOf=CN=.....)` 


# Gitlab.rb
Please not that by default when the gitlab.rb file is created, it will not be overwritten. So when doing manual changes it will not be reset by a following plyabook run.
Only when changing variables that exists in the template, like LDAP etc, please be aware that updates/changes are not reflected

## SSL
To copy SSL certificates for Gitlab and/or for the docker registery service, place the cert files in `./files/certs/*` (if directory does not exist, create directory) and add the cert filenames to the playbook:

```
gitlab__ssl_cert_file: 'git.example.com.pub'
gitlab__ssl_cert_key_file: 'git.example.com.key'
# optional:
gitlab__registery_ssl_cert_file: 'registery.example.com'
gitlab__registery_ssl_cert_key_file: 'registery.example.key'
```

### SSL Trusted root certificates
To add trusted certificates, place the certificate files in `./files/certs/trusted-certs/` to copy them over to the host


# Example playbook

The following playbook will install Gitlab CE on a host

first install the required roles:

- `ansible-galaxy role install bsmeding.docker`
- `ansible-galaxy role install bsmeding.gitlab_docker`

Then run the playbook, after executing wait 5 - 10 minutes on first build that is needed for Gitlab rails to start.
Change hostname and password to your needs:


```
---
- name: Install gitlab
  hosts: [gitlab_hosts]
  gather_facts: true
  become: true
  vars:
    gitlab__hostname: git.bartsmeding.nl
    gitlab__env:
      GITLAB_ROOT_PASSWORD: 'pleasechangeme'
  tasks:
    # Install Docker
    - name: Check if docker is installed
      ansible.builtin.include_role:
        name: bsmeding.docker

    # Install Gitlab CE
    - name: Check if gitlab is installed
      ansible.builtin.include_role:
        name: bsmeding.gitlab_docker
```
