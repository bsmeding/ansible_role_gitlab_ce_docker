# GitLab CE


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

# Gitlab.rb
Please not that by default when the gitlab.rb file is created, it will not be overwritten. So when doing manual changes it will not be reset by a following plyabook run.
Only when changing variables that exists in the template, like LDAP etc, please be aware that updates/changes are not reflected
