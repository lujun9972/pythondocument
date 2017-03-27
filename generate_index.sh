#!/bin/bash

declare -A catalog_comment_dict
catalog_comment_dict=([Web]="Web框架" [Scrapy]="web爬取" [DevOps]="DevOps工具" [testing]="测试" [Hardware]="硬件" [DA]="科学计算与数据分析" [raw]="未翻译或者翻译到一半的内容" [ML]="机器学习" [Python-Common]="Python常规文档" [NLP]="自然语言处理")

catalogs=${!catalog_comment_dict[*]}

function get_head()
{
    echo <<EOF

# pythondocument
translate python documents to Chinese for convenient reference
简而言之，这里用来存放那些Python文档君们，并且尽力将其翻译成中文~~

EOF
}

function get_contributors()
{
    echo "## Contributors"
    echo "感谢GitHub以及:"
    git shortlog --summary --email |cut -f2|sed -e 's/^/+ /'
}

function generate_headline()
{
    local catalog="$@"
    echo "## " "$catalog"
    echo ${catalog_comment_dict["$catalog"]}
    echo 
    if [[ ! -d "$catalog" ]];then
        mkdir -p $catalog
    fi
    generate_links "$catalog" |sort -t "<" -k2 -r
}

function generate_links()
{
    local catalog=$1
    posts=$(ls -t $catalog)
    old_ifs=$IFS
    IFS="
"
    for post in $posts
    do
        modify_date=$(git log --date=short --pretty=format:"%cd" -n 1 $catalog/$post) # 去除日期前的空格
        if [[ -n "$modify_date" ]];then # 没有修改日期的文件没有纳入仓库中,不予统计
            echo "+ [[https://github.com/lujun9972/emacs-document/blob/master/$catalog/$post][$post]]		<$modify_date>"
        fi
    done
    IFS=$old_ifs
}

get_contributors

for catalog in ${!catalog_comment_dict[*]}
do
    generate_headline $catalog
done
