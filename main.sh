#!/bin/sh
# Developer: 初慕苏流年
#------
url="http://[IP]:[PORT]"
vkey="[vkey]"
logfile="log.txt"
qq="[QQ_Bot]"
#------

cout()
# string -> null
{
  #cout $msg ...
  time=$(date +"%Y:%m:%d|%H:%M:%S")
  date="[$time]$*"
  echo "$date" >> $logfile
  echo "\033[32m$date\033[0m"
}
error()
# string -> null
{
  time=$(date +"%Y:%m:%d|%H:%M:%S")
  date="[$time]$*"
  echo "$date" >> $logfile
  echo "\033[31m$date\033[0m"
}
json()
# json: string -> string
{
  #json $json $key
  #echo $*
  return `echo $1 |grep '$2[" :]+\K[^"]+'`
}
verify()
# null -> key: string
{
  key=`curl $url/verify -X POST -d "{\"verifyKey\": \"$vkey\"}" -s`
  #echo "$key"
  #cout $key 
  #key=`json $key "session"`
  key=${key#*\":\"}
  key=${key%\"*}
  cout "key:" $key
}
bind()
# key: string -> null
{
  msg=`curl $url/bind -X POST -d "{\"sessionKey\": $1, \"qq\": $qq}" -s`
  #msg=`echo $msg|grep "[a-z]*"`
  cout "$msg"
  #if [[ $msg == *success* ]];
  if echo $msg | grep -q success;
  then
    cout "绑定账号成功！"
  else
    error "绑定账号错误！"
  fi
}
send()
# sendmsg: string && group: string
{
  cache0=`curl $url/sendGroupMessage -X POST -d "{\"sessionKey\": $key,\"target\": $2,\"messageChain\":[{\"type\":\"Plain\",\"text\":\"$1\"}]}" -s`
  cout $cache0
}
bot()
# null -> null
{
  boturl="$url/peekLatestMessage?sessionKey=$key&count=1"
  #cout $boturl
  msg=`curl $boturl -s`
  if [ "$msg" != *\"data\":[]* ];
  then
    if [ "$cache" != "$msg" ];
    #echo $cache $msg
    then
      cache=$msg
      #cout $msg
      #echo $msg | sed -n '/(?<="data":\["text":").*?(?="\])/p'
      info=${msg#*text\":\"}
      sender=${msg#*sender\":}
      group=${msg#*group\":}
      name=${msg#*memberName\":}
      message=${info%%\"\}\]*}
      sender=${sender#*id\":}
      group=${group#*id\":}
      name=${name#\"}
      sender=${sender%%,\"member*}
      group=${group%%,\"name\"*}
      name=${name%%\",\"special*}
      cout "$group|$name($sender) -> $message"
      #send $info $group
      yiyan $message $sender $group &
    fi
  fi
}
yiyan()
{
  if echo $1 | grep -q ".一言";
  then
    cache1=`curl https://v1.hitokoto.cn/\?c=d\&i -s`
    cache1=${cache1#*hitokoto\":\"}
    cache1=${cache1%%\",\"type*}
    send $cache1 $group
  fi
}
cout "form:" "初慕苏流年"
cout "log file:" $logfile
verify
bind $key
run=1
cache=""
while [ $run ];
do
  bot
  sleep 0.5s
done