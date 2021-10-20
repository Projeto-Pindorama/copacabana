| Tools supplied by GNU coreutils                      | Tools supplied by the Heirloom Project                            | Tools supplied by OpenBSD                  | posix-alt.shi-derived       |
|------------------------------------------------------|-------------------------------------------------------------------|--------------------------------------------|-----------------------------|
| chcon                                                | SELinux-specific                                                  | SELinux-specific                           | -                           |
| chgrp                                                | -                                                                 | chgrp (it's in the same folder than chown) | -                           |
| chown                                                | chown; chown_ucb                                                  | -                                          | -                           |
| chmod                                                | chmod; chmod_sus                                                  | -                                          | -                           |
| cp                                                   | cp; cp_s42; cp_sus                                                | -                                          | -                           |
| dd                                                   | dd                                                                | -                                          | -                           |
| df                                                   | df; df_ucb; dfspace                                               | -                                          | -                           |
| dir                                                  | unnecessary/DOS-users sugar                                       | unnecessary/DOS-users sugar                | unnecessary/DOS-users sugar |
| dircolors                                            | unnecessary/DOS-users sugar                                       | unnecessary/DOS-users sugar                | unnecessary/DOS-users sugar |
| install                                              | install_ucb                                                       | -                                          | -                           |
| ln                                                   | ln_ucb; (ln; ln_s42; ln_sus mv (it's in the same folder than cp)) | -                                          | -                           |
| ls                                                   | ls; ls_su3; ls_sus; ls_ucb                                        | -                                          | -                           |
| mkdir                                                | mkdir; mkdir_sus                                                  | -                                          | -                           |
| mkfifo                                               | mkfifo                                                            | -                                          | -                           |
| mknod                                                | mknod                                                             |                                            | -                           |
| mktemp                                               | -                                                                 | mktemp                                     | -                           |
| mv                                                   | mv; mv_s42; mv_sus (it's in the same folder than cp)              | -                                          | -                           |
| realpath                                             | -                                                                 | -                                          | -                           |
| rm                                                   | rm; rm_sus                                                        | -                                          | -                           |
| rmdir                                                | rmdir; rmdir_sus                                                  | -                                          | -                           |
| shred                                                | -                                                                 | -                                          | -                           |
| sync                                                 | sync (i don't think it's the same purpose)                        | -                                          | -                           |
| touch                                                | touch; touch_sus                                                  | -                                          | -                           |
| truncate                                             | -                                                                 | -                                          | -                           |
| vdir                                                 | -                                                                 | -                                          | -                           |
| b2sum                                                | -                                                                 | -                                          | -                           |
| base32                                               | -                                                                 | -                                          | -                           |
| base64                                               | -                                                                 | -                                          | -                           |
| cat                                                  | cat                                                               | -                                          | -                           |
| cksum                                                | cksum                                                             | -                                          | -                           |
| comm                                                 | comm                                                              | -                                          | -                           |
| csplit                                               | csplit; csplit_su3; csplit_sus                                    | -                                          | -                           |
| cut                                                  | cut                                                               | -                                          | -                           |
| expand                                               | expand                                                            | -                                          | -                           |
| fmt                                                  | fmt                                                               | -                                          | -                           |
| fold                                                 | fold                                                              | -                                          | -                           |
| head                                                 | head                                                              | -                                          | -                           |
| join                                                 | join                                                              | -                                          | -                           |
| md5sum                                               | -                                                                 | -                                          | -                           |
| nl                                                   | nl; nl_su3; nl_s42; nl_sus                                        | -                                          | -                           |
| numfmt                                               | -                                                                 | -                                          | -                           |
| od                                                   | od; od_sus                                                        | -                                          | -                           |
| paste                                                | paste                                                             | -                                          | -                           |
| ptx                                                  | -                                                                 | -                                          | -                           |
| pr                                                   | pr; pr_sus                                                        | -                                          | -                           |
| sha1sum, sha224sum, sha256sum, sha384sum, sha512sum  | -                                                                 | -                                          | -                           |
| shuf                                                 | -                                                                 | -                                          | -                           |
| sort                                                 | sort; sort_sus                                                    | -                                          | -                           |
| split                                                | split                                                             | -                                          | -                           |
| sum                                                  | sum; sum_ucb                                                      | -                                          | -                           |
| tac                                                  | -                                                                 | -                                          | -                           |
| tail                                                 | tail                                                              | -                                          | -                           |
| tr                                                   | tr; tr_sus; tr_ucb                                                | -                                          | -                           |
| tsort                                                | tsort                                                             | -                                          | -                           |
| unexpand                                             | unexpand                                                          | -                                          | -                           |
| uniq                                                 | uniq                                                              | -                                          | -                           |
| wc                                                   | wc; wc_s42; wc_sus                                                | -                                          | -                           |
| arch                                                 | -                                                                 | -                                          | -                           |
| basename                                             | basename; basename_sus; basename_ucb                              | -                                          | -                           |
| chroot                                               | -                                                                 | chroot                                     | -                           |
| date                                                 | date; date_sus                                                    | -                                          | -                           |
| dirname                                              | dirname                                                           | -                                          | -                           |
| du                                                   | du; du_sus; du_ucb                                                | -                                          | -                           |
| echo                                                 | echo; echo_sus; echo_ucb                                          | -                                          | -                           |
| env                                                  | env                                                               | -                                          | -                           |
| expr                                                 | expr; expr_s42; expr_su3; expr_sus                                | -                                          | -                           |
| factor                                               | factor                                                            | -                                          |                             |
| false                                                | true/false: POSIX shell script, ASCII text executable             | -                                          | -                           |
| groups                                               | groups; groups_ucb                                                | -                                          | -                           |
| hostid                                               | -                                                                 | -                                          | -                           |
| id                                                   | id; id_sus                                                        | -                                          | -                           |
| link                                                 | -                                                                 | -                                          | -                           |
| logname                                              | logname                                                           | -                                          | -                           |
| nice                                                 | nice                                                              | -                                          | -                           |
| nohup                                                | nohup                                                             | -                                          | -                           |
| nproc                                                | -                                                                 | -                                          | nproc()/nproc-go            |
| pathchk                                              | pathchk                                                           | -                                          | -                           |
| pinky                                                | -                                                                 | -                                          | -                           |
| printenv                                             | printenv                                                          | -                                          | -                           |
| printf                                               | printf                                                            | -                                          | -                           |
| pwd                                                  | pwd                                                               | -                                          | -                           |
| readlink                                             | -                                                                 | readlink                                   | -                           |
| runcon                                               | -                                                                 | -                                          | -                           |
| seq                                                  | -                                                                 | -                                          | seq() (to rewrite)          |
| sleep                                                | sleep                                                             | -                                          | -                           |
| stat                                                 | -                                                                 | stat                                       | -                           |
| stdbuf                                               | -                                                                 | -                                          | -                           |
| stty                                                 | stty; stty_ucb                                                    | -                                          | -                           |
| tee                                                  | tee                                                               | -                                          | -                           |
| test                                                 | test; test_sus; test_ucb                                          |                                            | -                           |
| timeout                                              | -                                                                 | -                                          | timeout()                   |
| true                                                 | true/true: POSIX shell script, ASCII text executable              | -                                          | -                           |
| tty                                                  | tty                                                               | -                                          | -                           |
| uname                                                | uname                                                             | -                                          | -                           |
| unlink                                               | -                                                                 | -                                          | -                           |
| uptime                                               | -                                                                 | -                                          | -                           |
| users                                                | users                                                             | -                                          | -                           |
| who                                                  | who; who_sus                                                      | -                                          | -                           |
| whoami                                               | whoami                                                            | -                                          | -                           |
| yes                                                  | yes                                                               | -                                          | -                           |
| [                                                    | [                                                                 | -                                          | -                           |
