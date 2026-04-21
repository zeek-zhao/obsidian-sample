#!/bin/bash
set -e

log_file=/var/log/boot_log.log

function create_user() {
    user_group="$1"
    user_gid="$2"
    user_account="$3"
    user_uid="$4"
    user_home="$5"
    user_password="$6"

    # 参数验证
    if [ -z "${user_account}" ]
    then
        echo "(${BASH_SOURCE[0]}: line $LINENO)错误: 用户账号为空!" >> ${log_file}
        return 0
    fi

    if [ -z "${user_uid}" ]
    then
        echo "(${BASH_SOURCE[0]}: line $LINENO)错误: 用户ID为空!" >> ${log_file}
        return 0
    fi

    if [ -z "${user_password}" ]
    then
        echo "(${BASH_SOURCE[0]}: line $LINENO)错误: 用户密码为空!" >> ${log_file}
        return 0
    fi

    # 设置默认值
    if [ -z "${user_group}" ]
    then
        user_group="${user_account}"
    fi

    if [ -z "${user_gid}" ]
    then
        user_gid="${user_uid}"
    fi
    
    # 处理用户组
    if grep -Eq "^${user_group}:" /etc/group
    then
        if ! grep -E "^${user_group}:x:${user_gid}:" /etc/group
        then
            groupmod -g "${user_gid}" "${user_group}"
        fi
    elif grep -Eq "^[^:]+:[^:]+:${user_gid}:" /etc/group
    then
        old_group="$(grep -E "^[^:]+:[^:]+:${user_gid}:" /etc/group | grep -Eo "^[^:]+")"
        test -n "${old_group}"
        groupmod -n "${user_group}" "${old_group}"
    else
        groupadd -g "${user_gid}" "${user_group}"
    fi

    # 创建用户
    useradd_options=" -MN"
    if [ -n "${user_home}" ]
    then
        useradd_options="${useradd_options} -d ${user_home}"
    fi
    useradd_options="${useradd_options} -s /bin/zsh -G sudo"
    useradd_options="${useradd_options} -g ${user_group} -u ${user_uid} "

    useradd ${useradd_options} -c "docker user" ${user_account}
    echo "成功添加用户 ${user_account}，选项: [${useradd_options} -c \"docker user\"]" >> ${log_file}
    echo "${user_account}:${user_password}" | chpasswd
    echo "成功为 ${user_account} 设置密码!" >> ${log_file}
}

function review_user() {
    group_info="$1"
    user_info="$2"
    user_password="$3"

    user_account="$(echo "${user_info}" | awk -F: '{print $1}')"
    user_uid="$(echo "${user_info}"     | awk -F: '{print $3}')"
    user_gid="$(echo "${user_info}"     | awk -F: '{print $4}')"
    user_home="$(echo "${user_info}"    | awk -F: '{print $6}')"

    user_account=${user_account// /}
    user_uid=${user_uid// /}
    user_gid=${user_gid// /}
    user_home=${user_home// /}

    # 跳过空用户
    if [ -z "${user_account}" ]
    then
        return 0
    fi

    # 检查用户是否存在，是否需要重新创建
    if grep -q ^${user_account}: /etc/passwd
    then
        recreate_user=false

        if [ -n "${user_uid}" ]
        then
            if [ "$(grep ^${user_account}: /etc/passwd | awk -F: '{print $3}')" != "${user_uid}" ]
            then
                recreate_user=true
            fi
        fi

        if [ -n "${user_gid}" ]
        then
            if [ "$(grep ^${user_account}: /etc/passwd | awk -F: '{print $4}')" != "${user_gid}" ]
            then
                recreate_user=true
            fi
        fi

        if [ -n "${user_home}" ]
        then
            if [ "$(grep ^${user_account}: /etc/passwd | awk -F: '{print $6}')" != "${user_home}" ]
            then
                recreate_user=true
            fi
        fi

        if ${recreate_user}
        then
            userdel ${user_account}
        fi
    elif awk -F: '{print $3}' /etc/passwd | grep -q "^${user_uid}$"
    then
        # 删除具有相同UID的用户
        for exist_user in $(awk -F: '{print $1,$3}' /etc/passwd | grep " ${user_uid}$" | awk '{print $1}')
        do
            userdel ${exist_user}
        done
    fi

    # 创建用户
    if ! grep -q ^${user_account}: /etc/passwd
    then
        user_group="$(echo "${group_info}" | awk -F'[=()]' '{print $3}')"
        create_user "${user_group}" "${user_gid}" "${user_account}" "${user_uid}" "${user_home}" "${user_password}"
    fi
}

function review_hosts_file() {
    # 设置hosts映射
    declare -A hosts_map
    hosts_map=( [localhost]="127.0.0.1"
               )
    for key in ${!hosts_map[*]}
    do
        if ! cat /etc/hosts | grep -Eq "^${hosts_map[${key}]}[^[:graph:]]+${key}$"
        then
            echo "${hosts_map[${key}]}  ${key}" >> /etc/hosts
        fi
    done
}

# 设置默认密码
if [ -z "${USER_PASSWORD// /}" ]
then
    USER_PASSWORD=123
fi

# 初始化系统配置
review_hosts_file
review_user "${GROUP_INFO}" "${USER_INFO}" "${USER_PASSWORD}"

# 执行传入的命令
echo "启动容器服务..."
exec "$@"
