// Writer: uuanqin
// At: 2023.07.27

const { exit } = require('process');
YAML = require('yamljs');
var exec = require('child_process').exec;
const package_json = require('./package.json')

function execute(cmd){
    return new Promise((resolve, reject)=>{
        exec(cmd, function(error, stdout, stderr) {
            if(error){
                console.error(error);
            }
            else{
                // console.log(stdout)
                console.log(`PRE-CHECK: excuse command - ${cmd}`)
                return resolve(stdout)
            }
            return reject("err")
        })
    })
}

// 参考
// https://github.com/moelody/hexo-link-obsidian
// https://github.com/moelody/link-to-server
// 插件默认监听的端口号
var port = 3333

// 查看有没有自定义port
function update_custom_port(){

    // Load yaml file using YAML.load
    nativeObject = YAML.load('_config.yml');
    jsonstr = JSON.stringify(nativeObject);
    jsonTemp = JSON.parse(jsonstr, null);

    // 有没有自定义过监听端口，有则改
    if(jsonTemp.easy_images!==undefined && jsonTemp.easy_images.port){
        port = jsonTemp.easy_images.port
    }
}

function main(){
    var pid_arr,pid_port_open_arr;
    execute(`tasklist /FI "IMAGENAME eq Obsidian.exe" /NH`)
        // PID 检查程序是否启动
        .then((str)=>{
            const reg1 = RegExp(/obsidian.exe/gi);
            if(str.search(reg1)<0){
                throw "Obsidian.exe is not running."
            }
            console.log(str)
            pid_arr = str.match(/(?<=obsidian.exe\s+)[0-9]+(?=\s)/gi)
        })
        // Hexo插件安装检查
        .then(()=>{
            var version = package_json.dependencies["hexo-link-obsidian"]
            if(version !== undefined){
                console.log(`PRE-CHECK: Your hexo-link-obsidian version - ${version}`)
                return;
            }else{
                throw "You haven't install hexo-link-obsidian plugin or just install it in global."
            }
        })
        // 目标端口更新
        .then(()=>{
            update_custom_port()
            console.log("PRE-CHECK: Target port - ",port)
        })
        // 查询目标端口对应开放的PID
        .then(()=>{
            // console.log(pid_arr)
            return execute(`netstat -ano | findstr ":${port}"`)
        })
        // PID_PID 匹配
        .then((str)=>{
            console.log(str)
            pid_port_open_arr = str.match(/(?<=\s+)[0-9]+(?=\r)/g)
            // console.log(pid_port_open_arr)
            const pid_set = new Set(pid_arr)
            // console.log(pid_set)
            for (num of pid_port_open_arr){
                if (pid_set.has(num)){
                    return;
                }
            }
            throw "Target port is not listening by Obsidian. Please check your settings."
        })
        .then(()=>{
            console.log("PRE-CHECK: All checks are done.")
            exit(0);
        })
        .catch((error)=>{
            // 命令执行抛出err
            if(error==="err"){
                console.error(`ERROR: Please contact developer to seek for solutions.`)
            }
            else{
                console.error("ERROR: ",error)
            }
            exit(1);
        })
}

main()

